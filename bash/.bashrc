source ~/.local/share/omarchy/default/bash/rc

eval "$(starship init bash)"

export EDITOR=$(which nvim)
export PATH=/home/tully/.opencode/bin:$PATH
export PATH=/home/tully/.config/general:$PATH
export PATH=/home/tully/.config/teller:$PATH
export PATH=/home/tully/.config/randomcode:$PATH

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
. "$HOME/.local/share/../bin/env"

# Utility functions

# make and chdir, lazy
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Docker stuff
alias dccu="docker compose up -d "
alias dps="docker ps"
dcrm() {
  if [ $# -eq 0 ]; then
    echo "Usage: dcrm <container_name_or_id> [more_containers...]"
    return 1
  fi
  for container in "$@"; do
    echo "Stopping container: $container..."
    docker stop "$container"
    echo "Removing container: $container..."
    docker rm "$container"
  done
}

# shell into a container (bash → sh fallback, supports -a/-u/-- etc.)
dcsh() {
  local all=0
  local user=""
  local container=""
  local shell_cmd=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
    -a | --all)
      all=1
      shift
      ;;
    -u | --user)
      user="$2"
      shift 2
      ;;
    -h | --help)
      cat <<'EOF'
Usage:
  dcsh [-a|--all] [-u USER] <container> [-- [command ...]]

Examples:
  dcsh web                         # open bash or sh
  dcsh -u root db                  # open as root
  dcsh api -- python -V            # run a specific command
  dcsh -a sleepy                   # start then shell into a stopped container
EOF
      return 0
      ;;
    --)
      shift
      shell_cmd="$*"
      break
      ;;
    -*)
      echo "dcsh: unknown option: $1" >&2
      return 2
      ;;
    *)
      container="$1"
      shift
      ;;
    esac
  done

  if [[ -z "$container" ]]; then
    echo "Usage: dcsh [-a|--all] [-u USER] <container> [-- [command ...]]" >&2
    return 1
  fi

  if ((all)); then
    if ! docker ps --format '{{.Names}}' | grep -qx "$container"; then
      if docker ps -a --format '{{.Names}}' | grep -qx "$container"; then
        echo "Starting container: $container..."
        docker start "$container" >/dev/null || return $?
      else
        echo "dcsh: container not found: $container" >&2
        return 1
      fi
    fi
  else
    if ! docker ps --format '{{.Names}}' | grep -qx "$container"; then
      echo "dcsh: container is not running: $container (use -a to start it)" >&2
      return 1
    fi
  fi

  if [[ -n "$shell_cmd" ]]; then
    if [[ -n "$user" ]]; then
      docker exec -it --user "$user" "$container" sh -c "$shell_cmd"
    else
      docker exec -it "$container" sh -c "$shell_cmd"
    fi
    return $?
  fi

  if [[ -n "$user" ]]; then
    docker exec -it --user "$user" "$container" /bin/bash 2>/dev/null ||
      docker exec -it --user "$user" "$container" /bin/sh
  else
    docker exec -it "$container" /bin/bash 2>/dev/null ||
      docker exec -it "$container" /bin/sh
  fi
}

__dock_names() {
  if [[ "$1" == "all" ]]; then
    docker ps -a --format '{{.Names}}'
  else
    docker ps --format '{{.Names}}'
  fi
}

__dock_user_list() {
  local container="$1"
  docker exec "$container" sh -lc '
    (command -v getent >/dev/null 2>&1 && getent passwd) || cat /etc/passwd 2>/dev/null
  ' 2>/dev/null | awk -F: '{print $1}'
}

__complete_dcrm() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=($(compgen -W "$(__dock_names all)" -- "$cur"))
}

__complete_dcsh() {
  local cur prev words want_all=0 container=""
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"
  words="${COMP_WORDS[*]}"

  for w in ${words}; do
    [[ "$w" == "--" ]] && {
      COMPREPLY=()
      return 0
    }
  done

  for w in ${words}; do
    [[ "$w" == "-a" || "$w" == "--all" ]] && want_all=1
  done

  local i=1
  while [[ $i -lt ${#COMP_WORDS[@]} ]]; do
    local tok="${COMP_WORDS[$i]}"
    case "$tok" in
    -a | --all | -h | --help | --) : ;;
    -u | --user) ((i++)) ;;
    -*) : ;;
    *)
      container="$tok"
      break
      ;;
    esac
    ((i++))
  done

  if [[ "$prev" == "-u" || "$prev" == "--user" ]]; then
    if [[ -n "$container" ]]; then
      COMPREPLY=($(compgen -W "$(__dock_user_list "$container")" -- "$cur"))
    else
      COMPREPLY=()
    fi
    return 0
  fi

  if [[ -z "$container" || "$cur" == "$container" ]]; then
    local scope="running"
    ((want_all)) && scope="all"
    COMPREPLY=($(compgen -W "$(__dock_names "$scope")" -- "$cur"))
    return 0
  fi

  local opts="-a --all -u --user -h --help --"
  COMPREPLY=($(compgen -W "$opts" -- "$cur"))
}

# Wire completions
complete -F __complete_dcrm dcrm
complete -F __complete_dcsh dcsh

csvup() {
  local api_base="http://127.0.0.1:8000"
  if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: csvup <file.csv> [table]" >&2
    return 2
  fi
  local file="$1"
  local table="${2:-default}"
  if [[ ! -f "$file" ]]; then
    echo "csvup: file not found: $file" >&2
    return 1
  fi
  curl -fsS -H "Accept: application/json" -X POST \
    -F "file=@${file}" "${api_base}/tables/${table}/data" |
    (command -v jq >/dev/null 2>&1 && jq . || cat)
}

csvupraw() {
  local api_base="http://127.0.0.1:8000"
  if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: csvupraw <file.csv> [table]" >&2
    return 2
  fi
  local file="$1"
  local table="${2:-default}"
  if [[ ! -f "$file" ]]; then
    echo "csvupraw: file not found: $file" >&2
    return 1
  fi
  curl -fsS -H "Content-Type: text/csv" -H "Accept: application/json" \
    --data-binary @"${file}" "${api_base}/tables/${table}/data/raw" |
    (command -v jq >/dev/null 2>&1 && jq . || cat)
}

csvupjson() {
  local api_base="http://127.0.0.1:8000"
  if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: csvupjson <file.csv> [table]" >&2
    return 2
  fi
  local file="$1"
  local table="${2:-default}"
  if [[ ! -f "$file" ]]; then
    echo "csvupjson: file not found: $file" >&2
    return 1
  fi
  curl -fsS -H "Content-Type: application/json" -H "Accept: application/json" \
    --data-binary @"${file}" "${api_base}/tables/${table}/data/json" |
    (command -v jq >/dev/null 2>&1 && jq . || cat)
}

# Aliases
alias yt='~/Sync/randomcode/ytmusic_search/ytmusic'
alias pact='source .venv/bin/activate'
alias dact='deactivate'
alias ga='git add .'
alias reload='exec $SHELL -l'
