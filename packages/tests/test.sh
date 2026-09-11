#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit

root=$(realpath "${BASH_SOURCE[0]%/*}/../..")
tmp=$(mktemp -d /tmp/opencode/pkgfiles-test.XXXXXX)
trap 'rm -rf -- "$tmp"' EXIT
export PKGFILES_REPO="$tmp/repo with spaces" HOME="$tmp/home with spaces"
export FIXTURES="$tmp/fixtures" PKGFILES_DISTRO=arch
mkdir -p "$PKGFILES_REPO" "$HOME/.config" "$FIXTURES" "$tmp/bin"
cp -a "$root/packages" "$PKGFILES_REPO/"
cp -a "$root/bash" "$root/bat" "$root/nvim" "$PKGFILES_REPO/"
mkdir -p "$PKGFILES_REPO/utils/.config/pkgfiles"
cp "$root/utils/.config/pkgfiles/pkgfiles" "$PKGFILES_REPO/utils/.config/pkgfiles/"
cp "$root/packages/tests/mock-command" "$tmp/bin/mock-command"
chmod +x "$tmp/bin/mock-command"
for tool in pacman dpkg-query apt-mark sudo apt-get yay paru stow less; do
  ln -s mock-command "$tmp/bin/$tool"
done
export PATH="$tmp/bin:$PATH"
cli="$PKGFILES_REPO/utils/.config/pkgfiles/pkgfiles"

expect() {
  : "Assert that captured output contains a literal substring."
  [[ $output == *"$1"* ]] || { printf 'Missing %q in:\n%s\n' "$1" "$output" >&2; exit 1; }
}

reject() {
  : "Assert that a helper invocation fails."
  if bash "$cli" "$@" > "$tmp/out" 2> "$tmp/err"; then
    printf 'Unexpected success: %s\n' "$*" >&2
    exit 1
  fi
}

printf 'neovim\nbash\nbat\ncustom-bin\nlibdependency\n' > "$FIXTURES/all"
printf 'neovim\nbash\nbash\n' > "$FIXTURES/native"
printf 'custom-bin\n' > "$FIXTURES/foreign"
ln -s "$PKGFILES_REPO/bash/.bashrc" "$HOME/.bashrc"
ln -s "$PKGFILES_REPO/nvim/.config/nvim" "$HOME/.config/nvim"
cp -a "$PKGFILES_REPO/bat/.config/bat" "$HOME/.config/bat"
output=$(bash "$cli" compare)
expect $'neovim\tyes\tnvim\tavailable\tlinked'
expect $'bash\tyes\tbash\tavailable\tlinked'
expect $'bat\tyes\tbat\tavailable\tunlinked'
expect $'tmux\tno\ttmux\tmissing\tunlinked'
expect $'libdependency\tyes\t-\tno mapping'
baseline=$output
output=$(bash "$cli" --tsv)
[[ $output == "$baseline" ]]
output=$(bash "$cli" --no-pager)
[[ $output == "$baseline" && ! -e $FIXTURES/pager ]]
output=$(bash "$cli" --table)
expect 'PACKAGE'
expect '-------'
[[ $output != *$'\t'* && ! -e $FIXTURES/pager ]]
cp "$PKGFILES_REPO/packages/config-map.tsv" "$tmp/map"
printf 'arch absent bat .config/bat/config\n' >> "$PKGFILES_REPO/packages/config-map.tsv"
output=$(bash "$cli" --installed)
expect $'libdependency\tyes\t-\tno mapping'
[[ $output != *$'\tno\t'* ]]
output=$(bash "$cli" compare --configured)
expect $'absent\tno\tbat\tavailable\tunlinked'
expect $'bat\tyes\tbat\tavailable\tunlinked'
[[ $output != *missing* && $output != *'no mapping'* ]]
output=$(bash "$cli" --installed --configured)
expect $'bat\tyes\tbat\tavailable\tunlinked'
[[ $output != *absent* && $output != *missing* && $output != *'no mapping'* ]]
printf 'arch absent missing .config/missing\n' > "$PKGFILES_REPO/packages/config-map.tsv"
output=$(bash "$cli" --configured --installed)
[[ $output == $'PACKAGE\tINSTALLED\tCONFIG\tREPO\tHOME PROBE' ]]
output=$(bash "$cli" --configured --table)
[[ $output == $'PACKAGE  INSTALLED  CONFIG  REPO  HOME PROBE\n-------  ---------  ------  ----  ----------' ]]
cp "$tmp/map" "$PKGFILES_REPO/packages/config-map.tsv"
if command -v script >/dev/null; then
  printf -v terminal_command 'bash %q' "$cli"
  output=$(script -qec "$terminal_command" /dev/null)
  [[ $(< "$FIXTURES/pager") == '-FRSX' && $output != *$'\t'* ]]
  rm "$FIXTURES/pager"
  output=$(script -qec "$terminal_command --no-pager" /dev/null)
  [[ ! -e $FIXTURES/pager && $output != *$'\t'* ]]
  output=$(script -qec "$terminal_command --tsv" /dev/null)
  [[ ! -e $FIXTURES/pager && $output == *$'\t'* ]]
  MOCK_LESS_QUIT=1 script -qec "$terminal_command" /dev/null > "$tmp/out"
  if MOCK_FAIL=less script -qec "$terminal_command" /dev/null > "$tmp/out"; then
    printf 'Pager failure was hidden\n' >&2
    exit 1
  fi
  rm "$FIXTURES/pager"
  mkdir "$tmp/no-less"
  for tool in bash readlink realpath mktemp sort rm cp pacman; do
    ln -s "$(command -v "$tool")" "$tmp/no-less/$tool"
  done
  printf -v fallback_command 'PATH=%q bash %q' "$tmp/no-less" "$cli"
  output=$(script -qec "$fallback_command" /dev/null)
  expect 'PACKAGE'
  expect '-------'
  [[ ! -e $FIXTURES/pager && $output != *$'\t'* ]]
else
  printf 'SKIP: terminal pager tests require util-linux script\n' >&2
fi
for flag in --installed --configured --no-pager --tsv --table; do
  reject snapshot "$flag"
  reject restore "$flag"
  reject stow "$flag"
done
reject --unknown
reject compare --unknown
reject compare extra
reject --table --tsv
reject snapshot --apply
bash "$cli" snapshot
[[ $(< "$PKGFILES_REPO/packages/arch-native.txt") == $'bash\nneovim' ]]
[[ $(< "$PKGFILES_REPO/packages/arch-foreign.txt") == custom-bin ]]
[[ $(< "$PKGFILES_REPO/packages/apt-manual.txt") == '# Run pkgfiles snapshot'* ]]
before=$(stat -c %Y "$PKGFILES_REPO/packages/arch-native.txt")
bash "$cli" snapshot
[[ $(stat -c %Y "$PKGFILES_REPO/packages/arch-native.txt") == "$before" ]]
export MOCK_FAIL=-Qqem
reject snapshot
[[ $(< "$PKGFILES_REPO/packages/arch-native.txt") == $'bash\nneovim' ]]
unset MOCK_FAIL
: > "$FIXTURES/foreign"
bash "$cli" snapshot
[[ ! -s $PKGFILES_REPO/packages/arch-foreign.txt ]]
printf 'custom-bin\n' > "$FIXTURES/foreign"
bash "$cli" snapshot
output=$(bash "$cli" restore)
expect 'sudo pacman -Syu --needed -- bash neovim'
expect 'paru -S --needed -- custom-bin'
[[ ! -e $FIXTURES/calls ]]
export PKGFILES_AUR_HELPER='yay --evil'
reject restore
unset PKGFILES_AUR_HELPER
printf '%s\n' '--bad-option' > "$PKGFILES_REPO/packages/arch-foreign.txt"
reject restore --apply
[[ ! -e $FIXTURES/calls ]]
bash "$cli" snapshot
if ((EUID == 0)); then
  reject restore --apply
else
  bash "$cli" restore --apply
  output=$(< "$FIXTURES/calls")
  expect 'paru -S --needed -- custom-bin'
  [[ $output != *'sudo paru'* ]]
  rm "$FIXTURES/calls"
fi

export PKGFILES_DISTRO=apt
printf 'bash\tinstalled\nlibfoo:amd64\tinstalled\nremoved\tconfig-files\ndep\tinstalled\n' > "$FIXTURES/dpkg"
printf 'bash\nlibfoo\nremoved\nnot-installed\n' > "$FIXTURES/manual"
bash "$cli" snapshot
[[ $(< "$PKGFILES_REPO/packages/apt-manual.txt") == $'bash\nlibfoo:amd64' ]]
[[ $(< "$PKGFILES_REPO/packages/arch-foreign.txt") == custom-bin ]]
export MOCK_FAIL=apt
reject snapshot
[[ $(< "$PKGFILES_REPO/packages/apt-manual.txt") == $'bash\nlibfoo:amd64' ]]
unset MOCK_FAIL
export MOCK_FAIL=dpkg
reject snapshot
[[ $(< "$PKGFILES_REPO/packages/apt-manual.txt") == $'bash\nlibfoo:amd64' ]]
unset MOCK_FAIL
output=$(bash "$cli" restore)
expect 'sudo apt-get update'
expect 'sudo apt-get install -- bash libfoo:amd64'
[[ ! -e $FIXTURES/calls ]]
bash "$cli" restore --apply
output=$(< "$FIXTURES/calls")
expect 'sudo apt-get install -- bash libfoo:amd64'
rm "$FIXTURES/calls"
export MOCK_FAIL=sudo
reject restore --apply
output=$(< "$FIXTURES/calls")
[[ $output != *'apt-get install'* ]]
unset MOCK_FAIL
rm "$FIXTURES/calls"
: > "$FIXTURES/manual"
bash "$cli" snapshot
[[ ! -s $PKGFILES_REPO/packages/apt-manual.txt ]]
output=$(bash "$cli" restore --apply)
[[ -z $output && ! -e $FIXTURES/calls ]]
rm "$PKGFILES_REPO/packages/apt-manual.txt"
reject restore

printf 'bash\nnvim\n' > "$PKGFILES_REPO/packages/configs.txt"
output=$(bash "$cli" stow)
expect '-- bash nvim'
[[ ! -e $FIXTURES/calls ]]
bash "$cli" stow --apply
output=$(< "$FIXTURES/calls")
expect 'stow --simulate --verbose'
expect 'stow --verbose'
rm "$FIXTURES/calls"
export MOCK_FAIL=stow
reject stow --apply
output=$(< "$FIXTURES/calls")
[[ $output != *'stow --verbose'* ]]
unset MOCK_FAIL
printf '../skills\n' > "$PKGFILES_REPO/packages/configs.txt"
reject stow
reject compare --apply
reject unknown
reject snapshot extra
export PKGFILES_DISTRO=unsupported
reject compare
unset PKGFILES_DISTRO
output=$(bash "$cli" compare)
expect 'PACKAGE'
ln -s "$PKGFILES_REPO/bash/bashfuncs.sh" "$HOME/bashfuncs.sh"
# shellcheck disable=SC1091
source "$HOME/bashfuncs.sh"
output=$(
  unset PKGFILES_REPO
  pkgfiles compare
)
expect 'PACKAGE'
printf 'All pkgfiles mocked tests passed.\n'
