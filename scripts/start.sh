#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

echo "Starting publisher_node..."
bash "$WORKSPACE_DIR/publisher_node/start.sh"

echo "Starting subscriber_node..."
bash "$WORKSPACE_DIR/subscriber_node/start.sh"

echo "========== All nodes started =========="
