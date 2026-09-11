# dotfiles

Personal dotfiles and configuration managed with GNU Stow. Targets Debian/Ubuntu and Arch Linux.

## Packages

The following directories are Stow packages that symlink into `$HOME`.
`packages/` holds reinstall inventories, documentation, and tests; do not stow it.

| Package    | Description                                                       |
| ---------- | ----------------------------------------------------------------- |
| `bash`     | Bash config, aliases, PATH setup                                  |
| `bat`      | `bat` (cat replacement) config                                    |
| `ghostty`  | Ghostty terminal emulator config                                  |
| `nvim`     | Neovim config                                                     |
| `starship` | Starship cross-shell prompt                                       |
| `tmux`     | tmux config                                                       |
| `utils`    | Utility scripts: `ns` (network scanner), `fzftunes`, `randomcode` |
| `yazi`     | Yazi terminal file manager config                                 |
| `skills`   | Agent skill definitions for Claude and OpenCode                   |

## Requirements

- GNU Stow
- Arch Linux or Debian/Ubuntu

```bash
# Arch
sudo pacman -S stow

# Debian/Ubuntu
sudo apt install stow
```

## Usage

```bash
git clone https://github.com/DDTully/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Symlink a package
stow -t $HOME bash
stow -t $HOME nvim

# Remove a package
stow -D -t $HOME bash

# Restow (recreate/update)
stow -R -t $HOME bash nvim tmux
```

## Package Inventory

`pkgfiles` compares installed packages with available configs and HOME link probes,
keeps distro-specific reinstall lists, and previews package/config restoration.
It is a Bash function in `bash/bashfuncs.sh`; it also works before anything is stowed:

```bash
bash utils/.config/pkgfiles/pkgfiles compare
```

After sourcing `~/bashfuncs.sh`, use:

```bash
pkgfiles                  # compare packages and config links
pkgfiles snapshot         # refresh this distro's tracked explicit-install lists
pkgfiles restore          # preview reinstall commands, no installs
pkgfiles stow             # preview only the selected config packages
```

See [packages/README.md](packages/README.md) for automatic updates, safe restoration,
mapping edits, and limitations.

## License

MIT — see [LICENSE](LICENSE)
