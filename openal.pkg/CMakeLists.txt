set(openal_DIR ${CMAKE_SOURCE_DIR}/packages/openal)
set(openal_VERSION 1.17.1)

if (NOT EXISTS "${openal_DIR}/src")
  message(STATUS "Cloning openal package sources...")
  execute_process(COMMAND "${GIT_EXECUTABLE}" clone --depth 1 --branch openal-soft-${openal_VERSION}
    https://github.com/kcat/openal-soft "${openal_DIR}/src" ERROR_QUIET)

  file(MAKE_DIRECTORY "${openal_DIR}/include")
  file(RENAME "${openal_DIR}/src/include/AL" "${openal_DIR}/include/AL")
  configure_file("${openal_DIR}/src/config.h.in" "${openal_DIR}/src/config.h")

  file(GLOB headers "${openal_DIR}/src/include/*.h" "${openal_DIR}/src/OpenAL32/Include/*.h"
  	"${openal_DIR}/src/Alc/*.h")
  file(COPY ${headers} DESTINATION "${openal_DIR}/src")

  file(WRITE "${openal_DIR}/openal-config.cmake"
    "add_subdirectory(\"${openal_DIR}\" \"\${CMAKE_BINARY_DIR}/packages/openal\" EXCLUDE_FROM_ALL)\n")
  file(WRITE "${openal_DIR}/CMakeLists.txt"
    "build_package(NAME openal VERSION \"${openal_VERSION}\")\n")
endif()

find_package(openal REQUIRED NO_MODULE)
