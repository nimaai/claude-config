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

  # Using Python bencode (fast)
  python3 -c "
import socket
import sys
import re

port = $PORT
code = '(do (require \'clj-reload.core) (clj-reload.core/reload))'
msg = f'd2:op4:eval4:code{len(code)}:{code}e'

try:
    s = socket.socket()
    s.settimeout(5)
    s.connect(('localhost', port))
    s.send(msg.encode())

    # Read all responses until done
    responses = []
    while True:
        try:
            chunk = s.recv(8192).decode('utf-8', errors='ignore')
            if not chunk:
                break
            responses.append(chunk)
            if 'status' in chunk and 'done' in chunk:
                break
        except:
            break
    s.close()

    full_resp = ''.join(responses)

    # Look for error/exception in response
    if 'error' in full_resp or 'Exception' in full_resp or 'Error' in full_resp:
        print('RELOAD ERRORS:', full_resp)
        sys.exit(2)

    # Extract value if present (bencode format: 5:valueNN:content)
    value_match = re.search(r'5:value(\d+):', full_resp)
    if value_match:
        length = int(value_match.group(1))
        start = value_match.end()
        value = full_resp[start:start+length]
        print('Reload result:', value)
    else:
        print('Reload OK')

except Exception as e:
    print(f'Connection error: {e}')
    sys.exit(2)
" 2>&1 || exit 2
fi
