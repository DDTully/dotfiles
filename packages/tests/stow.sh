#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit

if ! command -v stow >/dev/null; then
  printf 'SKIP: real GNU Stow tests require stow\n' >&2
  exit 0
fi

root=$(realpath "${BASH_SOURCE[0]%/*}/../..")
tmp=$(mktemp -d /tmp/opencode/pkgfiles-stow-test.XXXXXX)
trap 'rm -rf -- "$tmp"' EXIT
export PKGFILES_REPO="$tmp/repo with spaces" HOME="$tmp/home with spaces"
mkdir -p "$PKGFILES_REPO/packages" "$PKGFILES_REPO/alpha" "$PKGFILES_REPO/beta" "$HOME" "$tmp/work"
printf 'alpha\n' > "$PKGFILES_REPO/alpha/.alpha"
printf 'beta\n' > "$PKGFILES_REPO/beta/.beta"
printf '# Selected configs\n\nalpha\nbeta' > "$PKGFILES_REPO/packages/configs.txt"
cli="$root/utils/.config/pkgfiles/pkgfiles"
cd "$tmp/work"

output=$(bash "$cli" stow)
[[ $output == *' alpha beta '* && ! -e $HOME/.alpha && ! -e $HOME/.beta ]]
bash "$cli" stow --apply
[[ -L $HOME/.alpha && -L $HOME/.beta ]]
[[ $(readlink -f "$HOME/.alpha") == "$PKGFILES_REPO/alpha/.alpha" ]]
[[ $(readlink -f "$HOME/.beta") == "$PKGFILES_REPO/beta/.beta" ]]
bash "$cli" stow --apply

rm "$HOME/.alpha" "$HOME/.beta"
printf 'keep local file\n' > "$HOME/.beta"
if bash "$cli" stow --apply > "$tmp/out" 2> "$tmp/err"; then
  printf 'Unexpected success with a Stow conflict\n' >&2
  exit 1
fi
[[ $(< "$tmp/err") == *'conflict'* ]]
[[ ! -e $HOME/.alpha && ! -L $HOME/.beta && $(< "$HOME/.beta") == 'keep local file' ]]

for selection in '' '# Empty selection' '--adopt' '../alpha'; do
  printf '%s\n' "$selection" > "$PKGFILES_REPO/packages/configs.txt"
  if bash "$cli" stow --apply > "$tmp/out" 2> "$tmp/err"; then
    printf 'Unexpected success with selection: %s\n' "$selection" >&2
    exit 1
  fi
  [[ $(< "$tmp/err") == pkgfiles:* ]]
  [[ ! -e $HOME/.alpha && ! -L $HOME/.beta && $(< "$HOME/.beta") == 'keep local file' ]]
done
printf 'All pkgfiles real GNU Stow tests passed.\n'
