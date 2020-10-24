set(xz_DIR ${CMAKE_SOURCE_DIR}/packages/xz)
set(xz_VERSION 5.2)

if (NOT EXISTS "${xz_DIR}/src")
  message(STATUS "Cloning xz package sources...")
  execute_process(COMMAND "${GIT_EXECUTABLE}" clone --branch v${xz_VERSION}
    http://git.tukaani.org/xz.git "${xz_DIR}/src" ERROR_QUIET)

  file(MAKE_DIRECTORY "${xz_DIR}/include")
  file(RENAME "${xz_DIR}/src/src/liblzma/api/lzma.h" "${xz_DIR}/include/lzma.h")
  file(RENAME "${xz_DIR}/src/src/liblzma/api/lzma"   "${xz_DIR}/include/lzma")
  file(RENAME "${xz_DIR}/src/src/common" "${xz_DIR}/src/common")
  file(RENAME "${xz_DIR}/src/src/liblzma" "${xz_DIR}/src/liblzma")
  file(RENAME "${xz_DIR}/src/src/lzmainfo" "${xz_DIR}/src/lzmainfo")
  file(RENAME "${xz_DIR}/src/src/xz" "${xz_DIR}/src/xz")
  file(RENAME "${xz_DIR}/src/src/xzdec" "${xz_DIR}/src/xzdec")

  file(GLOB_RECURSE headers "${xz_DIR}/src/*.h")
  file(COPY ${headers} DESTINATION "${xz_DIR}/src")
  file(REMOVE ${headers})
  file(REMOVE ${xz_DIR}/src/debug/crc32.c)
  file(REMOVE ${xz_DIR}/src/debug/full_flush.c)
  file(REMOVE ${xz_DIR}/src/debug/hex2bin.c)
  file(REMOVE ${xz_DIR}/src/debug/known_sizes.c)
  file(REMOVE ${xz_DIR}/src/debug/memusage.c)
  file(REMOVE ${xz_DIR}/src/debug/repeat.c)
  file(REMOVE ${xz_DIR}/src/debug/sync_flush.c)
  file(REMOVE ${xz_DIR}/src/doc/examples/01_compress_easy.c)
  file(REMOVE ${xz_DIR}/src/doc/examples/02_decompress.c)
  file(REMOVE ${xz_DIR}/src/doc/examples/03_compress_custom.c)
  file(REMOVE ${xz_DIR}/src/doc/examples/04_compress_easy_mt.c)
  file(REMOVE ${xz_DIR}/src/doc/examples_old/xz_pipe_comp.c)
  file(REMOVE ${xz_DIR}/src/doc/examples_old/xz_pipe_decomp.c)
  file(REMOVE ${xz_DIR}/src/extra/scanlzma/scanlzma.c)
  file(REMOVE ${xz_DIR}/src/lib/getopt.c)
  file(REMOVE ${xz_DIR}/src/lib/getopt1.c)
  file(REMOVE ${xz_DIR}/src/liblzma/check/crc32_small.c)
  file(REMOVE ${xz_DIR}/src/liblzma/check/crc32_tablegen.c)
  file(REMOVE ${xz_DIR}/src/liblzma/check/crc64_tablegen.c)
  file(REMOVE ${xz_DIR}/src/liblzma/lzma/fastpos_tablegen.c)
  file(REMOVE ${xz_DIR}/src/liblzma/rangecoder/price_tablegen.c)
  file(REMOVE ${xz_DIR}/src/tests/bcj_test.c)
  file(REMOVE ${xz_DIR}/src/tests/create_compress_files.c)
  file(REMOVE ${xz_DIR}/src/tests/test_bcj_exact_size.c)
  file(REMOVE ${xz_DIR}/src/tests/test_block_header.c)
  file(REMOVE ${xz_DIR}/src/tests/test_check.c)
  file(REMOVE ${xz_DIR}/src/tests/test_filter_flags.c)
  file(REMOVE ${xz_DIR}/src/tests/test_index.c)
  file(REMOVE ${xz_DIR}/src/tests/test_stream_flags.c)
  file(RENAME ${xz_DIR}/src/xz/main.c ${xz_DIR}/src/xz/xz.c)

  file(WRITE "${xz_DIR}/src/config.h"
    "#define HAVE_ASSERT_H 1\n"
    "#define HAVE_COMPLEX_H 1\n"
    "#define HAVE_CTYPE_H 1\n"
    "#define HAVE_ERRNO_H 1\n"
    "#define HAVE_FENV_H 1\n"
    "#define HAVE_FLOAT_H 1\n"
    "#define HAVE_INTTYPES_H 1\n"
    "#define HAVE_ISO646_H 1\n"
    "#define HAVE_LIMITS_H 1\n"
    "#define HAVE_LOCALE_H 1\n"
    "#define HAVE_MATH_H 1\n"
    "#define HAVE_SETJMP_H 1\n"
    "#define HAVE_SIGNAL_H 1\n"
    "#define HAVE_STDALIGN_H 1\n"
    "#define HAVE_STDARG_H 1\n"
    "#define HAVE_STDATOMIC_H 1\n"
    "#define HAVE_STDBOOL_H 1\n"
    "#define HAVE_STDDEF_H 1\n"
    "#define HAVE_STDINT_H 1\n"
    "#define HAVE_STDIO_H 1\n"
    "#define HAVE_STDLIB_H 1\n"
    "#define HAVE_STDNORETURN_H 1\n"
    "#define HAVE_STRING_H 1\n"
    "#define HAVE_TGMATH_H 1\n"
    "#define HAVE_THREADS_H 1\n"
    "#define HAVE_TIME_H 1\n"
    "#define HAVE_UCHAR_H 1\n"
    "#define HAVE_WCHAR_H 1\n"
    "#define HAVE_WCTYPE_H 1\n"
    "\n"
    "#define PACKAGE_NAME \"xz\"\n"
    "#define PACKAGE_URL \"http://tukaani.org/xz\"\n"
    "#define PACKAGE_BUGREPORT \"lasse.collin@tukaani.org\"\n"
    "\n"
    "#define ASSUME_RAM 128\n"
    "#define MYTHREAD_ENABLED 1\n"
    "#define MYTHREAD_POSIX 1\n")

  file(WRITE "${xz_DIR}/xz-config.cmake"
    "add_subdirectory(\"${xz_DIR}\" \"\${CMAKE_BINARY_DIR}/packages/xz\" EXCLUDE_FROM_ALL)\n")
  file(WRITE "${xz_DIR}/CMakeLists.txt"
    "build_package(NAME xz VERSION \"${xz_VERSION}\")\n")
endif()

find_package(xz REQUIRED NO_MODULE)
