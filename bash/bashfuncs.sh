pkgfiles() {
  : "List linked configs or install their apps with apt or pacman/yay."
  local helper
  helper=$(readlink -f -- "${BASH_SOURCE[0]}") || return
  helper="${helper%/bash/bashfuncs.sh}/utils/.config/pkgfiles/pkgfiles"
  bash "$helper" "$@"
}

shipit() {
  : "Stage changes, commit with the supplied message, then push."
  if [[ $# -ne 1 || -z $1 ]]; then
    printf 'Usage: shipit "commit message"\n' >&2
    return 1
  fi

  git add . &&
    git commit -m "$1" &&
    git push
}

mkcd() {
  : "Create a directory and enter it."
  mkdir -p "$1" && cd "$1"
}
dcrm() {
  : "Stop and remove the named Docker containers."
  if [ $# -eq 0 ]; then
    printf 'Usage: dcrm <container_name_or_id> [more_containers...]\n' >&2
    return 1
  fi
  for container in "$@"; do
    printf 'Stopping container: %s...\n' "$container" >&2
    docker stop "$container"
    printf 'Removing container: %s...\n' "$container" >&2
    docker rm "$container"
  done
}
dcsh() {
  : "Open a shell or run a command in a Docker container."
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
      if [[ $# -lt 2 || "$2" == "--" || "$2" == -* ]]; then
        printf 'dcsh: --user requires a value\n' >&2
        return 2
      fi
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
      printf 'dcsh: unknown option: %s\n' "$1" >&2
      return 2
      ;;
    *)
      if [[ -n "$container" ]]; then
        printf 'dcsh: unexpected argument: %s\n' "$1" >&2
        return 2
      fi
      container="$1"
      shift
      ;;
    esac
  done

  if [[ -z "$container" ]]; then
    printf 'Usage: dcsh [-a|--all] [-u USER] <container> [-- [command ...]]\n' >&2
    return 1
  fi

  if ((all)); then
    if ! docker ps --format '{{.Names}}' | grep -qx "$container"; then
      if docker ps -a --format '{{.Names}}' | grep -qx "$container"; then
        printf 'Starting container: %s...\n' "$container" >&2
        docker start "$container" >/dev/null || return $?
      else
        printf 'dcsh: container not found: %s\n' "$container" >&2
        return 1
      fi
    fi
  else
    if ! docker ps --format '{{.Names}}' | grep -qx "$container"; then
      printf 'dcsh: container is not running: %s (use -a to start it)\n' "$container" >&2
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
  : "Print Docker container names, all of them when the argument is all."
  if [[ "$1" == "all" ]]; then
    docker ps -a --format '{{.Names}}'
  else
    docker ps --format '{{.Names}}'
  fi
}

__dock_user_list() {
  : "Print user names defined inside a container."
  local container="$1"
  docker exec "$container" sh -lc '
    (command -v getent >/dev/null 2>&1 && getent passwd) || cat /etc/passwd 2>/dev/null
  ' 2>/dev/null | awk -F: '{print $1}'
}

__reply_matching() {
  : "Set COMPREPLY from stdin lines that start with the given prefix."
  local prefix=$1 line
  COMPREPLY=()
  while IFS= read -r line; do
    [[ -n $line && $line == "$prefix"* ]] && COMPREPLY+=("$line")
  done
}

__complete_dcrm() {
  : "Complete dcrm with every container name."
  local cur
  cur="${COMP_WORDS[COMP_CWORD]}"
  __reply_matching "$cur" < <(__dock_names all)
}

__complete_dcsh() {
  : "Complete dcsh options, container names, and container users."
  local cur prev words want_all=0 container=""
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
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
      __reply_matching "$cur" < <(__dock_user_list "$container")
    else
      COMPREPLY=()
    fi
    return 0
  fi

  if [[ -z "$container" || "$cur" == "$container" ]]; then
    local scope="running"
    ((want_all)) && scope="all"
    __reply_matching "$cur" < <(__dock_names "$scope")
    return 0
  fi

  __reply_matching "$cur" < <(printf '%s\n' -a --all -u --user -h --help --)
}
_randomcode_completion() {
  : "Complete randomcode with directory names under ~/Sync/randomcode."
  local cur search_dir
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  search_dir="$HOME/Sync/randomcode"

  if [[ -d "$search_dir" ]]; then
    # Run compgen inside the target directory to get relative folder names
    # Use a subshell so we don't actually change the user's directory
    mapfile -t COMPREPLY < <(cd "$search_dir" && compgen -d -- "$cur")
  fi
}

frg() {
  : "Live-search the Git root with ripgrep, fzf, and bat."
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

  (
    cd "$root" || exit

    fzf --ansi --disabled --no-mouse --query "" \
      --bind "change:reload:
          rg --line-number --no-heading --color=always \
             --smart-case \
             --hidden \
             --glob '!.git/*' \
             {q} || true" \
      --delimiter : \
      --preview 'bat --style=numbers --color=always --highlight-line {2} {1} 2>/dev/null' \
      --preview-window=right:60%:wrap:+{2}/2 \
      --bind "enter:execute($EDITOR +{2} {1})"
  )
}
cheat() {
  : "Fetch a cheat.sh page and open a selected line in the editor."
  if [[ -z "$1" ]]; then
    printf 'Usage: cheat <command>\n' >&2
    return 1
  fi

  local tmp selection line status
  tmp="$(mktemp)" || return 1

  if ! curl -fsSL "https://cheat.sh/$1?T" -o "$tmp"; then
    printf 'Error: Failed to fetch cheat.sh/%s\n' "$1" >&2
    rm -f "$tmp"
    return 1
  fi

  selection=$(
    awk '{printf "%d:%s\n", NR, $0}' "$tmp" |
      fzf --ansi --no-mouse --delimiter=':' \
        --preview "bat --style=numbers --color=always --highlight-line {1} --paging=never $tmp" \
        --preview-window='right:60%:+{1}/2'
  ) || {
    rm -f "$tmp"
    return 0
  }

  line="${selection%%:*}"
  "$EDITOR" +"$line" "$tmp"
  status=$?
  rm -f "$tmp"
  return $status
}

update() {
  : "Upgrade the system with apt or pacman."
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update &&
      sudo apt-get full-upgrade -y &&
      sudo apt-get autoremove -y
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Syu
  else
    printf 'Unsupported Linux distribution.\n' >&2
    return 1
  fi
}

complete -F _randomcode_completion randomcode
complete -F __complete_dcrm dcrm
complete -F __complete_dcsh dcsh
