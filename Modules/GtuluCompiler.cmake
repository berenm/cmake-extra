if(__GTULU_COMPILER_CMAKE__)
  return()
endif()
set(__GTULU_COMPILER_CMAKE__ TRUE)


include(CMakeParseArguments)

function(add_gtulu_program GTULU_PROGRAM_NAME)
  set(GTULU_PROGRAM_ARGS_FLAGS )
  set(GTULU_PROGRAM_ARGS_ONE_VALUE   DESTINATION TEMPLATES_DIR OUTPUT_VARIABLE)
  set(GTULU_PROGRAM_ARGS_MULTI_VALUE SOURCES)
  cmake_parse_arguments(GTULU_PROGRAM "${GTULU_PROGRAM_ARGS_FLAGS}" "${GTULU_PROGRAM_ARGS_ONE_VALUE}" "${GTULU_PROGRAM_ARGS_MULTI_VALUE}" ${ARGN} )

  if(NOT DEFINED GTULU_PROGRAM_OUTPUT_VARIABLE)
    set(GTULU_PROGRAM_OUTPUT_VARIABLE "GTULU_PROGRAM_${GTULU_PROGRAM_NAME}_SOURCES")
    string(TOUPPER "${GTULU_PROGRAM_OUTPUT_VARIABLE}" GTULU_PROGRAM_OUTPUT_VARIABLE)
  endif()


  if(NOT DEFINED GTULU_PROGRAM_DESTINATION)
    set(GTULU_PROGRAM_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/generated)
  endif()

  if(NOT IS_ABSOLUTE "${GTULU_PROGRAM_DESTINATION}")
    set(GTULU_PROGRAM_DESTINATION "${CMAKE_CURRENT_SOURCE_DIR}/${GTULU_PROGRAM_DESTINATION}")
  endif()

  if(NOT EXISTS "${GTULU_PROGRAM_DESTINATION}")
    file(MAKE_DIRECTORY "${GTULU_PROGRAM_DESTINATION}")
  endif()


  if(NOT DEFINED GTULU_PROGRAM_TEMPLATES_DIR)
    set(GTULU_PROGRAM_TEMPLATES_DIR include/gtulu/templates)
  endif()

  if(NOT IS_ABSOLUTE "${GTULU_PROGRAM_TEMPLATES_DIR}")
    set(GTULU_PROGRAM_TEMPLATES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${GTULU_PROGRAM_TEMPLATES_DIR}")
  endif()


  set(GTULU_PROGRAM_ABSOLUTE_SOURCES )
  foreach(GTULU_PROGRAM_SOURCE ${GTULU_PROGRAM_SOURCES})
    if(NOT IS_ABSOLUTE "${GTULU_PROGRAM_SOURCE}")
      set(GTULU_PROGRAM_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/${GTULU_PROGRAM_SOURCE}")
    endif()
    set(GTULU_PROGRAM_ABSOLUTE_SOURCES ${GTULU_PROGRAM_ABSOLUTE_SOURCES} ${GTULU_PROGRAM_SOURCE})
  endforeach()
  
  set(GTULU_PROGRAM_OUTPUT_BASENAME ${GTULU_PROGRAM_DESTINATION}/${GTULU_PROGRAM_NAME}_program_format)
  add_custom_command(
    OUTPUT  ${GTULU_PROGRAM_OUTPUT_BASENAME}.cpp ${GTULU_PROGRAM_OUTPUT_BASENAME}.hpp
    COMMAND gtulu-compiler -d ${GTULU_PROGRAM_DESTINATION} -p ${GTULU_PROGRAM_NAME} -t ${GTULU_PROGRAM_TEMPLATES_DIR} ${GTULU_PROGRAM_ABSOLUTE_SOURCES}
    DEPENDS ${GTULU_PROGRAM_ABSOLUTE_SOURCES} ${GTULU_PROGRAM_TEMPLATES_DIR}/static_program_format.hpp
  )

  set(${GTULU_PROGRAM_OUTPUT_VARIABLE} ${GTULU_PROGRAM_OUTPUT_BASENAME}.cpp PARENT_SCOPE)
endfunction(add_gtulu_program)