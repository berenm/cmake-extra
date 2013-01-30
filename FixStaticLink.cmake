if(__FIX_STATIC_LINK_CMAKE__)
  return()
endif()
set(__FIX_STATIC_LINK_CMAKE__)


enable_language(C CXX)

include(CheckCCompilerFlag)
check_c_compiler_flag("-Wl,--start-group -Wl,--end-group" CMAKE_C_LINKER_HAS_GROUP)
if(CMAKE_C_LINKER_HAS_GROUP)
  string(REPLACE "<LINK_LIBRARIES>" "-Wl,--start-group <LINK_LIBRARIES> -Wl,--end-group" CMAKE_C_LINK_EXECUTABLE       "${CMAKE_C_LINK_EXECUTABLE}")
  string(REPLACE "<LINK_LIBRARIES>" "-Wl,--start-group <LINK_LIBRARIES> -Wl,--end-group" CMAKE_C_CREATE_SHARED_LIBRARY "${CMAKE_C_CREATE_SHARED_LIBRARY}")
  string(REPLACE "<LINK_LIBRARIES>" "-Wl,--start-group <LINK_LIBRARIES> -Wl,--end-group" CMAKE_C_CREATE_SHARED_MODULE  "${CMAKE_C_CREATE_SHARED_MODULE}")
endif()

include(CheckCXXCompilerFlag)
check_cxx_compiler_flag("-Wl,--start-group -Wl,--end-group" CMAKE_CXX_LINKER_HAS_GROUP)
if(CMAKE_CXX_LINKER_HAS_GROUP)
  string(REPLACE "<LINK_LIBRARIES>" "-Wl,--start-group <LINK_LIBRARIES> -Wl,--end-group" CMAKE_CXX_LINK_EXECUTABLE       "${CMAKE_CXX_LINK_EXECUTABLE}")
  string(REPLACE "<LINK_LIBRARIES>" "-Wl,--start-group <LINK_LIBRARIES> -Wl,--end-group" CMAKE_CXX_CREATE_SHARED_LIBRARY "${CMAKE_CXX_CREATE_SHARED_LIBRARY}")
  string(REPLACE "<LINK_LIBRARIES>" "-Wl,--start-group <LINK_LIBRARIES> -Wl,--end-group" CMAKE_CXX_CREATE_SHARED_MODULE  "${CMAKE_CXX_CREATE_SHARED_MODULE}")
endif()
