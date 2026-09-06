#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$(dirname "$SCRIPT_DIR")" && pwd)"

source /opt/ros/jazzy/setup.bash

# 自动收集工作区下所有含 ut_run.sh 的包目录，排除特殊目录
packages=()
for dir in "$WORKSPACE_DIR"/*/; do
  name="$(basename "$dir")"
  case "$name" in
    scripts|install|build|log) continue ;;
    .*) continue ;;
  esac
  [ -f "${dir}ut_run.sh" ] && packages+=("$name")
done

# 逐个执行各模块的单元测试，失败记录后继续，最后统一返回
UT_FAILED=0
for pkg in "${packages[@]}"; do
  echo "========== Running UT ${pkg} =========="
  if ! bash "$WORKSPACE_DIR/$pkg/ut_run.sh"; then
    echo "[ut] UT 失败: ${pkg}"
    UT_FAILED=1
  fi
done

if [ "$UT_FAILED" = "1" ]; then
  echo "========== UT failed =========="
  exit 2
fi

echo "========== UT passed =========="
exit 0
