#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

mkdir -p ${WORKSPACE_DIR}/install/scripts

source /opt/ros/jazzy/setup.bash
source "$WORKSPACE_DIR/install/setup.bash"
cd "$WORKSPACE_DIR"

echo "========== [1/5] Building sample_msgs =========="
bash "$WORKSPACE_DIR/sample_msgs/build.sh"

echo "========== [2/5] Building common_functions =========="
bash "$WORKSPACE_DIR/common_functions/build.sh"

echo "========== [3/5] Building protobuf_msg =========="
bash "$WORKSPACE_DIR/protobuf_msg/build.sh"

echo "========== [4/5] Building publisher_node =========="
bash "$WORKSPACE_DIR/publisher_node/build.sh"

echo "========== [5/5] Building subscriber_node =========="
bash "$WORKSPACE_DIR/subscriber_node/build.sh"

echo "========== Build all done =========="

cp -f ${SCRIPT_DIR}/start.sh ${WORKSPACE_DIR}/install/scripts/
cp -f ${SCRIPT_DIR}/kill.sh ${WORKSPACE_DIR}/install/scripts/
