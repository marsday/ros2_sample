#!/bin/bash
set -e
INSTALL_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# WORKSPACE_DIR="$(dirname "$INSTALL_SCRIPT_DIR")"
WORKSPACE_DIR="$(cd "$(dirname "$INSTALL_SCRIPT_DIR")/.." && pwd)"

echo "---INSTALL_SCRIPT_DIR $INSTALL_SCRIPT_DIR WORKSPACE_DIR $WORKSPACE_DIR----"
source /opt/ros/jazzy/setup.bash
source "$WORKSPACE_DIR/install/setup.bash"

export ROS_LOG_DIR="$WORKSPACE_DIR/.ros/log"
mkdir -p "$ROS_LOG_DIR"

# 自动遍历工作区下各子目录中的 start.sh 并启动
for start_script in "$INSTALL_SCRIPT_DIR"/*/start.sh; do
  [ -f "$start_script" ] || continue

  # 取 start.sh 所在子目录名（即节点名，如 publisher_node）
  pkg_name="$(basename "$(dirname "$start_script")")"

  # 跳过 scripts 目录，避免递归执行自身
  [ "$pkg_name" = "scripts" ] && continue

  echo "Starting ${pkg_name}..."
  bash "$start_script"
done

echo "========== All nodes started =========="
