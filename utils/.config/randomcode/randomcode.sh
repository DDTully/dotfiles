#!/usr/bin/env bash
set -euo pipefail

# Name of the tmux session
SESSION="randomcode"
WORKDIR="$HOME/Sync/randomcode/"

# Commands
EDITOR_CMD="nvim"
BACKEND_CMD=""
FRONTEND_CMD=""

# If session exists, just attach
if tmux has-session -t "$SESSION" 2>/dev/null; then
  exec tmux attach -t "$SESSION"
fi

# Start new tmux session in detached mode, in WORKDIR
tmux new-session -d -s "$SESSION" -c "$WORKDIR"

# Window 1: main editor
tmux rename-window -t "$SESSION:1" 'editor'
tmux send-keys -t "$SESSION:1" "$EDITOR_CMD" C-m

# Window 2: servers (split first, then send commands)
tmux new-window -t "$SESSION:2" -n 'servers' -c "$WORKDIR"
tmux split-window -v -t "$SESSION:2" -c "$WORKDIR"
tmux send-keys -t "$SESSION:2.1" "clear && $BACKEND_CMD" C-m
tmux send-keys -t "$SESSION:2.2" "clear && $FRONTEND_CMD" C-m

# Window 3: working session
tmux new-window -t "$SESSION:3" -n 'working' -c "$WORKDIR"
tmux send-keys -t "$SESSION:3" "clear" C-m

# Make 'working' the active window on attach
tmux select-window -t "$SESSION:3"

# Attach to the session
tmux attach -t "$SESSION"
