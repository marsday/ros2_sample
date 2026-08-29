cmake_minimum_required(VERSION 3.8)
project(publisher_node)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(common_functions REQUIRED)
find_package(sample_msgs REQUIRED)
find_package(protobuf_msg REQUIRED)

add_executable(publisher_node src/publisher_node.cpp)
ament_target_dependencies(publisher_node
  rclcpp
  common_functions
  sample_msgs
  protobuf_msg
)

install(
  TARGETS publisher_node
  DESTINATION lib/${PROJECT_NAME}
)

install(
  DIRECTORY launch
  DESTINATION share/${PROJECT_NAME}
)

ament_package()
