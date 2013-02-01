cmake-extra
===========

Extra CMake scripts used in my projects.

How to use it?
===============

Simply download the CMakeExtraBootstrap.cmake file in a cmake/ subfolder of your project, and add the following lines at the beginning of your CMakeLists.txt:
```cmake
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
include(CMakeExtraBootstrap)
```

`cmake-extra` will automatically try to keep itself up-to-date.
