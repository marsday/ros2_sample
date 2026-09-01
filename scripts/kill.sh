#!/bin/bash
INSTALL_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# WORKSPACE_DIR="$(dirname "$INSTALL_SCRIPT_DIR")"
WORKSPACE_DIR="$(cd "$(dirname "$INSTALL_SCRIPT_DIR")/.." && pwd)"

# echo "Killing publisher_node..."
# bash "$WORKSPACE_DIR/publisher_node/kill.sh"

# echo "Killing subscriber_node..."
# bash "$WORKSPACE_DIR/subscriber_node/kill.sh"
for kill_script in "$INSTALL_SCRIPT_DIR"/*/kill.sh; do
  [ -f "$kill_script" ] || continue

  # 取 start.sh 所在子目录名（即节点名，如 publisher_node）
  pkg_name="$(basename "$(dirname "$kill_script")")"

  # 跳过 scripts 目录，避免递归执行自身
  [ "$pkg_name" = "scripts" ] && continue

  echo "Killing ${pkg_name}..."
  bash "$kill_script"
done

echo "========== All nodes killed =========="
