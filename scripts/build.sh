#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

mkdir -p ${WORKSPACE_DIR}/install/scripts

source /opt/ros/jazzy/setup.bash

cd "$WORKSPACE_DIR"

# 基础依赖包需优先构建（被其他包 depend，必须先生成）
PRIORITY_PKGS=(sample_msgs common_functions protobuf_msg)

# 自动收集工作区下所有含 build.sh 的包目录，排除特殊目录
packages=()
for dir in "$WORKSPACE_DIR"/*/; do
  name="$(basename "$dir")"
  case "$name" in
    scripts|install|build|log) continue ;;
    .*) continue ;;
  esac
  [ -f "${dir}build.sh" ] && packages+=("$name")
done

# 1) 先按依赖顺序构建基础包
for pkg in "${PRIORITY_PKGS[@]}"; do
  [ -f "$WORKSPACE_DIR/$pkg/build.sh" ] || continue
  echo "========== Building ${pkg} =========="
  bash "$WORKSPACE_DIR/$pkg/build.sh"
done

# 2) 再构建其余自动发现的包（跳过已在优先级列表中构建过的）
for pkg in "${packages[@]}"; do
  skip=false
  for p in "${PRIORITY_PKGS[@]}"; do
    [ "$pkg" = "$p" ] && skip=true && break
  done
  $skip && continue

  echo "========== Building ${pkg} =========="
  bash "$WORKSPACE_DIR/$pkg/build.sh"
done

echo "========== Build all done =========="

cp -f ${SCRIPT_DIR}/start.sh ${WORKSPACE_DIR}/install/scripts/
cp -f ${SCRIPT_DIR}/kill.sh ${WORKSPACE_DIR}/install/scripts/
