#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
PID_FILE="$WORKSPACE_DIR/.ros/log/subscriber_node.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        echo "subscriber_node killed (PID: $PID)"
    else
        echo "subscriber_node process not running (PID: $PID)"
    fi
    rm -f "$PID_FILE"
else
    echo "No PID file found, trying pkill"
    pkill -f "install/subscriber_node/lib/subscriber_node/subscriber_node" 2>/dev/null && echo "subscriber_node killed" || echo "subscriber_node not running"
fi
