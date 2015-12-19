cmake_minimum_required(VERSION 3.3)

include(CMakeBuildPackage.cmake REQUIRED)
project(cmake-packages)

find_package(Git REQUIRED)

add_subdirectory(z.pkg)
add_subdirectory(bzip2.pkg)
add_subdirectory(png.pkg)

# Boost is a beast, lets skip it for now
# add_subdirectory(boost.pkg)
