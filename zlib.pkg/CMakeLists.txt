set(zlib_DIR ${CMAKE_SOURCE_DIR}/packages/zlib)
set(zlib_VERSION 1.2.11)
set(zlib_SOURCE arc::https://github.com/madler/zlib/archive/v1.2.11.tar.gz)

file(GLOB zlib_PATCHES "${CMAKE_CURRENT_LIST_DIR}/*.patch")

create_package(zlib)
