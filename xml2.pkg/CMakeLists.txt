set(xml2_DIR ${CMAKE_SOURCE_DIR}/packages/xml2)
set(xml2_VERSION 2.9.4)

if (NOT EXISTS "${xml2_DIR}/src")
  message(STATUS "Cloning xml2 package sources...")
  execute_process(COMMAND "${GIT_EXECUTABLE}" clone --depth 1 --branch v${xml2_VERSION}
    git://git.gnome.org/libxml2 "${xml2_DIR}/src" ERROR_QUIET)

  file(RENAME "${xml2_DIR}/src/include" "${xml2_DIR}/include")
  file(RENAME "${xml2_DIR}/src/doc" "${xml2_DIR}/doc")
  file(RENAME "${xml2_DIR}/src/example" "${xml2_DIR}/example")

  set(unsafe_paths "--unsafe-paths")
  if (GIT_VERSION_STRING VERSION_LESS "1.9.0")
    set(unsafe_paths "")
  endif()

  execute_process(COMMAND "${GIT_EXECUTABLE}" apply ${unsafe_paths} --directory "${xml2_DIR}/src"
    "${CMAKE_CURRENT_LIST_DIR}/patch" WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}")

  set(VERSION ${xml2_VERSION})
  string(REPLACE "." "0" LIBXML_VERSION_NUMBER "${xml2_VERSION}")
  set(LIBXML_VERSION_EXTRA "")
  set(WITH_TRIO 0)
  set(WITH_THREADS 1)
  set(WITH_THREAD_ALLOC 1)
  set(WITH_TREE 1)
  set(WITH_OUTPUT 1)
  set(WITH_PUSH 1)
  set(WITH_READER 1)
  set(WITH_PATTERN 1)
  set(WITH_WRITER 1)
  set(WITH_SAX1 1)
  set(WITH_FTP 0)
  set(WITH_HTTP 0)
  set(WITH_VALID 1)
  set(WITH_HTML 1)
  set(WITH_LEGACY 1)
  set(WITH_C14N 1)
  set(WITH_CATALOG 1)
  set(WITH_DOCB 1)
  set(WITH_XPATH 1)
  set(WITH_XPTR 1)
  set(WITH_XINCLUDE 1)
  set(WITH_ICONV 1)
  set(WITH_ICU 0)
  set(WITH_ISO8859X 1)
  set(WITH_DEBUG 1)
  set(WITH_MEM_DEBUG 1)
  set(WITH_RUN_DEBUG 1)
  set(WITH_REGEXPS 1)
  set(WITH_REGEXPS 1)
  set(WITH_REGEXPS 1)
  set(WITH_SCHEMAS 1)
  set(WITH_SCHEMAS 1)
  set(WITH_SCHEMATRON 1)
  set(WITH_MODULES 1)
  set(MODULE_EXTENSION 1)
  set(WITH_ZLIB 1)
  set(WITH_LZMA 1)
  
  file(WRITE "${xml2_DIR}/src/config.h"
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
    "#define HAVE_FCNTL_H 1\n"
    "#define HAVE_ARPA_INET_H 1\n"
    "#define HAVE_NETDB_H 1\n"
    "#define HAVE_NETINET_IN_H 1\n"
    "#define HAVE_SYS_STAT_H 1\n"
    "#define HAVE_SYS_TYPES_H 1\n"
    "#define HAVE_SYS_SELECT_H 1\n"
    "#define HAVE_SYS_SOCKET_H 1\n"
    "#define HAVE_SYS_TIME_H 1\n"
    "#define HAVE_UNISTD_H 1\n"
    "\n"
    "#define HAVE_VA_COPY 1\n"
    "\n"
    "#define HAVE_LZMA_H 1\n"
    "#define HAVE_ZLIB_H 1\n"
    "\n"
    "#define ICONV_CONST\n")
  
  file(REMOVE ${xml2_DIR}/src/trio.c)
  file(REMOVE ${xml2_DIR}/src/rngparser.c)
  file(REMOVE ${xml2_DIR}/src/runsuite.c)
  file(REMOVE ${xml2_DIR}/src/runtest.c)
  file(REMOVE ${xml2_DIR}/src/runxmlconf.c)
  file(REMOVE ${xml2_DIR}/src/testAutomata.c)
  file(REMOVE ${xml2_DIR}/src/testC14N.c)
  file(REMOVE ${xml2_DIR}/src/testHTML.c)
  file(REMOVE ${xml2_DIR}/src/testModule.c)
  file(REMOVE ${xml2_DIR}/src/testOOM.c)
  file(REMOVE ${xml2_DIR}/src/testOOMlib.c)
  file(REMOVE ${xml2_DIR}/src/testReader.c)
  file(REMOVE ${xml2_DIR}/src/testRegexp.c)
  file(REMOVE ${xml2_DIR}/src/testRelax.c)
  file(REMOVE ${xml2_DIR}/src/testSAX.c)
  file(REMOVE ${xml2_DIR}/src/testSchemas.c)
  file(REMOVE ${xml2_DIR}/src/testThreads.c)
  file(REMOVE ${xml2_DIR}/src/testThreadsWin32.c)
  file(REMOVE ${xml2_DIR}/src/testURI.c)
  file(REMOVE ${xml2_DIR}/src/testXPath.c)
  file(REMOVE ${xml2_DIR}/src/testapi.c)
  file(REMOVE ${xml2_DIR}/src/testchar.c)
  file(REMOVE ${xml2_DIR}/src/testdict.c)
  file(REMOVE ${xml2_DIR}/src/testlimits.c)
  file(REMOVE ${xml2_DIR}/src/testrecurse.c)


  file(REMOVE_RECURSE ${xml2_DIR}/src/win32)
  file(REMOVE_RECURSE ${xml2_DIR}/src/python)
  file(REMOVE_RECURSE ${xml2_DIR}/src/os400)
  file(REMOVE_RECURSE ${xml2_DIR}/src/macos)
  
  configure_file("${xml2_DIR}/include/libxml/xmlversion.h.in" "${xml2_DIR}/include/libxml/xmlversion.h" @ONLY)

  file(WRITE "${xml2_DIR}/xml2-config.cmake"
    "add_subdirectory(\"${xml2_DIR}\" \"\${CMAKE_BINARY_DIR}/packages/xml2\" EXCLUDE_FROM_ALL)\n")
  file(WRITE "${xml2_DIR}/CMakeLists.txt"
    "build_package(NAME xml2 REQUIRES z xz VERSION \"${xml2_VERSION}\")\n")
endif()

find_package(xml2 REQUIRED NO_MODULE)
