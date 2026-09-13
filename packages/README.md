# Apps for Stowed Configs

`pkgfiles` installs the applications that have configs in this repository.
It defaults to configs currently linked from `$HOME` into this checkout.
On a fresh machine, `--selected` uses the deliberate list in `configs.txt` instead.
This directory is **not a Stow package**.

## Usage

From the repository root, run `source bash/bashfuncs.sh`, then:

```bash
pkgfiles                         # List currently linked configs and package names
pkgfiles install                 # Check availability and print install commands
pkgfiles install --apply         # Install apps for currently linked configs
```

For a fresh machine, edit `packages/configs.txt` for the configs you want:

```bash
pkgfiles --selected              # Show the saved selection, including unlinked configs
pkgfiles install --selected      # Preview installation for that selection
pkgfiles install --selected --apply
pkgfiles stow                    # Print the Stow command for configs.txt
pkgfiles stow --apply            # Simulate first, then link if there are no conflicts
pkgfiles devtools                # Preview NVM/latest Node, stable Rust, and distro Go setup
pkgfiles devtools --apply        # Install them; run as a normal user, never root
```

Before sourcing or stowing anything, the same helper works as
`bash utils/.config/pkgfiles/pkgfiles ...`. Install Git and GNU Stow separately.
`compare` is an alias for `list`; `restore` is an alias for `install` and now uses
the same config-based scope. Neither alias reads historical inventories.

## Small, Explicit Mapping

`config-map.tsv` has one whitespace-separated row per Stow package:

```text
# stow-package arch-package apt-package representative-path-under-HOME
nvim neovim neovim .config/nvim/init.lua
utils - - .config/pkgfiles/pkgfiles
```

| Config | Arch / APT package name |
| --- | --- |
| bash | bash |
| bat | bat |
| ghostty | ghostty |
| herdr | herdr (Arch: AUR/yay; APT candidate required) |
| nvim | neovim |
| starship | starship |
| tmux | tmux |
| yazi | yazi |
| utils, skills | No single OS package; explicitly skipped |

These names are **candidates to check**, not a promise of availability on every
release. `-` means no OS package is mapped for that distro. Utility dependencies,
optional shell tools, plugins, fonts, and language servers remain separate choices.

The `LINK` column is `linked` only when the representative HOME path resolves to
the exact repository source. This handles file links and Stow-folded directory
links. Copies, links to other checkouts, and broken links do not count. It is a
representative check, not an audit of every file or proof that Stow created the link.
The report does not check whether the app is installed.

`configs.txt` accepts one existing Stow directory per line, blank lines, and full-line
`#` comments. It is never generated or overwritten. Unknown selected configs need
a mapping, including an explicit `-` mapping for configs without an OS package.
Stow itself only needs this selection, not the application mapping or a package manager.

## Package Managers

- **Arch/CachyOS:** check each name with `pacman -Si`; packages in configured sync
  repositories use `sudo pacman -Syu --needed`. If a name is not found, check the
  AUR using `yay -Si --aur`, then install it with `yay -S --needed --aur`.
  Install yay separately if needed; run AUR installs as a normal user.
  Pacman's command includes a system upgrade to avoid partial upgrades.
- **Debian/Ubuntu:** check `apt-cache policy` for an install candidate. Apply runs
  `sudo apt-get update`, rechecks candidates, then `sudo apt-get install`.
  Preview checks the current cache without refreshing it.

**Ghostty, Herdr, Starship, and Yazi in particular may lack an APT candidate on your
release.** If any selected app is unavailable, the command reports it and exits
nonzero before installing any packages. APT apply may already have refreshed its
cache. Check your release and configured sources, install that app separately, or
omit its config from `configs.txt` and use `--selected` to install the remaining
apps. The helper does not add third-party repositories or substitute unrelated packages.
An available Neovim package also needs to meet the current LazyVim version requirements.
Debian may provide `batcat` rather than the `bat` command used by these shell helpers.

Plans depend on current repository metadata; repositories can change between the
check and installation. Package-manager prompts are retained. Command failures
propagate, and earlier successful installs are not rolled back. Reports and plans
go to stdout; helper status and errors go to stderr.

## Runtime Toolchains

`devtools` is independent of stowed configs and `--selected`. It installs:

- **Node:** NVM v0.40.7 with `PROFILE=/dev/null` (your shell profiles are never
  edited), then the latest Node release set as the default. Existing NVM
  installations are reused, never reinstalled.
- **Rust:** rustup with `--no-modify-path`, default profile, and the stable
  toolchain; an existing rustup is updated rather than reinstalled.
- **Go:** distro packages (`golang-go` on apt, `go` on pacman) plus build
  prerequisites (`ca-certificates`, `curl`, `git`, `build-essential`/`base-devel`).

Downloaded installers go to a temporary directory that is removed on success or
failure; preview mode prints the commands with a `PREVIEW` placeholder path and
runs nothing. `.bashrc` already sources NVM and Cargo when present and adds
`~/go/bin` to `PATH`, so open a new terminal after applying. Only the OS
packages use `sudo`; refuse to run `devtools --apply` as root.

Requires Bash 4.4+, GNU coreutils, and the matching package tools. Distro detection
uses `/etc/os-release` (`ID`/`ID_LIKE`). `PKGFILES_REPO` overrides the checkout;
`PKGFILES_DISTRO=arch|apt` is for tests or previews with the corresponding tools
available. Do not apply with a mismatched distro override.

## Retired Inventory Workflow

The existing `arch-native.txt`, `arch-foreign.txt`, and `apt-manual.txt` are retained
as **unused legacy backups**. Installation does not read them; no command updates
them. Snapshot/filter/pager machinery and the supplied systemd units were removed.
`pkgfiles snapshot` is a read-only compatibility no-op so an old copied timer cannot
overwrite these backups.

If you previously installed the timer on another machine, retire it there:

```bash
systemctl --user disable --now pkgfiles-snapshot.timer
systemctl --user stop pkgfiles-snapshot.service
```

## Verification

```bash
bash packages/tests/test.sh
shellcheck utils/.config/pkgfiles/pkgfiles packages/tests/{test.sh,stow.sh,devtools.sh,mock-command,mock-devtools-installer}
bash -n bash/bashfuncs.sh
bash -n utils/.config/pkgfiles/pkgfiles
for file in packages/tests/{test.sh,stow.sh,devtools.sh,mock-command,mock-devtools-installer}; do bash -n "$file"; done
git diff --check
```

Tests use temporary checkouts/HOMEs under `/tmp/opencode` and mocked package
managers/sudo. They cover linked vs saved selection, folded/file links, copies and
wrong/broken links, APT availability, pacman/yay routing, devtools previews and
mocked installs on both distros (including failure cleanup and reinstall
idempotence), missing tools/packages,
failed queries/installs, invalid input, legacy snapshot preservation, and the shell
wrapper. Real GNU Stow tests cover previews, repeated apply, conflicts, paths with
spaces, and selection validation; they report a skip if Stow is unavailable.
