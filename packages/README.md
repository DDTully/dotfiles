# Package Inventory And Restore

This directory is **not a Stow package**. It contains portable package-name
inventories, not a disk image or a complete system backup. Requires Bash 4.4+,
GNU coreutils, and `flock` (util-linux) for snapshots. Package managers are
autodetected using `/etc/os-release` (`ID` and `ID_LIKE`), not executable priority.
Arch derivatives and Debian/Ubuntu derivatives are supported.

## Commands

From the repository root, without installing or stowing anything:

```bash
bash utils/.config/pkgfiles/pkgfiles help
bash utils/.config/pkgfiles/pkgfiles compare
bash utils/.config/pkgfiles/pkgfiles snapshot
```

Or source `bash/bashfuncs.sh` and use the `pkgfiles` function. The function resolves
the repository through its source file, including when `~/bashfuncs.sh` is a Stow
symlink. No `.bashrc` edits or new PATH entry are required. The standalone script
is invoked with `bash` intentionally.

| Command | Behavior |
| --- | --- |
| `pkgfiles` or `pkgfiles compare` | Read-only report of all installed packages and mapped configs |
| `pkgfiles snapshot` | Replace this distro's manifests with the current explicit-installed inventory |
| `pkgfiles restore` | Print shell-escaped install commands, execute nothing |
| `pkgfiles restore --apply` | Execute the install commands, retaining package-manager prompts |
| `pkgfiles stow` | Print the Stow command for `configs.txt`, execute nothing |
| `pkgfiles stow --apply` | Simulate Stow first; only proceed if simulation succeeds |

Status messages go to stderr; reports/plans go to stdout. Invalid input or a failed
query/command returns nonzero. Snapshot gathers and validates all lists before
replacing anything, serializes concurrent snapshots, and atomically replaces each
changed file. The two Arch files are not an atomic pair in a power failure.
Unchanged lists are not rewritten. No command commits or pushes changes.

## Manifests

- `arch-native.txt`: `pacman -Qqen`, explicit packages in configured sync databases.
- `arch-foreign.txt`: `pacman -Qqem`, explicit foreign packages, often AUR but also local builds.
- `apt-manual.txt`: `apt-mark showmanual` intersected with actually installed dpkg packages, retaining architecture suffixes.
- `configs.txt`: a deliberate, editable Stow selection independent of package inventories. `skills` is omitted by default; add it deliberately if desired.

The Arch manifests were seeded from this CachyOS machine (290 explicit native
packages and 23 explicit foreign packages at capture time). They include
CachyOS-specific repositories and packages, not just stock Arch packages.
`apt-manual.txt` remains a commented placeholder until captured on Debian/Ubuntu.
Run `snapshot` on each source system before relying on the lists. It updates only
the current distro's files. Inventory is current state, not an append-only history:
removing a package removes its entry on the next snapshot. Dependencies are left
to package managers, unless marked explicit/manual. Base-image packages marked
manual may also appear. Use Git history for historical lists and review diffs
before committing yourself.

One package per line; empty lines and lines starting with `#` are accepted.
Options, paths, version expressions, inline comments, and shell syntax are
rejected. Lists are passed as command arrays, never evaluated as shell code.

`PKGFILES_REPO=/path/to/dotfiles` overrides the repository location.
`PKGFILES_DISTRO=arch` or `apt` overrides detection for testing or previewing the
other distro's restore plan; do not use the wrong override with `--apply`.
These are per-distro, not per-host or per-release lists. Do not enable writers
from several same-distro hosts against one synced inventory unless you want the
most recent host's inventory to replace the previous one.

## Config Comparison

```bash
pkgfiles [compare] [--installed] [--configured] [--explicit|--dependencies] [--no-pager] [--tsv|--table]
```

On a terminal, comparisons use an aligned ASCII table. With terminal stdin and
stdout, `less -FRSX` pages the report if installed (quit with `q`; long lines can
be scrolled horizontally). Without `less`, the table prints directly. No new
dependency is required, and `PAGER` is not used or evaluated. `--no-pager`
disables paging without changing the format. Quitting the pager early is safe.

Pipes and redirections use raw TSV output, including its header,
and never start a pager. `--tsv` forces TSV even on a terminal and disables paging;
`--table` forces an aligned table even when redirected. These two flags cannot be
combined. An empty selection still prints the header (and table separator).

Columns are `PACKAGE`, `INSTALLED`, `REASON`, `CONFIG`, `REPO`, and `HOME PROBE`.
`REASON` is `explicit` or `dependency` on Arch, `manual` or `auto` on Debian/Ubuntu,
and `-` when not installed. Reasons use the current inventory queries, not saved
manifests: both native and foreign explicit lists on Arch, and installed manual
packages on APT. Explicit/manual packages are not necessarily apps.

- `--installed`: only packages currently installed, including dependencies.
- `--configured`: only mapping rows whose representative config probe exists in
  the repository, **not necessarily linked in HOME**. It does not use `configs.txt`.
- `--explicit`: only installed explicit (Arch) or manual (APT) packages.
- `--dependencies`: only installed dependency (Arch) or auto (APT) packages.
- `--explicit` and `--dependencies` are mutually exclusive and imply `--installed`.
- All filters combine with **AND**, including `--configured` and `--installed`.

For example, `pkgfiles --explicit --configured` shows explicit/manual packages with repo
configs; `pkgfiles compare --configured --tsv > configs.tsv` exports all available
mapped configs, including packages not installed. `pkgfiles --dependencies` lists
installed dependencies/auto packages. Filters and display options are
valid only for comparison. Restore and Stow retain their existing `--apply` option.

Edit `config-map.tsv` with whitespace-separated rows:

```text
# distro package-name stow-package representative-path-under-HOME
arch neovim nvim .config/nvim/init.lua
arch ghostty-git ghostty .config/ghostty/config
apt neovim nvim .config/nvim/init.lua
```

The report includes mapped apps even when not installed. Packages installed only
as dependencies also appear. An unmapped package is reported as `no mapping`, not
an error or a claim that it needs configuration. Add distro-specific alternative
package names yourself. Manually downloaded binaries, AppImages, Flatpaks, Cargo,
pip/uv, and npm installations are not queried.

`available` means the mapped probe exists in the repository; `linked` means the
HOME probe resolves to that exact repository path. This handles Stow's folded
directory links and individual file links. A regular copy, wrong-repository link,
or absent/broken link is not considered linked. These are **representative probe
checks, not a full audit of every config file**, nor proof that GNU Stow originally
created a link. Add additional probe rows when useful. Probe paths cannot contain
whitespace. Comparison does not inspect `utils` or `skills` automatically because
they do not correspond to one OS package.

## Automatic Updates

An opt-in **unprivileged user timer** refreshes inventories about once a minute,
including installs/removals via `sudo pacman`, yay/paru, apt, graphical frontends,
and explicit/manual marking changes. No shell command interception or root hooks
are needed. This avoids letting a root package-manager hook execute mutable code
from a user-owned repository.

Nothing is enabled automatically. After taking the initial snapshot, on your
original system, you can deliberately enable it with:

```bash
mkdir -p ~/.config/systemd/user
cp packages/automation/pkgfiles-snapshot.{service,timer} ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now pkgfiles-snapshot.timer
systemctl --user status pkgfiles-snapshot.timer
journalctl --user -u pkgfiles-snapshot.service
```

The service assumes `~/dotfiles`. For another location, edit the installed unit's
`ExecStart` to `/usr/bin/bash "/absolute/path/utils/.config/pkgfiles/pkgfiles" snapshot`
before enabling it. Quote paths containing spaces; systemd specifiers such as `%`
must be escaped as `%%` in literal paths. Do not run the service with `sudo`.

This is eventual inventory refresh, **not an immediate transaction hook**. It runs
only while your user manager runs. Failed queries preserve existing manifests and
are retried next tick. A read during an active package transaction can observe an
intermediate state; a later successful tick converges to the completed state.
Run `pkgfiles snapshot` after transactions finish and before backing up/reinstalling.
Without systemd, run snapshots yourself; there is no automatic fallback.

Disable updates before restoring a saved inventory or editing a desired list:

```bash
systemctl --user disable --now pkgfiles-snapshot.timer
systemctl --user stop pkgfiles-snapshot.service
```

**Do not enable the timer on a fresh system until restoration is complete.** It
would otherwise overwrite the saved desired inventory with the new minimal system.
The automation files live outside Stow packages, so even `pkgfiles stow --apply`
does not install or enable the timer.

## Reinstall Workflow

1. On the old system, finish package transactions, snapshot, review and back up the repository (including the manifests). Back up user data, secrets, and repository settings separately.
2. On the fresh matching distro, clone/restore the repository. Keep the timer disabled. Review the manifests, configure package repositories/signing keys, and install Stow yourself if it is not in the list.
3. Run `bash utils/.config/pkgfiles/pkgfiles restore` and inspect the plan. Run it again with `--apply` only when ready to install.
4. Review `packages/configs.txt`. Remove unwanted packages, especially apps unavailable on this distro, and back up conflicting existing HOME files. Preview with `bash utils/.config/pkgfiles/pkgfiles stow`, then deliberately use `stow --apply` through the helper.
5. Compare, take a fresh snapshot, then optionally enable the timer.

Arch native restoration uses `sudo pacman -Syu --needed`, avoiding partial upgrades.
Foreign restoration uses `paru` if available, otherwise `yay`;
`PKGFILES_AUR_HELPER=yay` or `paru` selects explicitly. With foreign entries,
`--apply` checks for the helper and rejects root execution **before** native installs.
Install/bootstrap the helper separately as a normal user. The helper is never run
through sudo. Foreign does not mean guaranteed AUR availability: review local-only,
renamed, removed, or obsolete packages and restore custom builds manually.

APT restoration runs `sudo apt-get update` then `sudo apt-get install`. Names alone
do not preserve PPAs, third-party repositories, signing keys, pins, versions,
foreign-architecture enablement, holds, or local `.deb` files. Recreate those
prerequisites yourself. A package from one Debian/Ubuntu release may not exist in
another. Neither distro's lists are a lockfile or a cross-distro name translation.
Installations are not transactional; if a later step fails, earlier installs remain.

Stow restoration never adopts, deletes, or overwrites conflicting files. The preview
without `--apply` is a printed plan, not a conflict check; `--apply` performs the
simulation first. Only `configs.txt` is used, never a wildcard over repository
directories.

## Verification

```bash
bash packages/tests/test.sh
shellcheck utils/.config/pkgfiles/pkgfiles packages/tests/{test.sh,stow.sh,mock-command}
bash -n bash/bashfuncs.sh
bash -n utils/.config/pkgfiles/pkgfiles
for file in packages/tests/{test.sh,stow.sh,mock-command}; do bash -n "$file"; done
systemd-analyze --user verify packages/automation/pkgfiles-snapshot.{service,timer}
```

Tests use isolated fixtures under `/tmp/opencode`, mocked package managers, sudo,
AUR helpers, and Stow. Before adding mocks to PATH, the suite also runs real GNU
Stow when installed (otherwise prints a skip). These integration tests cover
preview, apply, repeated apply, conflict preservation, and manifest validation,
including comments, blank lines, and a final line without a newline. Both HOME and
the working directory are isolated so live `.stowrc` files are not loaded.
Tests do not install packages or change actual HOME symlinks.
Comparison tests cover both distros' reasons, filters, empty selections, six-column
TSV/table alignment, and invalid
options. Terminal paging tests use a mocked `less` and util-linux `script` when
available, including early quit and pager failure.

References: [pacman manual](https://man.archlinux.org/man/pacman.8.en),
[apt-mark manual](https://manpages.debian.org/stable/apt/apt-mark.8.en.html),
[systemd.timer manual](https://www.freedesktop.org/software/systemd/man/latest/systemd.timer.html).
