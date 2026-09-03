#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

# 是否在编译后自动执行单元测试（1=执行，0=跳过）
ENABLE_UT=1  # 默认值
while getopts "e:" opt; do
  case $opt in
    e) ENABLE_UT="$OPTARG" ;;
  esac
done
echo "ENABLE_UT=$ENABLE_UT"

mkdir -p "${WORKSPACE_DIR}/install/scripts"

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

BUILD_FAILED=0

# 1) 先按依赖顺序构建基础包
for pkg in "${PRIORITY_PKGS[@]}"; do
  [ -f "$WORKSPACE_DIR/$pkg/build.sh" ] || continue
  echo "========== Building ${pkg} =========="
  if ! bash "$WORKSPACE_DIR/$pkg/build.sh"; then
    echo "[build] 编译失败: ${pkg}"
    BUILD_FAILED=1
  fi
done

# 基础包已安装，加载工作区 install 环境，供后续包 find_package 找到依赖
if [ -f "${WORKSPACE_DIR}/install/setup.bash" ]; then
  source "${WORKSPACE_DIR}/install/setup.bash"
fi

# 2) 再构建其余自动发现的包（跳过已在优先级列表中构建过的）
for pkg in "${packages[@]}"; do
  skip=false
  for p in "${PRIORITY_PKGS[@]}"; do
    [ "$pkg" = "$p" ] && skip=true && break
  done
  $skip && continue

  echo "========== Building ${pkg} =========="
  if ! bash "$WORKSPACE_DIR/$pkg/build.sh"; then
    echo "[build] 编译失败: ${pkg}"
    BUILD_FAILED=1
  fi
done

if [ "$BUILD_FAILED" = "1" ]; then
  echo "========== 编译失败，跳过后续步骤 =========="
  exit 1
fi

echo "========== Build all done =========="

cp -f "${SCRIPT_DIR}/start.sh" "${WORKSPACE_DIR}/install/scripts/"
cp -f "${SCRIPT_DIR}/kill.sh" "${WORKSPACE_DIR}/install/scripts/"

# 编译后自动执行 UT（可用 ENABLE_UT=0 跳过）
if [ "${ENABLE_UT}" = "1" ]; then
  echo "========== Running UT =========="
  source "${WORKSPACE_DIR}/install/setup.bash" 2>/dev/null || true
  if ! colcon test; then
    colcon test-result --verbose
    echo "========== UT failed =========="
    exit 2
  fi
  colcon test-result --verbose
  echo "========== UT passed =========="
else
  echo "========== Skip UT (ENABLE_UT=${ENABLE_UT}) =========="
fi

echo "========== All done =========="
exit 0
