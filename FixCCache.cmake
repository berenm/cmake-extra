if(__FIX_CCACHE_CMAKE__)
  return()
endif()
set(__FIX_CCACHE_CMAKE__ TRUE)


enable_language(C CXX)

if(CMAKE_C_COMPILER MATCHES ".*ccache.*")
  set(CMAKE_C_COMPILE_OBJECT   "CCACHE_BASEDIR=<CMAKE_CURRENT_SOURCE_DIR> CCACHE_UNIFY=1 ${CMAKE_C_COMPILE_OBJECT}")
endif()

if(CMAKE_CXX_COMPILER MATCHES ".*ccache.*")
  set(CMAKE_CXX_COMPILE_OBJECT "CCACHE_BASEDIR=<CMAKE_CURRENT_SOURCE_DIR> CCACHE_UNIFY=1 ${CMAKE_CXX_COMPILE_OBJECT}")
endif()

if($ENV{PATH} MATCHES ".*/ccache/.*")
  set(CMAKE_C_COMPILE_OBJECT   "CCACHE_BASEDIR=<CMAKE_CURRENT_SOURCE_DIR> CCACHE_UNIFY=1 ${CMAKE_C_COMPILE_OBJECT}")
  set(CMAKE_CXX_COMPILE_OBJECT "CCACHE_BASEDIR=<CMAKE_CURRENT_SOURCE_DIR> CCACHE_UNIFY=1 ${CMAKE_CXX_COMPILE_OBJECT}")
endif()
