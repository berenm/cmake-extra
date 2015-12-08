cmake_minimum_required(VERSION 2.8)
include(${CMAKE_CURRENT_LIST_DIR}/../../Modules/PackageHelper.cmake)

project(Test)
add_package(Test)


add_library(rary
	include/rary.h
	src/lib.c
	src/lib.h
	src/private/private.c
)
target_include_directories(rary
	PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
	PRIVATE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>"
)
package_library(rary HEADER_PATTERNS "*.h" HEADER_RELATIVE include HEADER_RECURSE)


add_library(rary++
	include/rary.hpp
	src/lib.cpp
	src/lib.hpp
	src/private/private.cpp
)
target_include_directories(rary++
	PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
	PRIVATE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>"
)
package_library(rary++ HEADER_PATTERNS "*.hpp" HEADER_RELATIVE include HEADER_RECURSE)


package_data(CMAKE_FILES "TestConfigExtra.cmake")
