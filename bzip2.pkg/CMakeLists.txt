set(bzip2_DIR ${CMAKE_SOURCE_DIR}/packages/bzip2)
set(bzip2_VERSION 1.0.6)

if (NOT EXISTS "${bzip2_DIR}/src")
  message(STATUS "Cloning bzip2 package sources...")

  file(MAKE_DIRECTORY "${bzip2_DIR}")
  file(DOWNLOAD http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz "${CMAKE_BINARY_DIR}/bzip2-1.0.6.tar.gz")
  execute_process(COMMAND "${CMAKE_COMMAND}" -E tar xf "${CMAKE_BINARY_DIR}/bzip2-1.0.6.tar.gz" WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")
  execute_process(COMMAND "${CMAKE_COMMAND}" -E rename "${CMAKE_BINARY_DIR}/bzip2-1.0.6" "${bzip2_DIR}/src" WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")
  execute_process(COMMAND "${CMAKE_COMMAND}" -E remove "${CMAKE_BINARY_DIR}/bzip2-1.0.6.tar.gz")

  file(MAKE_DIRECTORY "${bzip2_DIR}/include")
  file(RENAME "${bzip2_DIR}/src/bzlib.h"  "${bzip2_DIR}/include/bzlib.h")
  execute_process(COMMAND "${GIT_EXECUTABLE}" apply --directory "${bzip2_DIR}/src" "${CMAKE_CURRENT_LIST_DIR}/patch" WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}")

  file(REMOVE "${bzip2_DIR}/src/spewG.c")

  file(WRITE "${bzip2_DIR}/bzip2-config.cmake"
    "add_subdirectory(\"${bzip2_DIR}\" \"\${CMAKE_BINARY_DIR}/packages/bzip2\" EXCLUDE_FROM_ALL)\n")
  file(WRITE "${bzip2_DIR}/CMakeLists.txt"
    "build_package(VERSION \"${bzip2_VERSION}\")\n")
endif()

find_package(bzip2 REQUIRED NO_MODULE)
