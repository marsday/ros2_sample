#!/bin/bash
set -e
INSTALL_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$INSTALL_SCRIPT_DIR")/../.."

nohup "$WORKSPACE_DIR/install/subscriber_node/lib/subscriber_node/subscriber_node" > "$ROS_LOG_DIR/subscriber_node.out" 2>&1 &
echo $! > "$ROS_LOG_DIR/subscriber_node.pid"
echo "subscriber_node started (PID: $!)"
