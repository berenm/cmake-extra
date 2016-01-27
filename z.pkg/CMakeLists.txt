set(z_DIR ${CMAKE_SOURCE_DIR}/packages/z)
set(z_VERSION 1.2.8)

if (NOT EXISTS "${z_DIR}/src")
  message(STATUS "Cloning z package sources...")
  execute_process(COMMAND "${GIT_EXECUTABLE}" clone --depth 1 --branch v${z_VERSION}
    https://github.com/madler/zlib "${z_DIR}/src" ERROR_QUIET)

  file(MAKE_DIRECTORY "${z_DIR}/include")
  file(RENAME "${z_DIR}/src/zlib.h"  "${z_DIR}/include/zlib.h")
  file(RENAME "${z_DIR}/src/zconf.h" "${z_DIR}/include/zconf.h")

  file(REMOVE_RECURSE "${z_DIR}/src/contrib")
  file(REMOVE_RECURSE "${z_DIR}/src/test")
  file(REMOVE_RECURSE "${z_DIR}/src/examples")

  file(WRITE "${z_DIR}/z-config.cmake"
    "add_subdirectory(\"${z_DIR}\" \"\${CMAKE_BINARY_DIR}/packages/z\" EXCLUDE_FROM_ALL)\n")
  file(WRITE "${z_DIR}/CMakeLists.txt"
    "build_package(NAME z VERSION \"${z_VERSION}\")\n")
endif()

find_package(z REQUIRED NO_MODULE)
