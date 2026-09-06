SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_IMAGE_BASENAME="my_ros2_dev"
### 安装基础编译环境
if [ -z "$(docker images -q ${DOCKER_IMAGE_BASENAME}:0.01)" ]; then
    echo "Building Docker image ${DOCKER_IMAGE_BASENAME}:0.01..."
    docker build -f ${SCRIPT_DIR}/dockerfile_0.01 -t ${DOCKER_IMAGE_BASENAME}:0.01 ${SCRIPT_DIR}
fi
### 安装 ROS2
if [ -z "$(docker images -q ${DOCKER_IMAGE_BASENAME}:0.02)" ]; then
    echo "Building Docker image ${DOCKER_IMAGE_BASENAME}:0.02..."
    docker build -f ${SCRIPT_DIR}/dockerfile_0.02 -t ${DOCKER_IMAGE_BASENAME}:0.02 ${SCRIPT_DIR}
fi
### 安装 protobuf 与 GTest/GMock
if [ -z "$(docker images -q ${DOCKER_IMAGE_BASENAME}:0.03)" ]; then
    echo "Building Docker image ${DOCKER_IMAGE_BASENAME}:0.03..."
    docker build -f ${SCRIPT_DIR}/dockerfile_0.03 -t ${DOCKER_IMAGE_BASENAME}:0.03 ${SCRIPT_DIR}
fi
