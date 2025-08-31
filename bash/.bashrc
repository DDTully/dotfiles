source ~/.local/share/omarchy/default/bash/rc

eval "$(starship init bash)"

export EDITOR=$(which nvim)
export PATH=/home/tully/.opencode/bin:$PATH
export PATH=/home/tully/.config/general:$PATH

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
. "$HOME/.local/share/../bin/env"

# Utility functions

# make and chdir, lazy
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# docker stop and remove with tab complete
dsrm() {
  if [ $# -eq 0 ]; then
    echo "Usage: dsrm <container_name_or_id> [more_containers...]"
    return 1
  fi

  for container in "$@"; do
    echo "Stopping container: $container..."
    docker stop "$container"

    echo "Removing container: $container..."
    docker rm "$container"
  done
}
_dsrm_completion() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=($(compgen -W "$(docker ps -a --format '{{.Names}}')" -- "$cur"))
}
complete -F _dsrm_completion dsrm

# Aliases
alias yt='~/Sync/randomcode/ytmusic_search/ytmusic'
alias pact='source .venv/bin/activate'
alias dact='deactivate'
