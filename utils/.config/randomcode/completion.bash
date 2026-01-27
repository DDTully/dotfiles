#!/bin/bash

_randomcode_completion() {
    local cur search_dir
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    search_dir="$HOME/Sync/randomcode"

    if [[ -d "$search_dir" ]]; then
        # Run compgen inside the target directory to get relative folder names
        # Use a subshell so we don't actually change the user's directory
        local matches
        matches=$(cd "$search_dir" && compgen -d -- "$cur")
        
        # Populate COMPREPLY with the results
        COMPREPLY=( $matches )
    fi
}

complete -F _randomcode_completion randomcode
