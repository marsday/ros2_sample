#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

colcon build --packages-select publisher_node

PACKAGE_NAME="$(basename "$SCRIPT_DIR")"
mkdir -p ${WORKSPACE_DIR}/install/scripts/${PACKAGE_NAME}
cp -f ${SCRIPT_DIR}/start.sh ${WORKSPACE_DIR}/install/scripts/${PACKAGE_NAME}/
cp -f ${SCRIPT_DIR}/kill.sh ${WORKSPACE_DIR}/install/scripts/${PACKAGE_NAME}/
