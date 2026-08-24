#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

source /opt/ros/jazzy/setup.bash
source "$WORKSPACE_DIR/install/setup.bash"
cd "$WORKSPACE_DIR"
colcon build --packages-select subscriber_node
