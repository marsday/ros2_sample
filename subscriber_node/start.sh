#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

source /opt/ros/jazzy/setup.bash
source "$WORKSPACE_DIR/install/setup.bash"

export ROS_LOG_DIR="$WORKSPACE_DIR/.ros/log"

mkdir -p "$ROS_LOG_DIR"
nohup "$WORKSPACE_DIR/install/subscriber_node/lib/subscriber_node/subscriber_node" > "$ROS_LOG_DIR/subscriber_node.out" 2>&1 &
echo $! > "$ROS_LOG_DIR/subscriber_node.pid"
echo "subscriber_node started (PID: $!)"
