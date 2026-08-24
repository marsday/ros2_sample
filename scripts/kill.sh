#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

echo "Killing publisher_node..."
bash "$WORKSPACE_DIR/publisher_node/kill.sh"

echo "Killing subscriber_node..."
bash "$WORKSPACE_DIR/subscriber_node/kill.sh"

echo "========== All nodes killed =========="
