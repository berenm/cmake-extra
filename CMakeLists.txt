cmake_minimum_required(VERSION 3.3)

include(CMakeBuildPackage.cmake REQUIRED)
project(cmake-packages)

find_package(Git REQUIRED)

function(create_package PACKAGE)
  if (NOT EXISTS "${${PACKAGE}_DIR}")
    message(STATUS "Downloading ${PACKAGE} package")
    execute_process(COMMAND "${GIT_EXECUTABLE}" clone "${${PACKAGE}_SOURCE}" "${${PACKAGE}_DIR}"
      ERROR_QUIET)

    if (${PACKAGE}_PATCHES)
      message(STATUS "Patching ${PACKAGE} package")
      execute_process(COMMAND "${GIT_EXECUTABLE}" -C "${${PACKAGE}_DIR}" am
        ${${PACKAGE}_PATCHES})
    endif()

    file(WRITE "${${PACKAGE}_DIR}/${PACKAGE}-config.cmake"
      "add_subdirectory(\"\${CMAKE_CURRENT_LIST_DIR}\"\n"
      "  \"\${CMAKE_BINARY_DIR}/packages/${PACKAGE}\" EXCLUDE_FROM_ALL)\n"
      "message(STATUS \"Found ${PACKAGE} ${${PACKAGE}_VERSION} (source)\")\n"
    )
  endif()

  if (BUILD_PATCHES)
    file(REMOVE ${${PACKAGE}_PATCHES})
    execute_process(COMMAND "${GIT_EXECUTABLE}" -C "${${PACKAGE}_DIR}" format-patch
      --break-rewrites --find-renames --find-copies --find-copies-harder
      --output-directory "${CMAKE_CURRENT_LIST_DIR}" origin/master
      OUTPUT_QUIET)
  endif()

  find_package(${PACKAGE} REQUIRED NO_MODULE)
endfunction()

add_subdirectory(zlib.pkg)
add_subdirectory(bzip2.pkg)
# add_subdirectory(png.pkg)
# add_subdirectory(xz.pkg)
# add_subdirectory(xml2.pkg)
# add_subdirectory(openal.pkg)

# Boost is a beast, lets skip it for now
# add_subdirectory(boost.pkg)
