#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

source /opt/ros/jazzy/setup.bash
source "${WORKSPACE_DIR}/install/setup.bash" 2>/dev/null || true
cd "$WORKSPACE_DIR"

# 运行单元测试，失败时仍打印结果详情
if ! colcon test --packages-select common_functions; then
  colcon test-result --verbose || true
  exit 2
fi
colcon test-result --verbose
