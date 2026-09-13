#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit

root=$(realpath "${BASH_SOURCE[0]%/*}/../..")
tmp=$(mktemp -d /tmp/opencode/pkgfiles-devtools-test.XXXXXX)
trap 'rm -rf -- "$tmp"' EXIT
export HOME="$tmp/home with spaces" FIXTURES="$tmp/fixtures" TMPDIR="$tmp/downloads"
export NVM_DIR="$HOME/.nvm" CARGO_HOME="$HOME/.cargo"
export PKGFILES_REPO="$root" PKGFILES_DISTRO=arch
export DEVTOOLS_INSTALLER="$root/packages/tests/mock-devtools-installer"
unset MOCK_FAIL MOCK_NODE_FAIL MOCK_INSTALL_FAIL
mkdir -p "$HOME" "$FIXTURES" "$tmp/bin" "$TMPDIR"
cp "$root/packages/tests/mock-command" "$tmp/bin/mock-command"
chmod +x "$tmp/bin/mock-command"
for tool in sudo curl; do ln -s mock-command "$tmp/bin/$tool"; done
export PATH="$tmp/bin:$PATH"
cli="$root/utils/.config/pkgfiles/pkgfiles"

for distro in arch apt; do
  export PKGFILES_DISTRO=$distro
  output=$(bash "$cli" devtools)
  [[ $output == *v0.40.7/install.sh* && $output == *sh.rustup.rs* ]]
  [[ ! -e $FIXTURES/calls && ! -e $FIXTURES/queries && ! -e $NVM_DIR ]]
  if [[ $distro == arch ]]; then
    [[ $output == *'sudo pacman -Syu --needed -- ca-certificates curl git base-devel go'* ]]
  else
    [[ $output == *'sudo apt-get install -- ca-certificates curl git build-essential golang-go'* ]]
  fi
done
if bash "$cli" devtools --selected > /dev/null 2>&1; then exit 1; fi
if ((EUID == 0)); then
  if bash "$cli" devtools --apply > /dev/null 2>&1; then exit 1; fi
  [[ ! -e $FIXTURES/calls ]]
  printf 'Devtools preview/root checks passed; user installation mocks require non-root.\n'
  exit 0
fi

for distro in arch apt; do
  export PKGFILES_DISTRO=$distro
  bash "$cli" devtools --apply
  output=$(< "$FIXTURES/calls")
  [[ $output == *$'install nvm\nnvm install node\nnvm alias default node\ninstall rustup\nrustup update stable\nrustup default stable'* ]]
  [[ $output != *'sudo rustup'* ]]
  [[ -z $(command ls -A "$TMPDIR") ]]
  rm "$FIXTURES/calls" "$FIXTURES/queries"
  output=$(bash "$cli" devtools)
  [[ $output != *curl*install.sh* && $output != *sh.rustup.rs* ]]
  bash "$cli" devtools --apply
  output=$(< "$FIXTURES/calls")
  [[ $output != *'install nvm'* && $output != *'install rustup'* && $output == *'rustup update stable'* ]]
  export MOCK_NODE_FAIL=1
  rm "$FIXTURES/calls"
  if bash "$cli" devtools --apply > /dev/null 2>&1; then exit 1; fi
  output=$(< "$FIXTURES/calls")
  [[ $output != *'nvm alias'* && $output != *rustup* && -z $(command ls -A "$TMPDIR") ]]
  unset MOCK_NODE_FAIL
  rm -r "$NVM_DIR" "$CARGO_HOME"
  rm "$FIXTURES/calls"
  export MOCK_FAIL=curl
  if bash "$cli" devtools --apply > /dev/null 2>&1; then exit 1; fi
  [[ ! -e $NVM_DIR && ! -e $CARGO_HOME && -z $(command ls -A "$TMPDIR") ]]
  unset MOCK_FAIL
  rm "$FIXTURES/calls"
done
printf 'All pkgfiles devtools tests passed.\n'
