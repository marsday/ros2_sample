#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

source /opt/ros/jazzy/setup.bash
source "$WORKSPACE_DIR/install/setup.bash"

export ROS_LOG_DIR="$WORKSPACE_DIR/.ros/log"

mkdir -p "$ROS_LOG_DIR"
nohup "$WORKSPACE_DIR/install/publisher_node/lib/publisher_node/publisher_node" > "$ROS_LOG_DIR/publisher_node.out" 2>&1 &
echo $! > "$ROS_LOG_DIR/publisher_node.pid"
echo "publisher_node started (PID: $!)"
