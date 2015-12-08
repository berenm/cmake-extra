cmake_minimum_required(VERSION 2.8)
include(${CMAKE_CURRENT_LIST_DIR}/../../Modules/PackageHelper.cmake)

project(Exec)
add_package(Exec)

find_package(Test)

add_executable(exec	src/main.cpp)
target_link_libraries(exec Test::rary++)
package_executable(exec)
