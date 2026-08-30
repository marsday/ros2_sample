cmake_minimum_required(VERSION 3.8)
project(protobuf_msg)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

find_package(ament_cmake REQUIRED)
find_package(Protobuf REQUIRED)

# 自动收集 proto 目录下所有 .proto 文件
file(GLOB PROTO_FILES "${CMAKE_CURRENT_SOURCE_DIR}/proto/*.proto")
if(NOT PROTO_FILES)
  message(FATAL_ERROR "No .proto files found in proto/")
endif()

set(PROTO_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
file(MAKE_DIRECTORY "${PROTO_BINARY_DIR}")

set(PROTO_SRCS "")
set(PROTO_HDRS "")

# 为每个 .proto 文件生成 .pb.cc/.pb.h
foreach(proto_file ${PROTO_FILES})
  get_filename_component(proto_name ${proto_file} NAME_WE)
  set(pb_cc "${PROTO_BINARY_DIR}/${proto_name}.pb.cc")
  set(pb_h "${PROTO_BINARY_DIR}/${proto_name}.pb.h")

  add_custom_command(
    OUTPUT ${pb_cc} ${pb_h}
    COMMAND protobuf::protoc
      --cpp_out=${PROTO_BINARY_DIR}
      --proto_path=${CMAKE_CURRENT_SOURCE_DIR}/proto
      ${proto_file}
    DEPENDS ${proto_file}
    COMMENT "Generating protobuf C++ code from ${proto_name}.proto"
  )

  list(APPEND PROTO_SRCS ${pb_cc})
  list(APPEND PROTO_HDRS ${pb_h})
endforeach()

add_library(${PROJECT_NAME} SHARED ${PROTO_SRCS})
target_include_directories(${PROJECT_NAME} PUBLIC
  $<BUILD_INTERFACE:${PROTO_BINARY_DIR}>
  $<INSTALL_INTERFACE:include>
)
target_link_libraries(${PROJECT_NAME} PUBLIC protobuf::libprotobuf)

ament_export_targets(${PROJECT_NAME}Targets HAS_LIBRARY_TARGET)
ament_export_dependencies(Protobuf)

install(
  FILES ${PROTO_HDRS}
  DESTINATION include/${PROJECT_NAME}
)
install(
  TARGETS ${PROJECT_NAME}
  EXPORT ${PROJECT_NAME}Targets
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  RUNTIME DESTINATION bin
)

ament_package()
