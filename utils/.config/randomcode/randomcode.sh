#!/usr/bin/env bash
set -euo pipefail

# Check for directory argument
if [ $# -eq 0 ]; then
  echo "Usage: $0 <directory_name>"
  exit 1
fi

DIR="$1"
WORKDIR="$HOME/Sync/randomcode/$DIR"

# Create directory if it doesn't exist
if [ ! -d "$WORKDIR" ]; then
  mkdir -p "$WORKDIR"
fi

# Name of the tmux session
SESSION="Randomcode - $DIR"

# Commands
EDITOR_CMD="nvim"
BACKEND_CMD="clear"
FRONTEND_CMD="clear"

# If session exists, just attach
if tmux has-session -t "$SESSION" 2>/dev/null; then
  exec tmux attach -t "$SESSION"
fi

# Start new tmux session in detached mode, in WORKDIR
tmux new-session -d -s "$SESSION" -c "$WORKDIR"

# Window 1: main editor
tmux rename-window -t "$SESSION:1" 'editor'
tmux send-keys -t "$SESSION:1" "pact; $EDITOR_CMD; clear" C-m

# Window 2: servers (split first, then send commands)
tmux new-window -t "$SESSION:2" -n 'servers' -c "$WORKDIR"
tmux split-window -v -t "$SESSION:2" -c "$WORKDIR"
tmux send-keys -t "$SESSION:2.1" "pact; clear; $BACKEND_CMD" C-m
tmux send-keys -t "$SESSION:2.2" "pact; clear; $FRONTEND_CMD" C-m

# Window 3: opencode/codex
tmux new-window -t "$SESSION:3" -n 'agent' -c "$WORKDIR"
tmux send-keys -t "$SESSION:3" "pact; clear" C-m

# Window 3: working session
tmux new-window -t "$SESSION:4" -n 'working' -c "$WORKDIR"
tmux send-keys -t "$SESSION:4" "pact; clear" C-m

# Make 'working' the active window on attach
tmux select-window -t "$SESSION:4"

# Attach to the session
tmux attach -t "$SESSION"
