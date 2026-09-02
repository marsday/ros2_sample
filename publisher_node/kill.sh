#!/bin/bash
INSTALL_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"  && pwd)"
WORKSPACE_DIR="$(dirname "$INSTALL_SCRIPT_DIR")/../.."
PID_FILE="$WORKSPACE_DIR/.ros/log/publisher_node.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        echo "publisher_node killed (PID: $PID)"
    else
        echo "publisher_node process not running (PID: $PID)"
    fi
    rm -f "$PID_FILE"
else
    echo "No PID file found, trying pkill ${PID_FILE}"
    pkill -f "install/publisher_node/lib/publisher_node/publisher_node" 2>/dev/null && echo "publisher_node killed" || echo "publisher_node not running"
fi
