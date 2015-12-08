if ("${__INCLUDED_PACKAGE_HELPER}")
  return()
endif()
set(__INCLUDED_PACKAGE_HELPER TRUE)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")
include(GNUInstallDirs)
include(CMakeParseArguments)
include(CMakePackageConfigHelpers)

option(PACKAGE_EXCLUDE_FROM_ALL "Include the package dependencies with EXCLUDE_FROM_ALL" ON)

function(include_package PACKAGE_NAME)
  if ("${${PACKAGE_NAME}_FOUND}")
    return()
  endif()
  set(${PACKAGE_NAME}_FOUND FALSE PARENT_SCOPE)

  if ("${CMAKE_VERSION}" VERSION_GREATER "3.0.0")
    unset(${PACKAGE_NAME}_VERSION_MAJOR)
    unset(${PACKAGE_NAME}_VERSION_MINOR)
    unset(${PACKAGE_NAME}_VERSION_PATCH)
    unset(${PACKAGE_NAME}_VERSION_TWEAK)
  endif()

  if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt")
    if ("${PACKAGE_EXCLUDE_FROM_ALL}")
      set(exclude "EXCLUDE_FROM_ALL")
    else()
      set(exclude "")
    endif()

    add_subdirectory("${CMAKE_CURRENT_LIST_DIR}" "${PACKAGE_NAME}.dir" ${exclude})
    message(STATUS "Found ${PACKAGE_NAME} source in ${CMAKE_CURRENT_LIST_DIR}")

  elseif (EXISTS "${CMAKE_CURRENT_LIST_DIR}/${PACKAGE_NAME}Targets.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/${PACKAGE_NAME}Targets.cmake")
    message(STATUS "Found ${PACKAGE_NAME} built in ${CMAKE_CURRENT_LIST_DIR}")

  else()
    return()
  endif()

  set(${PACKAGE_NAME}_FOUND TRUE PARENT_SCOPE)
endfunction()

function(subdirectories OUTPUT_VARIABLE DIRECTORY)
  file(GLOB children LIST_DIRECTORIES TRUE RELATIVE "${DIRECTORY}" "${DIRECTORY}/*")

  set(${OUTPUT_VARIABLE})
  foreach(child ${children})
    if (NOT "${child}" MATCHES "\\..*" AND
        NOT "${DIRECTORY}/${child}" MATCHES "${CMAKE_CURRENT_BINARY_DIR}" AND
        IS_DIRECTORY "${DIRECTORY}/${child}")
      list(APPEND ${OUTPUT_VARIABLE} "${DIRECTORY}/${child}")
    endif()
  endforeach()

  set(${OUTPUT_VARIABLE} "${${OUTPUT_VARIABLE}}" PARENT_SCOPE)
endfunction()

function(package_executable TARGET)
  install(TARGETS "${TARGET}"
    EXPORT "${PACKAGE_NAME}Targets"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  )
endfunction()

function(package_library TARGET)
  cmake_parse_arguments(PACKAGE "HEADER_RECURSE" "HEADER_RELATIVE" "HEADER_PATTERNS" ${ARGN})

  if (NOT "${PACKAGE_HEADER_PATTERNS}" STREQUAL "")
    if (NOT IS_ABSOLUTE "${PACKAGE_HEADER_RELATIVE}")
      set(PACKAGE_HEADER_RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/${PACKAGE_HEADER_RELATIVE}")
    endif()

    string(REPLACE ";" ";${PACKAGE_HEADER_RELATIVE}/" patterns "${PACKAGE_HEADER_RELATIVE}/${PACKAGE_HEADER_PATTERNS}")
    file(GLOB files ${patterns})
    set_target_properties("${TARGET}" PROPERTIES PUBLIC_HEADER "${files}")

    if ("${PACKAGE_HEADER_RECURSE}")
      subdirectories(folders "${PACKAGE_HEADER_RELATIVE}")
      string(REPLACE ";" ";PATTERN;" patterns "${PACKAGE_HEADER_PATTERNS}")
      install(DIRECTORY ${folders}
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
        FILES_MATCHING PATTERN ${patterns}
      )
    endif()
  endif()

  target_include_directories(${TARGET}
    PUBLIC "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
  )

  install(TARGETS "${TARGET}"
    EXPORT "${PACKAGE_NAME}Targets"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    PUBLIC_HEADER DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
  )

  if (NOT TARGET "${PACKAGE_NAME}::${TARGET}")
    add_library("${PACKAGE_NAME}::${TARGET}" ALIAS "${TARGET}")
  endif()
endfunction()

function(package_data)
  cmake_parse_arguments(PACKAGE "" "" "FILES;CMAKE_FILES" ${ARGN})

  if (NOT "${PACKAGE_FILES}" STREQUAL "")
    install(FILES "${PACKAGE_FILES}" DESTINATION "${CMAKE_INSTALL_DATADIR}")
  endif()

  if (NOT "${PACKAGE_CMAKE_FILES}" STREQUAL "")
    install(FILES "${PACKAGE_CMAKE_FILES}" DESTINATION "${CMAKE_INSTALL_CMAKEDIR}")
  endif()
endfunction()

function(add_package PACKAGE_NAME)
  if ("${PROJECT_NAME}" STREQUAL "" OR
      "${${PROJECT_NAME}_SOURCE_DIR}" STREQUAL "" OR
      "${${PROJECT_NAME}_BINARY_DIR}" STREQUAL "")
    message(FATAL_ERROR "Could not find a valid CMake project")
  endif()

  cmake_parse_arguments(PACKAGE "" "VERSION" "" ${ARGN})

  set(PACKAGE_NAME            "${PACKAGE_NAME}" PARENT_SCOPE)
  set(${PACKAGE_NAME}_VERSION "${PACKAGE_VERSION}" PARENT_SCOPE)

  if ("${CMAKE_SYSTEM_NAME}" MATCHES "Windows")
    set(CMAKE_INSTALL_CMAKEDIR "cmake")
  # elseif ("${CMAKE_SYSTEM_NAME}" MATCHES "Darwin")
  #   set(CMAKE_INSTALL_CMAKEDIR "${PACKAGE_NAME}.framework/Resources/CMake")
  else()
    set(CMAKE_INSTALL_CMAKEDIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PACKAGE_NAME}")
  endif()
  set(CMAKE_INSTALL_CMAKEDIR  "${CMAKE_INSTALL_CMAKEDIR}" PARENT_SCOPE)

  install(EXPORT "${PACKAGE_NAME}Targets"
    FILE "${PACKAGE_NAME}Targets.cmake"
    NAMESPACE "${PACKAGE_NAME}::"
    DESTINATION "${CMAKE_INSTALL_CMAKEDIR}"
  )
  install(FILES "${PACKAGE_NAME}Config.cmake"
    DESTINATION "${CMAKE_INSTALL_CMAKEDIR}"
  )

  if (NOT "${PACKAGE_VERSION}" STREQUAL "")
    write_basic_package_version_file(
      "${PACKAGE_NAME}ConfigVersion.cmake"
      VERSION ${PACKAGE_VERSION}
      COMPATIBILITY AnyNewerVersion
    )

    install(FILES "${PACKAGE_NAME}ConfigVersion.cmake"
      DESTINATION "${CMAKE_INSTALL_CMAKEDIR}"
    )
  endif()
endfunction()
