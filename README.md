# dotfiles

Personal dotfiles and configuration managed with GNU Stow. Targets Debian/Ubuntu and Arch Linux.

## Packages

Each top-level directory is a Stow package that symlinks into `$HOME`:

| Package   | Description                                      |
|-----------|--------------------------------------------------|
| `bash`    | Bash config, aliases, PATH setup                 |
| `bat`     | `bat` (cat replacement) config                   |
| `ghostty` | Ghostty terminal emulator config                 |
| `nvim`    | Neovim config                                    |
| `starship`| Starship cross-shell prompt                      |
| `tmux`    | tmux config                                      |
| `utils`   | Utility scripts: `ns` (network scanner), `fzftunes`, `randomcode` |
| `yazi`    | Yazi terminal file manager config                |

`skills/` contains agent skill definitions for Claude and OpenCode — not a Stow package.

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

## License

MIT — see [LICENSE](LICENSE)
