#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit

root=$(realpath "${BASH_SOURCE[0]%/*}/../..")
bash "$root/packages/tests/stow.sh"
bash "$root/packages/tests/devtools.sh"
tmp=$(mktemp -d /tmp/opencode/pkgfiles-test.XXXXXX)
trap 'rm -rf -- "$tmp"' EXIT
export PKGFILES_REPO="$tmp/repo with spaces" HOME="$tmp/home with spaces"
export FIXTURES="$tmp/fixtures" PKGFILES_DISTRO=arch
mkdir -p "$PKGFILES_REPO/packages" "$HOME/.config" "$FIXTURES" "$tmp/bin"
cp "$root/packages/config-map.tsv" "$root/packages/configs.txt" "$PKGFILES_REPO/packages/"
for config in bash bat ghostty herdr nvim starship tmux yazi utils skills; do
  mkdir -p "$PKGFILES_REPO/$config"
done
cp -a "$root/bash" "$root/bat" "$root/nvim" "$PKGFILES_REPO/"
mkdir -p "$PKGFILES_REPO/utils/.config/pkgfiles" "$PKGFILES_REPO/skills/.agent_skills"
cp "$root/utils/.config/pkgfiles/pkgfiles" "$PKGFILES_REPO/utils/.config/pkgfiles/"
cp "$root/packages/tests/mock-command" "$tmp/bin/mock-command"
chmod +x "$tmp/bin/mock-command"
for tool in pacman apt-cache sudo yay; do ln -s mock-command "$tmp/bin/$tool"; done
export PATH="$tmp/bin:$PATH"
cli="$PKGFILES_REPO/utils/.config/pkgfiles/pkgfiles"
export MOCK_NATIVE='bash bat neovim' MOCK_AUR=''

expect() {
  : "Assert a literal substring occurs in the captured output."
  [[ $output == *"$1"* ]] || { printf 'Missing %q in:\n%s\n' "$1" "$output" >&2; exit 1; }
}

reject() {
  : "Assert failure and preserve diagnostics for the next assertion."
  if bash "$cli" "$@" > "$tmp/out" 2> "$tmp/err"; then
    printf 'Unexpected success: %s\n' "$*" >&2
    exit 1
  fi
}

printf 'unrelated-machine-package\n' > "$PKGFILES_REPO/packages/arch-native.txt"
printf '# Fresh selection\n\nbash\nbat\nnvim\nutils\nskills\nbash' > "$PKGFILES_REPO/packages/configs.txt"
output=$(bash "$cli")
[[ $output == 'CONFIG       PACKAGE      LINK' && ! -e $FIXTURES/queries ]]
reject install
[[ $(< "$tmp/err") == *'use --selected'* && ! -e $FIXTURES/calls ]]
output=$(bash "$cli" --selected)
expect 'unlinked'
expect 'neovim'
output=$(bash "$cli" install --selected)
expect 'sudo pacman -Syu --needed -- bash bat neovim'
[[ $output != *unrelated* && $output != *utils* && $output != *skills* && ! -e $FIXTURES/calls ]]
bash "$cli" install --selected --apply
output=$(< "$FIXTURES/calls")
expect 'sudo pacman -Syu --needed -- bash bat neovim'
rm "$FIXTURES/calls"

ln -s "$PKGFILES_REPO/bash/.bashrc" "$HOME/.bashrc"
ln -s "$PKGFILES_REPO/nvim/.config/nvim" "$HOME/.config/nvim"
cp -a "$PKGFILES_REPO/bat/.config/bat" "$HOME/.config/bat"
output=$(bash "$cli")
expect 'neovim'
expect 'linked'
[[ $output != *bat* && $output != *unrelated* ]]
output=$(bash "$cli" install)
expect 'sudo pacman -Syu --needed -- bash neovim'
[[ $output != *bat* ]]
rm -r "$HOME/.config/bat"
ln -s "$tmp/absent" "$HOME/.config/bat"
output=$(bash "$cli")
[[ $output != *bat* ]]
rm "$HOME/.config/bat"
mkdir "$tmp/other-bat"
cp "$PKGFILES_REPO/bat/.config/bat/config" "$tmp/other-bat/config"
ln -s "$tmp/other-bat" "$HOME/.config/bat"
output=$(bash "$cli")
[[ $output != *bat* ]]

export MOCK_NATIVE=bash MOCK_AUR=neovim
output=$(bash "$cli" install)
expect 'sudo pacman -Syu --needed -- bash'
expect 'yay -S --needed --aur -- neovim'
[[ ! -e $FIXTURES/calls ]]
if ((EUID == 0)); then
  reject install --apply
  [[ ! -e $FIXTURES/calls ]]
else
  bash "$cli" install --apply
  output=$(< "$FIXTURES/calls")
  expect 'yay -S --needed --aur -- neovim'
  [[ $output != *'sudo yay'* ]]
  rm "$FIXTURES/calls"
fi
export MOCK_AUR=''
reject install --apply
[[ $(< "$tmp/err") == *'yay could not resolve neovim'* && ! -e $FIXTURES/calls ]]
export MOCK_FAIL=pacman
reject install --apply
[[ $(< "$tmp/err") == *'pacman query failed'* && ! -e $FIXTURES/calls ]]
unset MOCK_FAIL
mkdir "$tmp/no-yay"
for tool in bash readlink realpath pacman; do ln -s "$(command -v "$tool")" "$tmp/no-yay/$tool"; done
if PATH="$tmp/no-yay" bash "$cli" install > "$tmp/out" 2> "$tmp/err"; then exit 1; fi
[[ $(< "$tmp/err") == *'install yay separately'* && ! -e $FIXTURES/calls ]]

export PKGFILES_DISTRO=apt MOCK_NATIVE='bash bat neovim'
output=$(bash "$cli" install --selected)
expect 'sudo apt-get update'
expect 'sudo apt-get install -- bash bat neovim'
[[ ! -e $FIXTURES/calls ]]
bash "$cli" restore --selected --apply
output=$(< "$FIXTURES/calls")
expect $'sudo apt-get update \nsudo apt-get install -- bash bat neovim '
rm "$FIXTURES/calls"
export MOCK_NATIVE=bash
reject install
[[ $(< "$tmp/err") == *'neovim has no APT candidate'* && ! -e $FIXTURES/calls ]]
export MOCK_EMPTY=1
reject install --apply
output=$(< "$FIXTURES/calls")
[[ $output == 'sudo apt-get update ' && $(< "$tmp/err") == *'no packages were installed'* ]]
rm "$FIXTURES/calls"
unset MOCK_EMPTY
export MOCK_FAIL=apt-cache
reject install
[[ $(< "$tmp/err") == *'apt-cache query failed'* && ! -e $FIXTURES/calls ]]
export MOCK_FAIL=sudo MOCK_NATIVE='bash bat neovim'
reject install --apply
[[ ! -e $FIXTURES/calls ]]
unset MOCK_FAIL
export MOCK_INSTALL_FAIL=1
reject install --apply
unset MOCK_INSTALL_FAIL
rm "$FIXTURES/calls"

for args in '--apply' '--installed' 'unknown' 'install extra' 'stow --selected'; do
  read -r -a arguments <<< "$args"
  reject "${arguments[@]}"
done
printf 'absent\n' > "$PKGFILES_REPO/packages/configs.txt"
reject install --selected
printf 'utils\n' > "$PKGFILES_REPO/packages/configs.txt"
reject install --selected
[[ $(< "$tmp/err") == *'no OS package mapped'* ]]
printf 'ghostty\n' > "$PKGFILES_REPO/packages/configs.txt"
reject install --selected
[[ $(< "$tmp/err") == *'Missing config probe'* ]]
mkdir "$PKGFILES_REPO/unmapped"
printf 'unmapped\n' > "$PKGFILES_REPO/packages/configs.txt"
reject install --selected
[[ $(< "$tmp/err") == *'No mapping for selected config'* ]]
printf 'bash\n' > "$PKGFILES_REPO/packages/configs.txt"
printf 'bash --bad bash .bashrc\n' > "$PKGFILES_REPO/packages/config-map.tsv"
reject install --selected
[[ $(< "$tmp/err") == *'Invalid package name'* ]]
cp "$root/packages/config-map.tsv" "$PKGFILES_REPO/packages/config-map.tsv"
export PKGFILES_DISTRO=unsupported
reject list
unset PKGFILES_DISTRO
ln -s "$PKGFILES_REPO/bash/bashfuncs.sh" "$HOME/bashfuncs.sh"
# shellcheck source=/dev/null
source "$HOME/bashfuncs.sh"
output=$(unset PKGFILES_REPO; pkgfiles compare)
expect 'neovim'
bash "$cli" snapshot
[[ $(< "$PKGFILES_REPO/packages/arch-native.txt") == unrelated-machine-package && ! -e $FIXTURES/calls ]]
printf 'All pkgfiles mocked tests passed.\n'
