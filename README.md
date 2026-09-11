# dotfiles

Personal Bash, terminal, editor, and utility configuration managed with **GNU Stow**.
The primary environment is Arch Linux (including CachyOS), Bash, and KDE on Wayland;
package inventory and restore also support Debian/Ubuntu and their derivatives.

This is a working personal setup, not an unattended workstation installer. Stow
links configuration into your home directory; it does not install applications.
`pkgfiles` separately compares installed packages and config links, saves package
inventories, and previews restoration. Machine-specific paths need review before use.

## Navigation

- [Package Catalog](#package-catalog)
- [Before You Start](#before-you-start)
- [Safe Setup](#safe-setup)
- [Daily Use](#daily-use)
- [Package Inventory](#package-inventory)
- [Restore a Machine](#restore-a-machine)
- [Automatic Snapshots](#automatic-snapshots)
- [Utilities](#utilities)
- [Backups and Portability](#backups-and-portability)
- [Troubleshooting](#troubleshooting)
- [Verification](#verification)

For manifest formats, mapping rules, failure behavior, and implementation details,
see the [package inventory guide](packages/README.md). Repository editing conventions
are in [AGENTS.md](AGENTS.md).

## Package Catalog

Each package contains paths relative to `$HOME`. For example,
`nvim/.config/nvim/init.lua` becomes `~/.config/nvim/init.lua`. Stow may link a whole
directory rather than each file individually; both layouts are normal.

| Stow Package | Main Paths Under `$HOME` | Contents |
| --- | --- | --- |
| [`bash`](bash/) | `.bashrc`, `bashfuncs.sh` | Starship initialization, PATH, aliases, shell functions, completions |
| [`bat`](bat/.config/bat/) | `.config/bat/` | Catppuccin Mocha default and four Catppuccin theme files |
| [`ghostty`](ghostty/.config/ghostty/) | `.config/ghostty/` | Catppuccin Mocha, padding, clipboard and font-size bindings |
| [`nvim`](nvim/.config/nvim/) | `.config/nvim/` | LazyVim via lazy.nvim, plugin overrides, Markdown/wiki tooling |
| [`starship`](starship/.config/starship.toml) | `.config/starship.toml` | Shell prompt configuration |
| [`tmux`](tmux/.tmux.conf) | `.tmux.conf` | Ctrl-Space prefix, pane/window bindings, Catppuccin, TPM plugins |
| [`utils`](utils/.config/) | `.config/{addskill,mp4thumb,music,netscan,pkgfiles,randomcode,tms-util}/` | Local scripts and the package inventory helper |
| [`yazi`](yazi/.config/yazi/yazi.toml) | `.config/yazi/yazi.toml` | Show hidden files |
| [`skills`](skills/) | `.agent_skills/`, `.claude/skills/`, `.opencode/skills/`, `.agents/skills/` | Shared agent skill sources and client-facing links |

**`packages/` is not a Stow package.** It holds inventories, config mappings, optional
systemd units, documentation, and tests. Do not stow every top-level directory with
a wildcard. The deliberate selection in [`packages/configs.txt`](packages/configs.txt)
currently includes all packages above except `skills`.

Edit skill content only under [`skills/.agent_skills/`](skills/.agent_skills/), not
through the client-facing links. Some Claude skill links reference external content
not included in this checkout; stowing `skills` is not a guarantee that every skill
target is present.

## Before You Start

### Dependencies

Install Git and GNU Stow for checkout/link management. Choose the command for your
distribution, not both:

```bash
# Arch: upgrade with the install rather than refreshing databases alone.
sudo pacman -Syu --needed git stow

# Debian/Ubuntu:
sudo apt-get update
sudo apt-get install git stow
```

Additional requirements depend on what you select:

| Feature | Requirements and Caveats |
| --- | --- |
| `pkgfiles` | Bash 4.4+, GNU coreutils, the matching distro package manager; `flock` from util-linux for snapshots; optional `less` for paging |
| Bash setup | `starship` is called at startup; `eza` backs `ls`/`lt`; search helpers use `fzf`, `rg` (ripgrep), `bat`, and `$EDITOR` |
| Neovim | A Neovim version compatible with current LazyVim, Git, and network access for plugin bootstrap; language tools depend on enabled plugins |
| tmux | A recent tmux supporting the configured terminal options, Git/network access for TPM bootstrap, and a font with the configured glyphs |
| Desktop helpers | KDE/Dolphin and Wayland-oriented tools where used; URI dispatch uses `xdg-open` |
| Automatic inventories | A running systemd user manager; entirely optional |
| Utilities | Separate dependencies listed [below](#utilities); stowing does not install them |

Package names and binary names can differ by distribution. For example, Debian
installations may expose `batcat` and `fdfind`, while these scripts call `bat` and
`fd`. Check the actual commands available and adapt the configuration deliberately.

### Personal Assumptions

Review [`bash/.bashrc`](bash/.bashrc) before replacing your shell configuration:

- `EDITOR` points to `/opt/nvim-linux-x86_64/bin/nvim`, not simply `nvim` on PATH.
- `BROWSER` is `google-chrome-stable`; aliases reference Dolphin, AppImage wrappers,
  PiKaraoke, Docker, Bun, and a script under `~/Sync/randomcode/ytmusic_search/`.
- Startup unconditionally initializes Starship, sources `~/bashfuncs.sh`, and sources
  `~/.cargo/env`. Missing Starship or Rust environment files can produce errors.
- PATH includes `/usr/lib`, a Steam Blender directory, and local tool directories.
  Review both the directories and their ordering for your machine.
- Optional envman, local environment, and NVM files are sourced when present but
  are not supplied by this repository.
- Neovim's wiki paths point to `~/Sync/work/wiki` and `~/Sync/personal/wiki`.
- tmux references `~/.tmux/custom_number.sh`, which is not tracked here. Supply that
  helper or simplify the window formats before expecting the full status display.

Loading Neovim or tmux for the first time can download plugins. Neither application's
startup should be treated as an offline, read-only configuration check.

## Safe Setup

If you are rebuilding from saved package inventories, use [Restore a Machine](#restore-a-machine)
first. **Do not snapshot or enable the timer on a fresh system before restoring:**
that would replace your saved package list with the fresh system's inventory.

### Clone and Inspect

```bash
git clone https://github.com/DDTully/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
git status --short
```

The examples below run from the repository root and always specify the target.
The checkout can live elsewhere, but `addskill` and the supplied snapshot service
assume `~/dotfiles`. Review selected configs and back up conflicting HOME files
outside this repository before proceeding.

### Preview, Then Link

Start with only the packages you want. This example selects bat and Yazi:

```bash
stow --simulate --verbose --target="$HOME" bat yazi
stow --verbose --target="$HOME" bat yazi
```

Run the second command only after the simulation is clean. Once Bash's dependencies
and personal paths are addressed, a shell setup could be:

```bash
stow --simulate --verbose --target="$HOME" bash starship utils
stow --verbose --target="$HOME" bash starship utils
source "$HOME/.bashrc"
```

Stow does not merge an existing `.bashrc` or `.config/nvim` with the repository.
On a conflict, compare and back up the existing content, move only the conflicting
path aside deliberately, then simulate again. **Do not use `--adopt` blindly:** it
moves existing target content into the package tree and can change tracked files.
Do not run Stow with `sudo` for these HOME configurations.

### Relink or Remove

```bash
stow --simulate --verbose --restow --target="$HOME" bash nvim tmux
stow --verbose --restow --target="$HOME" bash nvim tmux

stow --simulate --verbose --delete --target="$HOME" yazi
stow --verbose --delete --target="$HOME" yazi
```

Restow is useful after adding/removing config paths. Unstowing removes managed
links, not the repository's source files, and does not uninstall the application or
restore files you previously moved aside. Keep the checkout in place while links
point into it.

## Daily Use

Edits made through correctly stowed paths edit repository content. Review changes
before staging, especially after an application writes its own configuration:

```bash
git status --short
git diff
git diff --cached
```

To load just the Bash functions without running the entire shell startup file:

```bash
# Before stowing, from the repository root:
source bash/bashfuncs.sh

# After stowing bash:
source "$HOME/bashfuncs.sh"
```

`pkgfiles` resolves its helper relative to the real source of `bashfuncs.sh`, including
through the HOME symlink; it needs no new PATH entry. A full `.bashrc` reload is
needed for changed aliases or environment settings. The `reload` alias starts a
new login shell via `exec $SHELL -l`; its startup behavior also depends on your login
profile, which this repository does not supply.

| Function or Alias | Behavior |
| --- | --- |
| `mkcd directory` | Create a directory and enter it |
| `frg` | Live ripgrep search from the Git root (or current directory), with fzf/bat preview and editor jump |
| `ff text` | Search file contents, choose a matching file, and open it in `$EDITOR` |
| `cheat command` | Fetch a cheat.sh reference, select a line with fzf, and open a temporary copy in `$EDITOR` |
| `dcsh container` | Open Bash or sh in a running Docker container; `-a` allows starting a stopped container, `-u USER` selects a user |
| `dcrm container ...` | Stop and remove named Docker containers; this is destructive, not a preview |
| `pact` / `dact` | Activate `.venv/bin/activate` in the current directory / deactivate it |
| `update` | APT update, full upgrade, and autoremove with `-y`, or `pacman -Syu`; inspect before using |
| `shipit "message"` | Run `git add .`, commit, then push, stopping on failure |

**`shipit` is not selective staging.** `git add .` stages changes under the current
directory, and the commit includes **all already-staged changes across the repository**,
including unrelated work. Inspect both the worktree and index first, or use explicit
file staging and separate commit/push commands instead.

In tmux, the prefix is **Ctrl-Space**, not Ctrl-B. Prefix + `v` splits side by side,
`s` splits top/bottom, `w` opens the tree, and `r` reloads the config. Ghostty leaves
Ctrl-Shift-Left/Right unbound for tmux window navigation; F11 toggles fullscreen.

## Package Inventory

The helper can run before anything is stowed:

```bash
bash utils/.config/pkgfiles/pkgfiles help
bash utils/.config/pkgfiles/pkgfiles compare
```

After sourcing the functions, the full command interface is:

```text
pkgfiles [compare] [--installed] [--configured] [--explicit|--dependencies] [--no-pager] [--tsv|--table]
pkgfiles snapshot|help
pkgfiles restore|stow [--apply]
```

| Command | Effect |
| --- | --- |
| `pkgfiles` or `pkgfiles compare` | Read-only comparison of installed packages and mapped config probes |
| `pkgfiles snapshot` | Replace this distro's saved explicit/manual package lists with current inventory |
| `pkgfiles restore` | Print shell-escaped package installation commands; execute nothing |
| `pkgfiles restore --apply` | Install packages, keeping package-manager prompts |
| `pkgfiles stow` | Print the Stow command for `packages/configs.txt`; not a conflict check |
| `pkgfiles stow --apply` | Run a real Stow simulation first, then link only if it succeeds |

No command commits or pushes. Reports/plans go to stdout, status/errors to stderr.
Comparison and snapshots detect the distro from `/etc/os-release` (`ID`/`ID_LIKE`),
not whichever package-manager executable happens to appear first.

### Read the Report

Columns are `PACKAGE`, `INSTALLED`, `REASON`, `CONFIG`, `REPO`, and `HOME PROBE`.

- `REASON` is `explicit`/`dependency` on Arch, `manual`/`auto` on APT, or `-` if
  absent. This is queried live, not read from saved manifests.
- `available` means the representative config exists in this checkout.
- `linked` means its HOME path resolves to that exact repository config. A regular
  copy, a link to another checkout, or a missing/broken link is not equivalent.
- `no mapping` is normal for packages without an entry in
  [`config-map.tsv`](packages/config-map.tsv); it does not mean they need config.

These are representative probes, **not an audit of every file**. `utils` and `skills`
are not automatically compared as OS applications. Mappings, installed packages,
and the desired Stow selection in `configs.txt` are three separate things.

| Filter | Selects |
| --- | --- |
| `--installed` | Installed packages, including dependencies |
| `--configured` | Mapped configs available in the repository, whether linked or installed or not |
| `--explicit` | Installed explicit/manual packages, not necessarily applications |
| `--dependencies` | Installed dependency/auto packages |

Filters combine with **AND**. The two reason filters are mutually exclusive and
imply `--installed`. Filter/display flags apply only to comparisons.

```bash
pkgfiles --explicit --configured
pkgfiles --dependencies --no-pager
pkgfiles compare --configured --tsv > configs.tsv
pkgfiles compare --table > package-report.txt
```

Terminal stdout defaults to an aligned ASCII table. With both stdin and stdout
attached to a terminal, `less -FRSX` pages it if installed: `q` quits, and horizontal
scrolling reveals long lines. `--no-pager` disables paging; `PAGER` is not evaluated.
Pipes/redirections default to raw TSV with a header and no pager. `--tsv` forces TSV
and disables paging; `--table` forces a table. They cannot be combined. Empty results
still include a header.

### Saved Inventories

| File | Snapshot Source |
| --- | --- |
| [`arch-native.txt`](packages/arch-native.txt) | `pacman -Qqen`: explicit packages in configured sync databases |
| [`arch-foreign.txt`](packages/arch-foreign.txt) | `pacman -Qqem`: explicit foreign packages, including AUR and local builds |
| [`apt-manual.txt`](packages/apt-manual.txt) | `apt-mark showmanual`, intersected with installed dpkg packages |
| [`configs.txt`](packages/configs.txt) | Hand-maintained Stow selection; never generated by snapshot |

The Arch lists were captured on CachyOS and include distribution-specific packages.
The APT list is currently a commented placeholder, not a captured Debian workstation.
These are package names, not version locks or a cross-distro translation.

Snapshot updates only the current distro's inventories. Removed packages disappear
on the next snapshot; dependencies are omitted unless marked explicit/manual.
Unchanged files are not rewritten. Queries are gathered and validated before files
are replaced, concurrent snapshots are locked, and each changed file is replaced
atomically. The two Arch files are not an atomic pair in a power failure.

Lists are per-distro, **not per-host**. Multiple same-distro machines writing a synced
checkout will replace each other's inventory. Use separate copies or a deliberate
host-specific workflow. See the [manifest guide](packages/README.md#manifests) for
validation rules and `PKGFILES_REPO`, `PKGFILES_DISTRO`, and AUR-helper overrides.

## Restore a Machine

### 1. Preserve the Source Inventory

On the old system, finish package transactions, run `pkgfiles snapshot`, review
`git diff -- packages/`, and back up the checkout and manifests. Preserve user data
and credentials separately. A local snapshot is not automatically committed or
copied off the machine.

If automatic snapshots are already enabled, stop them **before replacing manifests
with saved/edited desired lists**:

```bash
systemctl --user disable --now pkgfiles-snapshot.timer
systemctl --user stop pkgfiles-snapshot.service
```

Do not run `snapshot` on the destination until package restoration is complete.

### 2. Prepare the Destination

Clone or restore the checkout on the matching distro family. Keep the timer disabled.
Review the package lists for the destination release, configure required repositories
and signing keys, and install Git/Stow as needed.

Arch native restore uses `sudo pacman -Syu --needed` to avoid partial upgrades.
Foreign restore uses `paru` if found, otherwise `yay`; select explicitly with
`PKGFILES_AUR_HELPER=yay` or `paru`. Bootstrap the helper separately as a normal user.
With foreign entries, apply checks for the helper and rejects root execution before
native installs. Foreign packages may be local-only, removed, or renamed, not available
from the AUR. Review them and recover custom builds separately.

APT restore runs `sudo apt-get update` and `sudo apt-get install`. Recreate any
third-party repositories, signing keys, pins, foreign architectures, and other package
source settings yourself. Do not apply the CachyOS list blindly to stock Arch or
assume an old Debian/Ubuntu package name still exists in a newer release.

### 3. Preview and Install Packages

From the repository root:

```bash
bash utils/.config/pkgfiles/pkgfiles restore
```

After reviewing the printed commands and prerequisites, deliberately apply:

```bash
bash utils/.config/pkgfiles/pkgfiles restore --apply
```

Run as your normal user; the helper invokes sudo where needed. Installs are not
transactional: if a later step fails, earlier successful installs remain. A preview
does not prove package availability. Do not set a mismatched `PKGFILES_DISTRO` when
applying; that override is useful for testing or previewing another distro only.

### 4. Restore Configuration

Review `packages/configs.txt`, omit unwanted/unavailable applications, adjust personal
paths, and back up existing HOME conflicts. Then:

```bash
bash utils/.config/pkgfiles/pkgfiles stow
bash utils/.config/pkgfiles/pkgfiles stow --apply
```

The first command only prints a plan. The second simulates before linking and will
not adopt or overwrite conflicting files. Only `configs.txt` is selected, never a
wildcard; this does not install the snapshot timer.

### 5. Confirm and Resume Tracking

Run the comparison, check the apps you selected, and only then take a fresh snapshot:

```bash
bash utils/.config/pkgfiles/pkgfiles compare --configured --no-pager
bash utils/.config/pkgfiles/pkgfiles snapshot
git diff -- packages/
```

Enable automatic tracking only after the restored inventory is the state you want
to preserve. The [detailed reinstall guide](packages/README.md#reinstall-workflow)
describes additional package-manager limitations.

## Automatic Snapshots

The optional **unprivileged systemd user timer** refreshes inventories about once a
minute while your user manager runs. It observes package-manager state, including
GUI installs/removals and explicit/manual marking changes; there are no root hooks
or shell-command interception. Nothing enables it automatically.

On the original system after an initial snapshot, or after destination restoration
is complete, run from the repository root:

```bash
mkdir -p "$HOME/.config/systemd/user"
cp packages/automation/pkgfiles-snapshot.{service,timer} "$HOME/.config/systemd/user/"
systemctl --user daemon-reload
systemctl --user enable --now pkgfiles-snapshot.timer
systemctl --user status pkgfiles-snapshot.timer
journalctl --user -u pkgfiles-snapshot.service
```

Inspect/back up any existing units before copying. The service uses
`/usr/bin/bash %h/dotfiles/utils/.config/pkgfiles/pkgfiles snapshot`. For a different
checkout location, edit the installed service's `ExecStart` before reloading/enabling;
see [path quoting rules](packages/README.md#automatic-updates). Do not use `sudo`.
These units are copied, not stowed: later repository changes require deliberately
updating the installed copies and running `daemon-reload` again.

To pause tracking, disable the timer and stop any active snapshot service:

```bash
systemctl --user disable --now pkgfiles-snapshot.timer
systemctl --user stop pkgfiles-snapshot.service
```

To resume with already-installed units after restoration, use
`systemctl --user enable --now pkgfiles-snapshot.timer`.

This is eventual refresh, not an immediate transaction hook. A query during a package
transaction can observe an intermediate state; a later tick converges. Failed queries
preserve saved inventories and retry on the next tick. Run a manual snapshot after
transactions finish and before backup. Without systemd, use manual snapshots; there
is no automatic fallback.

## Utilities

Stowing `utils` makes its files available under `~/.config`; sourcing the supplied
`.bashrc` adds several utility directories to PATH. `pkgfiles` is a function, the
music directory is **not** added to PATH, and `randomcode` needs its Python entry
point installed separately.

| Tool | Actual Interface and Behavior | Requirements / Cautions |
| --- | --- | --- |
| [`ns`](utils/.config/netscan/ns) | `ns`, `ns --verbose`, `ns --help`; detects the default-route network, scans hosts, offers an fzf connection menu | `nmap`, `fzf`, `ipcalc`, GNU `parallel`, `ip`; connection tools depend on selected service. Scan only networks you are authorized to scan |
| [`mp4thumb`](utils/.config/mp4thumb/mp4thumb) | `mp4thumb`, `mp4thumb --help`; interactively chooses an MP4 and writes its first frame as a neighboring PNG | `ffmpeg`, `fzf`, `fd`, `chafa`, `kitten`; this is a file-writing operation |
| [`fzftunes`](utils/.config/music/fzftunes) | `bash utils/.config/music/fzftunes "search terms"`; YouTube search and MPD playback; also `controls`, `pause`, `resume`, `toggle`, `stop`, `next`, `prev`, `status`, `queue`, `queue-menu`, `relabel-queue`, `clear` | `yt-dlp`, `fzf`, `mpc`, running MPD; use `--help` for search settings and queue keys |
| [`randomcode`](utils/.config/randomcode/) | `randomcode project-name`; creates/focuses a herdr workspace for a single folder under `~/Sync/randomcode`, creating the folder if absent | Python 3.12+, herdr, and the expected shell/editor setup; [installation notes](utils/.config/randomcode/README.md) |
| [`tms`](utils/.config/tms-util/tms) | `tms --no-install`; interactive NEW/ATTACH/KILL/RELOAD CONFIG herdr workspace menu | herdr, `jq`, `fzf`; expects the herdr environment, `pact`, Neovim, and OpenCode. Without `--no-install`, may offer a privileged copy to `/usr/bin/tms` |
| [`addskill`](utils/.config/addskill/addskill) | `addskill /path/to/skill`; copies a directory into `~/dotfiles/skills/.agent_skills` and creates all three client links | Hard-coded checkout location; **replaces existing same-name source and client paths**. Back up and review first; restow `skills` if needed |

Despite their names/history, `tms` and `randomcode` currently manage **herdr**, not
tmux sessions. Their generated workspace commands assume project virtual environments
and the supplied Bash aliases.

The separate [`install-fzftunes`](utils/.config/music/install-fzftunes) script is a
mutating installer: it installs dependencies, configures MPD, attempts to enable its
user service, and copies `fzftunes` to `~/.local/bin`. `--force-config` overwrites an
existing MPD config. Inspect before running; its Arch branch currently uses
`pacman -Sy`, unlike `pkgfiles restore`'s full-upgrade workflow, so it is not the
recommended general Arch bootstrap path. Copies in `~/.local/bin` do not automatically
update when the source script changes.

## Backups and Portability

The repository plus manifests are **not a complete machine backup**. Preserve these
separately, using storage appropriate for sensitive data:

- Documents, projects, media, wiki directories, databases, and application state.
- SSH/GPG keys, API tokens, passwords, `.env` files, and service credentials. Never
  stage secrets merely because a file lives under a Stow-linked directory.
- Package repository definitions, signing keys, pins, holds, local build sources,
  local `.deb` files, and any versions required for reproduction.
- Manually downloaded binaries, AppImages, Flatpaks, Cargo tools, pip/uv environments,
  npm/Bun tools, and applications under `/opt`; `pkgfiles` does not inventory them.
- Untracked helpers such as `~/.tmux/custom_number.sh`, shell startup/profile files
  outside the catalog, and externally installed agent skill targets.

The root [`.gitignore`](.gitignore) excludes `.env`, `lazy-lock.json`, and `*.conf.bak*`;
it is not a comprehensive secret filter. In particular, the usual Neovim lockfile is
ignored, so a fresh plugin bootstrap is not guaranteed to reproduce exact revisions.
Review `git status`, unstaged changes, and staged changes before every commit.

## Troubleshooting

| Symptom | What to Check |
| --- | --- |
| Stow reports a conflict | Compare the specific existing target with the source, back it up, and move only that target aside deliberately. Retry simulation; do not delete entire config directories or adopt blindly |
| Config says `available` but `unlinked` | Check `readlink -f "$HOME/.config/nvim/init.lua"` (substitute the reported probe). A plain copy or another checkout is not a link to this repository |
| `pkgfiles: command not found` | Source `bash/bashfuncs.sh`, or invoke `bash utils/.config/pkgfiles/pkgfiles ...` from the repo root; stowing `utils` alone does not define the function |
| Shell startup reports missing commands/files | Review Starship, `~/.cargo/env`, `~/bashfuncs.sh`, and the hard-coded `EDITOR`. Install intended dependencies or adapt the config before reloading |
| bat cannot find Catppuccin Mocha | After linking themes, run `bat cache --build` with the intended bat executable |
| tmux status numbers/icons are missing | Check the untracked custom-number helper, font glyph coverage, terminal capabilities, and TPM installation |
| Restore cannot find a package | Check distro/release, configured repositories and keys, renamed/removed packages, and foreign/local builds. Review the desired list rather than forcing unrelated removals or repositories |
| Saved inventory suddenly shrank | Check whether a snapshot/timer ran on a minimal or different same-distro host. Stop writers before recovering the desired list from a backup or Git history |
| Timer does not update lists | Check `systemctl --user status pkgfiles-snapshot.timer` and the service journal, the checkout path in `ExecStart`, and whether the user manager is running |
| Utility is absent from PATH | Check the utility table: music uses an explicit path or separate installer, randomcode uses an installed Python entry point, and shell functions require sourcing |

## Verification

Run from the repository root. The package suite needs `/tmp/opencode` to exist:

```bash
mkdir -p /tmp/opencode
bash packages/tests/test.sh
```

The suite uses temporary repositories/HOMEs and mocked package managers, sudo, AUR
helpers, and Stow. It also runs **real GNU Stow in temporary directories** when
installed, otherwise reports a skip. Integration coverage includes preview, apply,
repeat apply, conflict preservation, paths with spaces, and manifest validation.
Comparison tests cover both distro families, install reasons, filters, TSV/table
formatting, and errors. Pager tests use a mocked `less` and util-linux `script` when
available. No packages are installed and no live HOME links are changed.

Additional static checks, with ShellCheck and systemd tools installed:

```bash
bash -n bash/.bashrc
bash -n bash/bashfuncs.sh
bash -n utils/.config/pkgfiles/pkgfiles
for file in packages/tests/{test.sh,stow.sh,mock-command}; do bash -n "$file"; done
shellcheck utils/.config/pkgfiles/pkgfiles packages/tests/{test.sh,stow.sh,mock-command}
systemd-analyze --user verify packages/automation/pkgfiles-snapshot.{service,timer}
git diff --check
```

These checks validate the package tooling and syntax, not every application's
runtime configuration, external plugin, network service, or utility. Test selected
applications separately after reviewing startup side effects.

## Licensing

There is currently no repository-wide `LICENSE` file. Do not assume a blanket MIT
license for the collection; consult individual components and their upstream terms.
The Neovim starter includes its own [license](nvim/.config/nvim/LICENSE).
