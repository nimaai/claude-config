#!/bin/bash

# Auto-detect tmux session
SESSION=$(tmux display-message -p '#S' 2>/dev/null || echo "")
WINDOW="2"
LINES="${1:-50}"

if [ -z "$SESSION" ]; then
  echo "ERROR: Not running in tmux session"
  exit 2
fi

tmux capture-pane -t "$SESSION:$WINDOW" -p -S -$LINES
