# Randomcode

A tool to manage tmux sessions for projects in `~/Sync/randomcode`.

## Installation

You can install this tool using `uv` to make the `randomcode` command available:

```bash
uv tool install .
```

Or run it directly from the directory:

```bash
uv run randomcode <directory>
```

## Shell Completion

To enable tab completion for directory names, source the provided completion script in your shell configuration (e.g., `~/.bashrc` or `~/.bash_profile`).

```bash
source /home/tully/dotfiles/utils/.config/randomcode/completion.bash
```

If you are using Zsh, you might need to enable bash completion support first or adapt the script.
