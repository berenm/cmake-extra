set(png_DIR ${CMAKE_SOURCE_DIR}/packages/png)

if (NOT EXISTS "${png_DIR}/src")
  message(STATUS "Cloning png package sources...")
  execute_process(COMMAND "${GIT_EXECUTABLE}" clone --depth 1 --branch v1.6.20
    https://github.com/glennrp/libpng "${png_DIR}/src" ERROR_QUIET)

  file(MAKE_DIRECTORY "${png_DIR}/include")
  file(RENAME "${png_DIR}/src/png.h" "${png_DIR}/include/png.h")
  file(RENAME "${png_DIR}/src/pngconf.h" "${png_DIR}/include/pngconf.h")
  file(RENAME "${png_DIR}/src/pngcrush.h" "${png_DIR}/include/pngcrush.h")

  file(GLOB png_SOURCES "${png_DIR}/src/png*.c" "${png_DIR}/src/png*.h")
  file(GLOB all_SOURCES "${png_DIR}/src/*.c" "${png_DIR}/src/*.h")
  list(REMOVE_ITEM all_SOURCES "${png_DIR}/src/cexcept.h")
  list(REMOVE_ITEM all_SOURCES ${png_SOURCES})
  file(REMOVE ${all_SOURCES})

  # Because of missing utime.h on windows
  # TODO: fix pngcrush.c
  file(REMOVE "${png_DIR}/src/pngcrush.c")

  execute_process(COMMAND "${GIT_EXECUTABLE}" describe --all
    WORKING_DIRECTORY "${png_DIR}/src"
    OUTPUT_VARIABLE png_VERSION)
  string(REGEX REPLACE "^[^0-9]*([0-9]+(\\.[0-9]+)*)[^0-9]*$" "\\1" png_VERSION "${png_VERSION}")

  file(WRITE "${png_DIR}/png-config.cmake"
    "add_subdirectory(\"${png_DIR}\" \"\${CMAKE_BINARY_DIR}/packages/png\" EXCLUDE_FROM_ALL)\n")
  file(WRITE "${png_DIR}/CMakeLists.txt"
    "build_package(VERSION \"${png_VERSION}\" REQUIRES z)\n")
endif()

find_package(png REQUIRED NO_MODULE)
