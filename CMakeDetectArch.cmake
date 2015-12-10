if (CMAKE_SYSTEM_ARCH)
  return()
endif()

file(WRITE "${CMAKE_BINARY_DIR}/architecture.c" [[
#if defined(__arm64) || defined(__arm64__)
  #error cmake_ARCH aarch64
#elif defined(__arm__) || defined(__TARGET_ARCH_ARM) || defined(_M_ARM)
  #if defined(__ARM_ARCH_8__) \
      || defined(__ARM_ARCH_8A__) \
      || (defined(__TARGET_ARCH_ARM) && __TARGET_ARCH_ARM-0 >= 8)
    #error cmake_ARCH armv7
  #elif defined(__ARM_ARCH_7__) \
      || defined(__ARM_ARCH_7A__) \
      || defined(__ARM_ARCH_7R__) \
      || defined(__ARM_ARCH_7M__) \
      || (defined(__TARGET_ARCH_ARM) && __TARGET_ARCH_ARM-0 >= 7)
    #error cmake_ARCH armv7
  #elif defined(__ARM_ARCH_6__) \
      || defined(__ARM_ARCH_6J__) \
      || defined(__ARM_ARCH_6T2__) \
      || defined(__ARM_ARCH_6Z__) \
      || defined(__ARM_ARCH_6K__) \
      || defined(__ARM_ARCH_6ZK__) \
      || defined(__ARM_ARCH_6M__) \
      || (defined(__TARGET_ARCH_ARM) && __TARGET_ARCH_ARM-0 >= 6)
    #error cmake_ARCH armv6
  #elif defined(__ARM_ARCH_5TEJ__) \
      || (defined(__TARGET_ARCH_ARM) && __TARGET_ARCH_ARM-0 >= 5)
    #error cmake_ARCH armv5
  #else
    #error cmake_ARCH arm
  #endif
#elif defined(__i386) || defined(__i386__) || defined(_M_IX86)
  #error cmake_ARCH i386
#elif defined(__x86_64) || defined(__x86_64__) || defined(__amd64) || defined(_M_X64)
  #error cmake_ARCH amd64
#elif defined(__ia64) || defined(__ia64__) || defined(_M_IA64)
  #error cmake_ARCH ia64
#elif defined(__ppc__) || defined(__ppc) || defined(__powerpc__) \
    || defined(_ARCH_COM) || defined(_ARCH_PWR) || defined(_ARCH_PPC)  \
    || defined(_M_MPPC) || defined(_M_PPC)
  #if defined(__ppc64__) || defined(__powerpc64__) || defined(__64BIT__)
    #error cmake_ARCH powerpc64
  #else
    #error cmake_ARCH powerpc
  #endif
#else
  #error cmake_ARCH unknown
#endif
]])

enable_language(C)
try_compile(compiled ${CMAKE_BINARY_DIR} "${CMAKE_BINARY_DIR}/architecture.c" OUTPUT_VARIABLE CMAKE_SYSTEM_ARCH)
unset(compiled)

string(REGEX REPLACE "^.*cmake_ARCH ([a-zA-Z0-9_]+).*$" "\\1" CMAKE_SYSTEM_ARCH "${CMAKE_SYSTEM_ARCH}")
message(STATUS "Target system: ${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_ARCH}")
