# README.md

# dotfiles

Personal dotfiles and configuration for setting up a development environment.

This repository is intended for Linux systems and is organized to be managed with GNU Stow. Each top-level directory is treated as a "package" that stow will symlink into your home directory.

## What’s included

Below are the packages (directories) included in this repository:

- bash
- bat
- ghostty
- hypr
- nvim
- omarchy
- starship
- tmux
- yazi

Each directory contains configuration files or scripts for a specific tool.

## Requirements

- Supported Operating Systems:
  - Debian / Ubuntu
  - Arch Linux
- GNU Stow

Install GNU Stow:

- Debian / Ubuntu:
  ```bash
  sudo apt update && sudo apt install -y stow
  ```
- Arch:
  ```bash
  sudo pacman -Syu stow
  ```

## Installation (using GNU Stow)

1. Clone this repository:
   ```bash
   git clone https://github.com/DDTully/dotfiles.git
   ```
2. Change into the repository directory:
   ```bash
   cd dotfiles
   ```
3. Inspect the package directories listed above.
4. Use stow to symlink a package into your home directory. Examples:
   ```bash
   stow -t $HOME bash
   stow -t $HOME nvim
   ```
   To remove symlinks created by a package:
   ```bash
   stow -D -t $HOME bash
   ```
   To restow (recreate/update) packages:
   ```bash
   stow -R -t $HOME bash nvim
   ```

Note: You can omit `-t $HOME` if you run `stow` from the repo root and want the default target to be your home directory.

## Contributing

PRs and improvements are welcome. Open an issue to discuss larger changes.

## License

This repository is licensed under the MIT License. See the LICENSE file.

## Contact

DDTully — https://github.com/DDTully

# LICENSE

MIT License

Copyright (c) 2025 DDTully

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
