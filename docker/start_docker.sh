#!/usr/bin/env bash
IMAGE="my_ros2_dev:0.04"
CONTAINER="$(whoami)_ros2_dev"
TOP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


# 采集当前用户/组信息，输出 "user uid group gid"
collect_host_identity() {
  local user="${CUSTOM_USER-$USER}"
  local uid="${CUSTOM_UID-$(id -u)}"
  local group="${CUSTOM_GROUP-$(id -g -n)}"
  local gid="${CUSTOM_GID-$(id -g)}"
  printf '%s %s %s %s\n' "${user}" "${uid}" "${group}" "${gid}"
}

# 启动容器并完成用户映射
# 参数: <镜像> <容器名> [额外 docker run 参数...]
start_container_with_user() {
  # local image="$1"; shift
  # local container="$1"; shift
  local image="${IMAGE}"
  local container="${CONTAINER}"

  read -r user uid group gid <<< "$(collect_host_identity)"

  # 1. 启动容器（root），注入用户信息环境变量
  docker run -d \
    --init \
    --name "${container}" \
    --hostname "$(hostname)_in_docker" \
    -v "${TOP_DIR}:/workspace" \
    -w /workspace \
    -e DOCKER_USER="${user}" \
    -e USER="${user}" \
    -e DOCKER_USER_ID="${uid}" \
    -e DOCKER_GRP="${group}" \
    -e DOCKER_GRP_ID="${gid}" \
    "$@" \
    "${image}" sleep infinity

  # 2. 容器启动后，以 root 触发容器内用户创建脚本（非 root 才需要）
  if [[ "${user}" != "root" ]]; then
    docker exec -u root "${container}" \
      bash -c '/workspace/docker/start_docker.sh create_container_user'
  fi
}

# 以映射用户登录容器
enter_container_as_user() {
  local container="${CONTAINER}"
  local user="${CUSTOM_USER-$USER}"
  docker exec -u "${user}" -it "${container}" /bin/bash
}

# 主流程：确保容器存在且运行，最后进入容器
main() {
  local container="${CONTAINER}"
  local image="${IMAGE}"

  # 容器不存在 → 创建并启动
  if [ -z "$(docker ps -a -q -f "name=^/${container}$")" ]; then
    echo "[start_docker] 容器 ${container} 不存在，开始创建并启动..."
    start_container_with_user
  else
    # 检查容器使用的镜像版本是否与期望一致
    local current_image
    current_image="$(docker inspect -f '{{.Config.Image}}' "${container}" 2>/dev/null)"

    if [ "${current_image}" != "${image}" ]; then
      # 镜像版本不一致 → 删除旧容器并重建
      echo "[start_docker] 容器 ${container} 使用镜像 ${current_image}，与期望 ${image} 不一致，重建容器..."
      docker rm -f "${container}"
      start_container_with_user
    elif [ -z "$(docker ps -q -f "name=^/${container}$")" ]; then
      # 镜像一致但未运行 → 启动
      echo "[start_docker] 容器 ${container} 已存在但未运行，开始启动..."
      docker start "${container}"
    else
      echo "[start_docker] 容器 ${container} 已在运行。"
    fi
  fi

  enter_container_as_user
}

# ============================ 容器内侧 ============================

# 读取宿主机注入的环境变量，若用户在容器内不存在则创建
create_container_user() {
  local user_name="${DOCKER_USER:-$USER}"
  local uid="${DOCKER_USER_ID:-$(id -u)}"
  local group_name="${DOCKER_GRP:-$user_name}"
  local gid="${DOCKER_GRP_ID:-${uid}}"

  if grep -q "^${user_name}:" /etc/passwd; then
    echo "[docker_user_mapping] User '${user_name}' already exists, skip."
    return 0
  fi

  _create_user_account "${user_name}" "${uid}" "${group_name}" "${gid}"
  _setup_user_home "${user_name}" "${uid}" "${gid}"
  _grant_extra_groups "${user_name}"
  echo "[docker_user_mapping] User '${user_name}' (uid=${uid}, gid=${gid}) created."
}

_create_user_account() {
  local user_name="$1"; local uid="$2"
  local group_name="$3"; local gid="$4"

  # 组处理：同名存在则跳过；GID 被占用则改名复用；否则新建
  if getent group "${group_name}" >/dev/null; then
    echo "[docker_user_mapping] Group '${group_name}' already exists, skip."
  elif getent group "${gid}" >/dev/null; then
    local old_group
    old_group="$(getent group "${gid}" | cut -d: -f1)"
    groupmod -n "${group_name}" "${old_group}"
    echo "[docker_user_mapping] Renamed group '${old_group}' -> '${group_name}' (gid=${gid})."
  else
    addgroup --gid "${gid}" "${group_name}"
  fi

  # 用户处理：同名存在则跳过；UID 被占用则改名复用；否则新建
  if getent passwd "${user_name}" >/dev/null; then
    echo "[docker_user_mapping] User '${user_name}' already exists, skip."
  elif getent passwd "${uid}" >/dev/null; then
    local old_user
    old_user="$(getent passwd "${uid}" | cut -d: -f1)"
    usermod -l "${user_name}" "${old_user}"
    usermod -d "/home/${user_name}" "${user_name}"
    echo "[docker_user_mapping] Renamed user '${old_user}' -> '${user_name}' (uid=${uid})."
  else
    adduser --disabled-password --force-badname --gecos '' \
      "${user_name}" --uid "${uid}" --gid "${gid}"
  fi

  # 手动补复制 skel 初始化文件
  local user_home
  user_home="$(getent passwd "${user_name}" | cut -d: -f6)"
  mkdir -p "${user_home}"
  if [[ -d /etc/skel ]]; then
    cp /etc/skel/.* "${user_home}/" 2>/dev/null || true
  fi
  chown -R "${uid}:${gid}" "${user_home}" 2>/dev/null || true
}

_setup_user_home() {
  local user_name="$1"; local uid="$2"; local gid="$3"
  local user_home
  user_home="$(getent passwd "${user_name}" | cut -d: -f6)"

  # 复制自定义 rcfiles：user.bashrc -> .bashrc, user.profile -> .profile
  local rcfiles_dir="${RCFILES_DIR:-/opt/apollo/rcfiles}"
  if [[ -d "${rcfiles_dir}" ]]; then
    local entry rc
    for entry in "${rcfiles_dir}"/*; do
      rc="$(basename "${entry}")"
      if [[ "${rc}" == user.* ]]; then
        cp -rf "${entry}" "${user_home}/${rc##user}"
      fi
    done
  fi

  # 将 ROS2 环境 source 追加到用户 .bashrc（幂等，避免重复添加）
  local bashrc="${user_home}/.bashrc"
  touch "${bashrc}"
  if ! grep -q 'source /opt/ros/jazzy/setup.bash' "${bashrc}"; then
    echo 'source /opt/ros/jazzy/setup.bash' >> "${bashrc}"
  fi

  # 归属改到目标用户
  chown -R "${uid}:${gid}" "${user_home}"/.* 2>/dev/null || true
}

_grant_extra_groups() {
  local user_name="$1"

  usermod -aG sudo "${user_name}" 2>/dev/null || true
  usermod -aG video "${user_name}" 2>/dev/null || true

  # 按设备存在情况授予权限（GPS/IMU/摄像头/音频/计算设备）
  for dev in /dev/novatel0 /dev/novatel1 /dev/novatel2 /dev/ttyACM0 /dev/imu \
             /dev/camera/obstacle /dev/camera/trafficlights; do
    [ -e "${dev}" ] && chmod a+rw "${dev}" 2>/dev/null || true
  done

  [ -e /dev/snd ] && usermod -aG audio "${user_name}" 2>/dev/null || true

  if [ -e /dev/kfd ]; then
    getent group render >/dev/null || \
      echo "render:x:$(stat -c %g /dev/kfd):${user_name}" >> /etc/group
    usermod -aG render "${user_name}" 2>/dev/null || true
  fi
}

# 允许直接以参数方式调用容器内函数，便于作为 ENTRYPOINT 或 docker exec 使用
case "${1:-}" in
  create_container_user)
    create_container_user
    ;;
  *)
    main
    ;;
esac
