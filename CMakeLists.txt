cmake_minimum_required(VERSION 3.3)

include(CMakeBuildPackage.cmake REQUIRED)
project(cmake-packages)

find_package(Git REQUIRED)

add_subdirectory(z.pkg)
add_subdirectory(png.pkg)

find_package(z REQUIRED NO_MODULE)
find_package(png REQUIRED NO_MODULE)
