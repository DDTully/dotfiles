# AGENTS.md - Dotfiles Repository Guide

This repository manages personal dotfiles and development environment configurations using GNU Stow.

## Key Information

- **Structure**: Each top-level directory (`bash`, `bat`, `ghostty`, `nvim`, `starship`, `tmux`, `yazi`, `utils`) is a Stow package
- **Target**: Packages are designed to be symlinked into `$HOME`
- **OS Support**: Debian/Ubuntu and Arch Linux
- **Dependency**: GNU Stow must be installed

## Common Commands

### Install a package
```bash
stow -t $HOME <package-name>
# Example: stow -t $HOME nvim
```

### Remove a package
```bash
stow -D -t $HOME <package-name>
```

### Restow (recreate/update) packages
```bash
stow -R -t $HOME <package-name1> <package-name2>
# Example: stow -R -t $HOME bash nvim
```

### Work from repository root
When running stow from the repository root, you can omit `-t $HOME`:
```bash
stow <package-name>  # defaults to symlinking into $HOME
```

## Package Directories
- `bash`: Bash configuration
- `bat`: Cat clone with syntax highlighting
- `ghostty`: GPU-accelerated terminal emulator
- `nvim`: Neovim configuration
- `starship`: Cross-shell prompt
- `tmux`: Terminal multiplexer configuration
- `yazi`: Terminal file manager
- `utils`: Utility scripts and configurations

## Notes
- The repository assumes a home directory target (`$HOME`)
- Configuration files within each package directory maintain their relative paths when stowed
- Always inspect package contents before stowing to understand what will be linked