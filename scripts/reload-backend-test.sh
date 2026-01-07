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

# Get test DB name from env or use default
DB_NAME_TEST="${DB_NAME_TEST:-leihs_test}"

echo "Starting backend with DB_NAME=$DB_NAME_TEST..."

# Stop backend if running
tmux send-keys -t "$SESSION:$WINDOW" C-c 2>/dev/null || true
sleep 0.5

# Remove old .nrepl-port
rm -f "$PROJECT_DIR/.nrepl-port"

# Start backend with test DB
tmux send-keys -t "$SESSION:$WINDOW" "cd $PROJECT_DIR && DB_NAME=$DB_NAME_TEST bin/dev-run-backend" Enter

# Wait for backend to start (check for .nrepl-port)
for i in {1..20}; do
  if [ -f "$PROJECT_DIR/.nrepl-port" ]; then
    echo "Backend started with test DB: $DB_NAME_TEST"
    exit 0
  fi
  sleep 0.5
done

echo "ERROR: Backend failed to start"
exit 2
