# dotfiles

Personal Bash, terminal, editor, and utility configuration managed with **GNU Stow**.
The primary environment is Arch Linux (including CachyOS), Bash, and KDE on Wayland;
config-driven app installation also supports Debian/Ubuntu and their derivatives.

This is a working personal setup, not an unattended workstation installer. Stow
links configuration into your home directory; it does not install applications.
`pkgfiles` lists linked configs and installs their apps with apt or pacman/yay.
`pkgfiles devtools` installs user-owned Node (via NVM), Rust (via rustup), and
distro Go toolchains. Machine-specific paths need review before use.

## Navigation

- [Package Catalog](#package-catalog)
- [Before You Start](#before-you-start)
- [Safe Setup](#safe-setup)
- [Daily Use](#daily-use)
- [Configured Apps](#configured-apps)
- [Restore a Machine](#restore-a-machine)
- [Utilities](#utilities)
- [Backups and Portability](#backups-and-portability)
- [Troubleshooting](#troubleshooting)
- [Verification](#verification)

For selection, mapping rules, and package-manager behavior,
see the [configured apps guide](packages/README.md). Repository editing conventions
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
| [`herdr`](herdr/.config/herdr/config.toml) | `.config/herdr/config.toml` | Disable onboarding; sort agent panels by spaces. Arch install uses AUR/yay; APT availability depends on configured sources. |
| [`nvim`](nvim/.config/nvim/) | `.config/nvim/` | LazyVim via lazy.nvim, plugin overrides, Markdown/wiki tooling |
| [`starship`](starship/.config/starship.toml) | `.config/starship.toml` | Shell prompt configuration |
| [`tmux`](tmux/.tmux.conf) | `.tmux.conf` | Ctrl-Space prefix, pane/window bindings, Catppuccin, TPM plugins |
| [`utils`](utils/.config/) | `.config/{addskill,mp4thumb,music,netscan,pkgfiles,randomcode,tms-util}/` | Local scripts and the config-driven app installer |
| [`yazi`](yazi/.config/yazi/yazi.toml) | `.config/yazi/yazi.toml` | Show hidden files |
| [`skills`](skills/) | `.agent_skills/`, `.claude/skills/`, `.opencode/skills/`, `.agents/skills/` | Shared agent skill sources and client-facing links |

**`packages/` is not a Stow package.** It holds the config selection and mappings,
legacy inventory backups, documentation, and tests. Do not stow every top-level directory with
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
| `pkgfiles` | Bash 4.4+, GNU coreutils, apt-get/apt-cache or pacman; yay for apps only available in the AUR |
| Bash setup | `starship` is called at startup; `eza` backs `ls`/`lt`; search helpers use `fzf`, `rg` (ripgrep), `bat`, and `$EDITOR` |
| Neovim | A Neovim version compatible with current LazyVim, Git, and network access for plugin bootstrap; language tools depend on enabled plugins |
| tmux | A recent tmux supporting the configured terminal options, Git/network access for TPM bootstrap, and a font with the configured glyphs |
| Desktop helpers | KDE/Dolphin and Wayland-oriented tools where used; URI dispatch uses `xdg-open` |
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

For a fresh system, use [Restore a Machine](#restore-a-machine) to install apps from
the saved config selection before linking their configs.

### Clone and Inspect

```bash
git clone https://github.com/DDTully/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
git status --short
```

The examples below run from the repository root and always specify the target.
The checkout can live elsewhere, but `addskill` assumes `~/dotfiles`.
Review selected configs and back up conflicting HOME files
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

## Configured Apps

After sourcing `bash/bashfuncs.sh`:

```bash
pkgfiles                  # Show configs currently linked into this checkout
pkgfiles install          # Check availability and preview install commands
pkgfiles install --apply  # Install apps for those linked configs
```

The mapped apps are Bash, bat, Ghostty, Herdr, Neovim, Starship, tmux, and Yazi.
`utils` and `skills` are explicitly skipped during installation because they do not
correspond to single OS packages. Optional utility dependencies remain separate.
The report checks representative config links, including folded directory links;
copies and links to another checkout do not count. It does not inventory installed apps.

Arch uses configured pacman repositories first, then yay for AUR-only packages.
APT uses candidate versions from the current release's configured sources.
**Ghostty, Starship, and Yazi may be unavailable through APT on your release.**
Unresolved apps are reported before package installation; check sources or edit the
saved selection and use `--selected`. No third-party repositories are added.
See [package-manager details](packages/README.md#package-managers).

Runtime toolchains are independent of stowed configs:

```bash
pkgfiles devtools          # Preview NVM/latest Node, stable Rust, and distro Go setup
pkgfiles devtools --apply  # Install them; run as a normal user, never root
```

This installs NVM without touching shell profiles, then the latest Node release as
the default; installs rustup without touching `PATH` and selects stable Rust; and
installs Go from apt or pacman. `.bashrc` already sources NVM and Cargo when
present and adds `~/go/bin` to `PATH`, so open a new terminal after applying.

## Restore a Machine

Install Git and Stow, restore the checkout, and edit
[`packages/configs.txt`](packages/configs.txt) for the configs you want. This saved
selection works even before any HOME links exist:

```bash
bash utils/.config/pkgfiles/pkgfiles --selected
bash utils/.config/pkgfiles/pkgfiles install --selected
bash utils/.config/pkgfiles/pkgfiles install --selected --apply
bash utils/.config/pkgfiles/pkgfiles stow
bash utils/.config/pkgfiles/pkgfiles stow --apply
```

`--apply` retains package-manager prompts. Arch installs use a full system upgrade
(`pacman -Syu --needed`); APT apply refreshes metadata before checking candidates.
Install yay separately if an app needs the AUR. Stow apply simulates first and
only links if the simulation succeeds. Review personal paths and back up HOME
conflicts before linking.

`compare` and `restore` remain aliases for `list` and `install`, with the new
config-based scope. Old inventories are retained as unused backups. Snapshots and
the supplied timer units have been retired; `snapshot` is now a read-only no-op.
If you installed the old timer elsewhere, follow the
[retirement instructions](packages/README.md#retired-inventory-workflow).

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
`pacman -Sy`, unlike `pkgfiles install`'s full-upgrade workflow, so it is not the
recommended general Arch bootstrap path. Copies in `~/.local/bin` do not automatically
update when the source script changes.

## Backups and Portability

The repository and config selection are **not a complete machine backup**. Preserve these
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
| A selected config says `unlinked` | Check `readlink -f "$HOME/.config/nvim/init.lua"` (substitute the mapped probe). A plain copy or another checkout is not a link to this repository |
| `pkgfiles: command not found` | Source `bash/bashfuncs.sh`, or invoke `bash utils/.config/pkgfiles/pkgfiles ...` from the repo root; stowing `utils` alone does not define the function |
| Shell startup reports missing commands/files | Review Starship, `~/.cargo/env`, `~/bashfuncs.sh`, and the hard-coded `EDITOR`. Install intended dependencies or adapt the config before reloading |
| bat cannot find Catppuccin Mocha | After linking themes, run `bat cache --build` with the intended bat executable |
| tmux status numbers/icons are missing | Check the untracked custom-number helper, font glyph coverage, terminal capabilities, and TPM installation |
| Install cannot find a package | Check distro/release and configured sources. Edit configs.txt and use `--selected` to omit unavailable apps; install them separately if needed |
| No apps in scope on a fresh machine | Use `pkgfiles install --selected` to read configs.txt before HOME links exist |
| Utility is absent from PATH | Check the utility table: music uses an explicit path or separate installer, randomcode uses an installed Python entry point, and shell functions require sourcing |

## Verification

Run from the repository root. The package suite needs `/tmp/opencode` to exist:

```bash
mkdir -p /tmp/opencode
bash packages/tests/test.sh
```

The suite uses temporary repositories/HOMEs and mocked package managers and sudo.
It also runs **real GNU Stow in temporary directories** when installed, otherwise
reports a skip. Tests cover linked vs saved selections, package availability,
APT and pacman/yay routing, devtools previews and mocked installs for both
distros, failures, Stow conflicts, repeated apply, paths with
spaces, and input validation. No packages are installed and no live HOME links change.

Additional static checks, with ShellCheck installed:

```bash
bash -n bash/.bashrc
bash -n bash/bashfuncs.sh
bash -n utils/.config/pkgfiles/pkgfiles
for file in packages/tests/{test.sh,stow.sh,devtools.sh,mock-command,mock-devtools-installer}; do bash -n "$file"; done
shellcheck utils/.config/pkgfiles/pkgfiles packages/tests/{test.sh,stow.sh,devtools.sh,mock-command,mock-devtools-installer}
git diff --check
```

These checks validate the package tooling and syntax, not every application's
runtime configuration, external plugin, network service, or utility. Test selected
applications separately after reviewing startup side effects.

## Licensing

There is currently no repository-wide `LICENSE` file. Do not assume a blanket MIT
license for the collection; consult individual components and their upstream terms.
The Neovim starter includes its own [license](nvim/.config/nvim/LICENSE).
