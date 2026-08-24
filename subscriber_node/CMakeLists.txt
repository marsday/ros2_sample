cmake_minimum_required(VERSION 3.8)
project(subscriber_node)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(sample_msgs REQUIRED)

add_executable(subscriber_node src/subscriber_node.cpp)
ament_target_dependencies(subscriber_node
  rclcpp
  sample_msgs
)

install(
  TARGETS subscriber_node
  DESTINATION lib/${PROJECT_NAME}
)

install(
  DIRECTORY launch
  DESTINATION share/${PROJECT_NAME}
)

ament_package()
