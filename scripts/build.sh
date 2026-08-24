#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

echo "========== [1/4] Building sample_msgs =========="
bash "$WORKSPACE_DIR/sample_msgs/build.sh"

echo "========== [2/4] Building common_functions =========="
bash "$WORKSPACE_DIR/common_functions/build.sh"

echo "========== [3/4] Building publisher_node =========="
bash "$WORKSPACE_DIR/publisher_node/build.sh"

echo "========== [4/4] Building subscriber_node =========="
bash "$WORKSPACE_DIR/subscriber_node/build.sh"

echo "========== Build all done =========="
