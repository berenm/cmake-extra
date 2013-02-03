cmake-extra
===========

Extra CMake scripts used in my projects.

How to use it?
===============

1. Download the CMakeExtraBootstrap.cmake file in a cmake/ subfolder of your project:
```bash
mkdir cmake
wget http://git.io/CMakeExtraBootstrap.cmake -P cmake/
```

2. Add the following lines at the beginning of your CMakeLists.txt:
```cmake
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
include(CMakeExtraBootstrap)
```

`cmake-extra` will automatically try to keep itself up-to-date.
