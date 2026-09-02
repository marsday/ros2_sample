#!/bin/bash
set -e
INSTALL_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$INSTALL_SCRIPT_DIR")/../.."

echo "===WORKSPACE_DIR: $WORKSPACE_DIR"
nohup "$WORKSPACE_DIR/install/publisher_node/lib/publisher_node/publisher_node" > "$ROS_LOG_DIR/publisher_node.out" 2>&1 &
echo $! > "$ROS_LOG_DIR/publisher_node.pid"
echo "publisher_node started (PID: $!)"
