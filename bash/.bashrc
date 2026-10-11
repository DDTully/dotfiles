export BROWSER="google-chrome-stable"
export EDITOR="nvim"

# Each assignment prepends, so later lines are searched first.
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.config/general:$PATH"
export PATH="$HOME/.config/randomcode:$PATH"
export PATH="$HOME/.config/netscan:$PATH"
export PATH="$HOME/.config/mp4thumb:$PATH"
export PATH="$HOME/.config/addskill:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/Steam/steamapps/common/Blender:$PATH"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
[ -s "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
[ -s "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
export PATH="$HOME/go/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
[[ -r "$HOME/.grok/completions/bash/grok.bash" ]] && source "$HOME/.grok/completions/bash/grok.bash"
# <<< grok installer <<<

source "$HOME/bashfuncs.sh"

alias ls="eza --long --git"
alias lt="eza --long --git --tree --level 99"
alias bcwd='nautilus --new-window . >/dev/null 2>&1 & disown'
alias ff='f() { rg -l -uu -i -F --no-messages "$*" | fzf --preview "bat --style=numbers --color=always {}" --bind "enter:execute($EDITOR {} )"; }; f'

alias ga='git add .'
alias gcam='git commit -a -m'

alias dccu="docker compose up -d "
alias dps="docker ps"

alias pact='source .venv/bin/activate'
alias dact='deactivate'
alias testme='uv run pytest --cov=src'

alias bunx="bun x"
alias yt='~/Sync/randomcode/ytmusic_search/ytmusic'
alias reload='exec $SHELL -l'

eval "$(starship init bash)"
