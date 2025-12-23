#!/bin/bash
set -e

# Auto-detect tmux session (assumes claude code runs in same session)
SESSION=$(tmux display-message -p '#S' 2>/dev/null || echo "")
WINDOW="2"
PROJECT_DIR="$PWD"  # Use current directory (where .nrepl-port is)

if [ -z "$SESSION" ]; then
  echo "ERROR: Not running in tmux session"
  exit 2
fi

# Check if backend is running
if [ ! -f "$PROJECT_DIR/.nrepl-port" ]; then
  echo "Backend not running - starting in tmux window $WINDOW..."

  # Send start command to tmux window
  tmux send-keys -t "$SESSION:$WINDOW" C-c 2>/dev/null || true
  sleep 0.5
  tmux send-keys -t "$SESSION:$WINDOW" "cd $PROJECT_DIR && bin/dev-run-backend" Enter

  # Wait for backend to start (check for .nrepl-port)
  for i in {1..20}; do
    if [ -f "$PROJECT_DIR/.nrepl-port" ]; then
      echo "Backend started"
      break
    fi
    sleep 0.5
  done

  if [ ! -f "$PROJECT_DIR/.nrepl-port" ]; then
    echo "ERROR: Backend failed to start"
    exit 2
  fi
else
  echo "Backend running - sending reload..."
  PORT=$(cat "$PROJECT_DIR/.nrepl-port")

  # Use nrepl-eval script
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  "$SCRIPT_DIR/nrepl-eval.py" "$PORT" "(do (require 'clj-reload.core) (clj-reload.core/reload))" || exit 2
fi
