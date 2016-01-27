if (CMakeBuildPackage_FOUND)
  return()
endif()
set(CMakeBuildPackage_FOUND TRUE)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")


include(GNUInstallDirs REQUIRED)
include(CMakeParseArguments REQUIRED)
include(CMakePackageConfigHelpers REQUIRED)
include(CMakeDetermineArchitecture REQUIRED)

option(CMakeBuildPackage_SOURCE_PACKAGE_EXCLUDE_FROM_ALL
  "Register the packages found in source form with EXCLUDE_FROM_ALL"
  ON)
option(CMakeBuildPackage_ARCHIVE_ENABLED
  "Generate tar.xz archives foreach declared package"
  ON)
option(CMakeBuildPackage_SOURCE_ARCHIVE_ENABLED
  "Generate tar.xz archives foreach declared package"
  ON)

function(build_package)
  cmake_parse_arguments(CBP_PACKAGE "" "NAME;VERSION;CXX_STANDARD" "REQUIRES" ${ARGN})

  foreach(package IN LISTS CBP_PACKAGE_REQUIRES)
    if (package MATCHES "(@|==)")
      string(REGEX REPLACE "(@|==)(.*)" ";\\2;EXACT" package "${package}")
    elseif(package MATCHES "( |>=)")
      string(REGEX REPLACE "( |>=)" ";" package "${package}")
    endif()

    find_package(${package} REQUIRED NO_MODULE)

    list(GET package 0 package)
    list(APPEND imported_packages ${package}::${package})
  endforeach()

  if (CBP_PACKAGE_NAME)
    set(package "${CBP_PACKAGE_NAME}")
  else()
    get_filename_component(package "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
  endif()

  if (CBP_PACKAGE_VERSION)
    set(version "${CBP_PACKAGE_VERSION}")
  else()
    set(version "0.0.0")
  endif()
  get_filename_component(soversion "${version}" NAME_WE)


  set(CMAKE_C_EXTENSIONS OFF)
  set(CMAKE_C_STANDARD 11)
  set(CMAKE_C_STANDARD_REQUIRED TRUE)

  set(CMAKE_CXX_EXTENSIONS OFF)
  set(CMAKE_CXX_STANDARD 14)
  set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

  set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS TRUE)
  set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)

  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

  if (CMAKE_SYSTEM_NAME MATCHES "[Ww][Ii][Nn][Dd][Oo][Ww][Ss]")
    set(install_bindir   "${CMAKE_INSTALL_BINDIR}")
    set(install_libdir   "${CMAKE_INSTALL_LIBDIR}")
    set(install_incdir   "${CMAKE_INSTALL_INCLUDEDIR}")
    set(install_cmakedir "cmake")
  else()
    set(install_bindir   "${CMAKE_INSTALL_BINDIR}/${package}-${version}")
    set(install_libdir   "${CMAKE_INSTALL_LIBDIR}/${package}-${version}")
    set(install_incdir   "${CMAKE_INSTALL_INCLUDEDIR}/${package}-${version}")
    set(install_cmakedir "${CMAKE_INSTALL_DATADIR}/cmake/${package}-${version}")
  endif()


  project(${package})

  file(GLOB_RECURSE sources RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    "src/*.c" "src/*.cpp" "src/*.cc" "src/*.c++")
  list(SORT sources)
  file(GLOB_RECURSE headers RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    "src/*.h" "src/*.hpp" "src/*.hh" "src/*.h++")
  list(SORT headers)

  set(package_sources ${sources})
  set(package_headers ${headers})
  set(executable_sources)


  foreach(source IN LISTS sources)
    file(READ "${source}" contents)
    string(REGEX REPLACE "/\\*(\\*[^/]|[^*]+)*\\*/" "" contents "${contents}")
    string(REGEX REPLACE "//[^\n]*\n" "" contents "${contents}")

    if (contents MATCHES "(int|void)[\t\n ]+main[\t\n ]*(\\([\t\n ]*\\)|\\([\t\n ]*void[\t\n ]*\\)|\\([\t\n ]*int[^,\\)]*,[\t\n ]*char[^,\\)]*\\))")
      message(STATUS "Found executable in ${source}")

      get_filename_component(directory "${source}" DIRECTORY)
      list(APPEND executable_dirs "${directory}")
      list(APPEND executable_sources "${source}")

      get_filename_component(executable "${source}" NAME_WE)
      if (executable STREQUAL "src")
        set(executable "${package}")
      endif()
      set(${executable}_dir "${directory}")

      if (executable STREQUAL package)
        add_executable(${executable}-exe ${source})
        set_target_properties(${executable}-exe PROPERTIES OUTPUT_NAME ${executable})
        set(executable "${executable}-exe")
      else()
        add_executable(${executable} ${source})
      endif()

      target_include_directories(${executable}
         PRIVATE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>"
         PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>")

      list(APPEND executables "${executable}")
    endif()
  endforeach()

  if (executables)
    list(APPEND package_targets ${executables})
    list(REMOVE_ITEM package_sources ${executable_sources})


    list(REMOVE_DUPLICATES executable_dirs)
    foreach(executable_dir IN LISTS executable_dirs)
      if (executable_dir STREQUAL "src")
        continue()
      endif()

      string(REPLACE "/" "_" library "${executable_dir}")
      string(REPLACE "src_" "${package}_" library "${library}")

      file(GLOB_RECURSE library_sources RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
        "${executable_dir}/*.c" "${executable_dir}/*.cpp" "${executable_dir}/*.cc" "${executable_dir}/*.c++")
      list(SORT library_sources)
      file(GLOB_RECURSE library_headers RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
        "${executable_dir}/*.h" "${executable_dir}/*.hpp" "${executable_dir}/*.hh" "${executable_dir}/*.h++")
      list(SORT library_headers)

      list(REMOVE_ITEM library_sources ${executable_sources})

      if (library_sources)
        list(REMOVE_ITEM package_sources ${library_sources})

        add_library(${library} ${library_sources} ${library_headers})
        add_library(${package}::${library} ALIAS ${library})
        target_include_directories(${library}
           PRIVATE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>"
           PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
                  "$<INSTALL_INTERFACE:${install_incdir}>")

        foreach(executable IN LISTS executables)
          if (${executable}_dir STREQUAL executable_dir)
            target_link_libraries(${executable} PUBLIC ${library})
          endif()
        endforeach()

        list(APPEND libraries "${library}")
      endif()
    endforeach()
    list(APPEND package_targets ${libraries})
  endif()


  if (CMAKE_SYSTEM_NAME MATCHES "[Ww][Ii][Nn][Dd][Oo][Ww][Ss]")
    set(system_libraries)
  elseif (CMAKE_SYSTEM_NAME MATCHES "[Ll][Ii][Nn][Uu][Xx]")
    set(system_libraries m)
  endif()


  file(GLOB_RECURSE public_headers RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    "include/*.h" "include/*.hpp" "include/*.hh" "include/*.h++")
  list(SORT public_headers)
  list(APPEND package_headers ${public_headers})

  if (package_sources OR package_headers)
    add_library(${package} ${package_sources} ${package_headers})
    add_library(${package}::${package} ALIAS ${package})
    target_include_directories(${package}
       PRIVATE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>"
       PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
              "$<INSTALL_INTERFACE:${install_incdir}>")
    target_link_libraries(${package} PUBLIC ${imported_packages} ${system_libraries})

    foreach(executable IN LISTS executables)
      target_link_libraries(${executable} PUBLIC ${package})
    endforeach()

    foreach(library IN LISTS libraries)
      target_link_libraries(${library} PUBLIC ${package})
    endforeach()

    list(APPEND package_targets ${package})
  endif()


  if (package_targets)
    install(TARGETS ${package_targets}
      EXPORT "${package}_targets"
      RUNTIME DESTINATION "${install_bindir}"
      LIBRARY DESTINATION "${install_libdir}"
      ARCHIVE DESTINATION "${install_libdir}")
    install(EXPORT "${package}_targets"
      FILE "${package}-targets.cmake"
      NAMESPACE "${package}::"
      DESTINATION "${install_cmakedir}")
  endif()

  install(DIRECTORY include/ DESTINATION ${install_incdir}
    FILES_MATCHING
    PATTERN "include/*.h"
    PATTERN "include/*.hpp"
    PATTERN "include/*.hh"
    PATTERN "include/*.h++")


  if (CMakeBuildPackage_SOURCE_PACKAGE_EXCLUDE_FROM_ALL)
    set(exclude EXCLUDE_FROM_ALL)
  else()
    set(exclude)
  endif()

  file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/${package}-config.cmake"
    "# AUTOGENERATED\n"
    "if (TARGET ${package}::${package})\n"
    "  return()\n"
    "endif()\n"
    "add_subdirectory(\"\${CMAKE_CURRENT_LIST_DIR}\"\n"
    "  \"\${CMAKE_BINARY_DIR}/packages/${package}\" ${exclude})\n")
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${package}-config.cmake"
    "# AUTOGENERATED\n"
    "include(\"${package}-targets.cmake\")\n")
  install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${package}-config.cmake"
    DESTINATION "${install_cmakedir}")

  if (version)
    set(version_file "${CMAKE_CURRENT_SOURCE_DIR}/${package}-config-version.cmake")
    write_basic_package_version_file("${version_file}" VERSION "${version}"
      COMPATIBILITY SameMajorVersion)
    install(FILES "${version_file}" DESTINATION "${install_cmakedir}")
  endif()


  if (CMakeBuildPackage_ARCHIVE_ENABLED)
    if (NOT TARGET packages)
      add_custom_target(packages)
    endif()

    if (BUILD_SHARED_LIBS)
      set(link_type "shared")
    else()
      set(link_type "static")
    endif()

    if (CMAKE_NO_BUILD_TYPE)
      set(build_type "$<LOWER_CASE:$<CONFIG>>")
    elseif (CMAKE_BUILD_TYPE)
      set(build_type "$<LOWER_CASE:${CMAKE_BUILD_TYPE}>")
    else()
      set(build_type "noconfig")
    endif()

    string(TOLOWER "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_ARCHITECTURE}" system_name)

    set(package_vername  "${package}-${version}")
    set(package_pkgdir   "${CMAKE_BINARY_DIR}/package/${package_vername}-${build_type}")
    set(package_instdir  "${CMAKE_BINARY_DIR}/install/${package_vername}-${build_type}")
    set(package_filename "${package_vername}-${build_type}-${link_type}-${system_name}")

    if (CMAKE_HOST_WIN32)
      set(package_instdirs "${package_instdir};${package_vername}")
      set(package_source_instdirs "${package_instdir}-source;${package_vername}")
    else()
      set(package_instdirs "${package_instdir}\;${package_vername}")
      set(package_source_instdirs "${package_instdir}-source\;${package_vername}")
    endif()

    string(REGEX REPLACE "cmake(.exe|)$" "cpack\\1" CPACK_COMMAND "${CMAKE_COMMAND}")
    add_custom_target(package-${package}
      COMMAND "${CPACK_COMMAND}" -G TXZ -P "${package}" -R "${version}" -B ${package_pkgdir}
        -D "CPACK_INSTALL_COMMANDS=${CMAKE_COMMAND} -D CMAKE_INSTALL_PREFIX=${package_instdir} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_install.cmake"
        -D "CPACK_INSTALLED_DIRECTORIES=${package_instdirs}"
        -D "CPACK_PACKAGE_FILE_NAME=${package_filename}"
        -D "CPACK_PACKAGE_DESCRIPTION=${package_vername} prebuilt"
        -D "CPACK_INCLUDE_TOPLEVEL_DIRECTORY=NO"
      COMMAND "${CMAKE_COMMAND}" -E copy "${package_pkgdir}/${package_filename}.tar.xz" "${CMAKE_BINARY_DIR}"
    )
    if (package_targets)
      add_dependencies(package-${package} ${package_targets})
    endif()
    add_dependencies(packages package-${package})

    if (CMakeBuildPackage_SOURCE_ARCHIVE_ENABLED)
      file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/cmake_install_source.cmake"
        "file(INSTALL DESTINATION \"\${CMAKE_INSTALL_PREFIX}\"\n"
        "  TYPE DIRECTORY FILES \"${CMAKE_CURRENT_SOURCE_DIR}/\"\n"
        "  FILES_MATCHING\n"
        "  REGEX \"${CMAKE_CURRENT_BINARY_DIR}\" EXCLUDE\n"
        "  REGEX \"${CMAKE_CURRENT_SOURCE_DIR}/packages\" EXCLUDE\n"
        "  REGEX \"(\\.git|\\.hg|\\.svn)$\" EXCLUDE\n"
        "  REGEX \".*\")\n")
      add_custom_target(package-${package}-source
        COMMAND ${CPACK_COMMAND} -G TXZ -P "${package}" -R "${version}" -B ${package_pkgdir}-source
          -D "CPACK_INSTALL_COMMANDS=${CMAKE_COMMAND} -D CMAKE_INSTALL_PREFIX=${package_instdir}-source -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_install_source.cmake"
          -D "CPACK_INSTALLED_DIRECTORIES=${package_source_instdirs}"
          -D "CPACK_PACKAGE_FILE_NAME=${package_vername}-source"
          -D "CPACK_PACKAGE_DESCRIPTION=${package_vername} sources"
          -D "CPACK_INCLUDE_TOPLEVEL_DIRECTORY=NO"
        COMMAND "${CMAKE_COMMAND}" -E copy "${package_pkgdir}-source/${package_vername}-source.tar.xz" "${CMAKE_BINARY_DIR}"
      )
      add_dependencies(packages package-${package}-source)
    endif()
  endif()


  if (NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    set(${package}_VERSION "${version}" CACHE STRING "${package} package version")
    set(${package}_FOUND TRUE CACHE BOOL "${package} package was found")
  endif()
endfunction()

list(APPEND CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/packages")


if (CMAKE_SYSTEM_NAME MATCHES "[Ww][Ii][Nn][Dd][Oo][Ww][Ss]" AND
    CMAKE_SYSTEM_ARCHITECTURE MATCHES "[Aa][Rr][Mm]" AND
    CMAKE_C_COMPILER_ID MATCHES "MSVC")
  add_definitions(-D_ARM_WINAPI_PARTITION_DESKTOP_SDK_AVAILABLE=1)
endif()
