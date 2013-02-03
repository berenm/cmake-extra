============================
CMake Extra
============================

Extra CMake scripts used in my projects.

USAGE
````````````````````````````

1. Download the CMakeExtraBootstrap.cmake file in a cmake/ subfolder of your project:

.. code:: bash

  mkdir cmake
  wget http://git.io/CMakeExtraBootstrap.cmake -P cmake/


2. Add the following lines at the beginning of your CMakeLists.txt:

.. code:: cmake

  list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
  include(CMakeExtraBootstrap)

``cmake-extra`` will automatically try to keep itself up-to-date.
