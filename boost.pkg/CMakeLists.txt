set(boost_VERSION 1.60.0)
set(boost_COMPONENTS accumulators algorithm align any array asio assert assign atomic bimap bind
  chrono circular_buffer compatibility concept_check config container #[[context]] conversion convert
  core #[[coroutine]] coroutine2 crc date_time detail disjoint_sets dynamic_bitset endian exception
  filesystem flyweight foreach format function function_types functional fusion geometry gil graph
  #[[graph_parallel]] heap icl integer interprocess intrusive io iostreams iterator lambda lexical_cast
  local_function #[[locale]] lockfree #[[log]] logic math move #[[mpi]] mpl msm multi_array multi_index
  multiprecision numeric_conversion interval odeint ublas optional parameter phoenix polygon pool
  predef preprocessor program_options property_map property_tree proto ptr_container #[[python]] random
  range ratio rational regex scope_exit serialization signals signals2 smart_ptr sort spirit
  statechart static_assert system test thread throw_exception timer tokenizer tr1 tti tuple
  type_erasure type_index type_traits typeof units unordered utility uuid variant vmd wave winapi
  xpressive)

foreach(component IN LISTS boost_COMPONENTS)
  set(boost_${component}_DIR "${CMAKE_SOURCE_DIR}/packages/boost_${component}")

  if (NOT EXISTS "${boost_${component}_DIR}")
    message(STATUS "Cloning boost_${component} package sources...")
    execute_process(COMMAND "${GIT_EXECUTABLE}" clone --depth 1 --branch boost-${boost_VERSION}
      https://github.com/boostorg/${component} "${boost_${component}_DIR}" ERROR_QUIET)

    file(WRITE "${boost_${component}_DIR}/boost_${component}-config.cmake"
      "add_subdirectory(\"${boost_${component}_DIR}\" \"\${CMAKE_BINARY_DIR}/packages/boost_${component}\" EXCLUDE_FROM_ALL)\n")
    file(WRITE "${boost_${component}_DIR}/CMakeLists.txt"
      "build_package(VERSION \"${boost_VERSION}\")\n")

    if (component STREQUAL thread)
      execute_process(COMMAND "${GIT_EXECUTABLE}" apply "${CMAKE_CURRENT_LIST_DIR}/boost_thread.patch" WORKING_DIRECTORY "${boost_thread_DIR}")
      file(RENAME "${boost_thread_DIR}/src/pthread/once_atomic.cpp" "${boost_thread_DIR}/src/pthread/once_atomic.ipp")
    elseif (component STREQUAL container)
      execute_process(COMMAND "${GIT_EXECUTABLE}" apply "${CMAKE_CURRENT_LIST_DIR}/boost_container.patch" WORKING_DIRECTORY "${boost_container_DIR}")
      file(RENAME "${boost_container_DIR}/src/dlmalloc_2_8_6.c" "${boost_container_DIR}/src/dlmalloc_2_8_6.i")
      file(RENAME "${boost_container_DIR}/src/dlmalloc_ext_2_8_6.c" "${boost_container_DIR}/src/dlmalloc_ext_2_8_6.i")
    elseif (component STREQUAL test)
      execute_process(COMMAND "${GIT_EXECUTABLE}" apply "${CMAKE_CURRENT_LIST_DIR}/boost_test.patch" WORKING_DIRECTORY "${boost_test_DIR}")
    endif()
  endif()
endforeach()

foreach(component IN ITEMS accumulators algorithm align any array asio assert assign bimap bind
  circular_buffer compatibility concept_check config conversion convert core coroutine2 crc detail
  disjoint_sets dynamic_bitset endian flyweight foreach format function function_types functional
  fusion geometry gil heap icl integer interprocess intrusive io iterator lambda lexical_cast
  local_function lockfree logic move mpl msm multi_array multi_index multiprecision
  numeric_conversion interval odeint ublas optional parameter phoenix polygon pool predef
  preprocessor property_map property_tree proto ptr_container range ratio rational scope_exit
  signals2 sort spirit statechart static_assert throw_exception tokenizer tr1 tti tuple type_index
  type_traits typeof units unordered utility uuid variant vmd winapi xpressive)
  if (NOT EXISTS "${boost_${component}_DIR}/src")
    file(MAKE_DIRECTORY "${boost_${component}_DIR}/src")
    file(WRITE "${boost_${component}_DIR}/src/dummy.cpp" "\n")
  endif()
endforeach()

function(boost_depends component)
  file(WRITE "${boost_${component}_DIR}/CMakeLists.txt"
    "build_package(VERSION \"${boost_VERSION}\" REQUIRES\n")
  list(REMOVE_AT ARGV 0)
  foreach(dependency IN LISTS ARGV)
    if (dependency IN_LIST boost_COMPONENTS)
      file(APPEND "${boost_${component}_DIR}/CMakeLists.txt"
        "   \"boost_${dependency}\"\n")
    else()
      file(APPEND "${boost_${component}_DIR}/CMakeLists.txt"
        "   \"${dependency}\"\n")
    endif()
  endforeach()
  file(APPEND "${boost_${component}_DIR}/CMakeLists.txt"
    ")\n")
endfunction()

if (NOT EXISTS "${boost_math_DIR}/src/pch.hpp")
  file(WRITE "${boost_math_DIR}/src/pch.hpp" "")
endif()

# boost_depends(context config assert thread predef)
# boost_depends(coroutine context config assert)
# boost_depends(graph_parallel graph mpi)
# boost_depends(locale config assert iterator thread unordered)
# boost_depends(log assert throw_exception smart_ptr intrusive type_index filesystem thread parameter spirit proto phoenix asio property_tree random variant regex)
boost_depends(any type_index)
boost_depends(array functional)
boost_depends(atomic config assert type_traits)
boost_depends(algorithm range)
boost_depends(chrono config predef mpl ratio core integer system throw_exception utility)
boost_depends(container config move intrusive)
boost_depends(date_time config throw_exception mpl type_traits smart_ptr utility math lexical_cast tokenizer)
boost_depends(exception config)
boost_depends(filesystem config system detail type_traits iterator smart_ptr io functional range)
boost_depends(foreach config mpl core range)
boost_depends(format optional)
boost_depends(function bind integer)
boost_depends(functional detail)
boost_depends(fusion typeof)
boost_depends(graph foreach lexical_cast math any property_map tuple unordered multi_index algorithm xpressive property_tree regex)
boost_depends(intrusive core)
boost_depends(iostreams throw_exception range bzip2 utility core smart_ptr)
boost_depends(iterator mpl static_assert detail)
boost_depends(lexical_cast range numeric_conversion integer array container)
boost_depends(math format lexical_cast fusion atomic)
boost_depends(move assert static_assert)
boost_depends(mpl config preprocessor type_traits)
boost_depends(multi_index serialization)
boost_depends(optional move)
boost_depends(program_options config any detail function lexical_cast math tokenizer)
boost_depends(range iterator concept_check)
boost_depends(ratio type_traits)
boost_depends(regex config predef assert throw_exception smart_ptr mpl type_traits integer functional)
boost_depends(serialization io spirit function)
boost_depends(signals type_traits config smart_ptr utility any function iterator)
boost_depends(random config core system)
boost_depends(smart_ptr throw_exception core predef align)
boost_depends(system config predef assert core)
boost_depends(test config core type_traits smart_ptr preprocessor utility function detail iterator timer io algorithm exception numeric_conversion)
boost_depends(thread core move bind atomic system date_time chrono io tuple exception function algorithm)
boost_depends(throw_exception assert)
boost_depends(timer config chrono io)
boost_depends(type_erasure mpl assert utility typeof thread)
boost_depends(type_index static_assert throw_exception core type_traits mpl)
boost_depends(type_traits static_assert)
boost_depends(wave config spirit pool)
boost_depends(pool thread)
boost_depends(xpressive proto exception conversion)

foreach(component IN LISTS boost_COMPONENTS)
  find_package(boost_${component} REQUIRED NO_MODULE)
endforeach()

add_custom_target(boost)
foreach(component IN LISTS boost_COMPONENTS)
  add_dependencies(boost boost_${component})
endforeach()
