eval "$(starship init bash)"
export BROWSER="google-chrome-stable"
export PATH=$HOME/.opencode/bin:$PATH
export PATH=$HOME/.config/general:$PATH
export PATH=$HOME/.config/randomcode:$PATH
export PATH=$HOME/.config/netscan:$PATH
export PATH=$HOME/.config/mp4thumb:$PATH
export PATH=$HOME/.config/tms-util:$PATH
export PATH=$HOME/.config/addskill:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=/usr/lib:$PATH

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
. "$HOME/.local/share/../bin/env"
export EDITOR="/opt/nvim-linux-x86_64/bin/nvim"

# Utility functions
source ~/bashfuncs.sh

# Aliases
alias ls="eza --long --git"
alias lt="eza --long --git --tree --level 99"
alias bunx="bun x"
alias dccu="docker compose up -d "
alias dps="docker ps"
alias yt='~/Sync/randomcode/ytmusic_search/ytmusic'
alias pact='source .venv/bin/activate'
alias dact='deactivate'
alias ga='git add .'
alias gcam='git commit -a -m'
alias reload='exec $SHELL -l'
alias bcwd='dolphin --new-window . >/dev/null 2>&1 & disown'
alias obsidian='obsidian_appimage >/dev/null 2>&1 & disown'
alias openshot='openshot_appimage >/dev/null 2>&1 & disown'
alias ff='f() { rg -l -uu -i -F --no-messages "$*" | fzf --preview "bat --style=numbers --color=always {}" --bind "enter:execute($EDITOR {} )"; }; f'
. "$HOME/.cargo/env"
alias testme='uv run pytest --cov=src'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
