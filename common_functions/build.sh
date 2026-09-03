#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

source /opt/ros/jazzy/setup.bash
cd "$WORKSPACE_DIR"

# 编译库 + 单元测试（显式开启 BUILD_TESTING）
colcon build --packages-select common_functions --cmake-args -DBUILD_TESTING=ON
