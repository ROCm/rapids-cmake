#=============================================================================
# Copyright (c) 2021-2023, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#=============================================================================
# MIT License
#
# Modifications Copyright (c) 2023-2024 Advanced Micro Devices, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#=============================================================================
include_guard(GLOBAL)

include("${rapids-cmake-dir}/cpm/_init_hip_options.cmake")

#[=======================================================================[.rst:
rapids_cpm_libhipcxx
---------------------

.. versionadded:: v21.12.00

Allow projects to find or build `libhipcxx` via `CPM` with built-in
tracking of these dependencies for correct export support.

Uses the version of libhipcxx :ref:`specified in the version file <cpm_versions>` for consistency
across all RAPIDS projects.

.. code-block:: cmake

  rapids_cpm_libhipcxx( [BUILD_EXPORT_SET <export-name>]
                         [INSTALL_EXPORT_SET <export-name>]
                         [<CPM_ARGS> ...])

.. |PKG_NAME| replace:: libhipcxx
.. include:: common_package_args.txt

Result Targets
^^^^^^^^^^^^^^
  libhipcxx::libhipcxx target will be created

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`libhipcxx_SOURCE_DIR` is set to the path to the source directory of libhipcxx.
  :cmake:variable:`libhipcxx_BINARY_DIR` is set to the path to the build directory of  libhipcxx.
  :cmake:variable:`libhipcxx_ADDED`      is set to a true value if libhipcxx has not been added before.
  :cmake:variable:`libhipcxx_VERSION`    is set to the version of libhipcxx specified by the versions.json.

#]=======================================================================]
function(rapids_cpm_libhipcxx)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.libhipcxx")

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(libhipcxx version repository tag shallow exclude)

  include("${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake")
  rapids_cpm_generate_patch_command(libhipcxx ${version} patch_command)

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(libhipcxx ${version} ${ARGN}
                  GLOBAL_TARGETS libhipcxx::libhipcxx
                  CPM_ARGS
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow}
                  PATCH_COMMAND ${patch_command}
                  EXCLUDE_FROM_ALL ${exclude})

  include("${rapids-cmake-dir}/cpm/detail/display_patch_status.cmake")
  rapids_cpm_display_patch_status(libhipcxx)

  set(options)
  set(one_value BUILD_EXPORT_SET INSTALL_EXPORT_SET)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(libhipcxx_SOURCE_DIR AND _RAPIDS_BUILD_EXPORT_SET)
    # Store where CMake can find our custom libhipcxx
    include("${rapids-cmake-dir}/export/find_package_root.cmake")
    rapids_export_find_package_root(BUILD libhipcxx "${libhipcxx_SOURCE_DIR}/lib/cmake"
                                    EXPORT_SET ${_RAPIDS_BUILD_EXPORT_SET})
  endif()

  if(libhipcxx_SOURCE_DIR AND _RAPIDS_INSTALL_EXPORT_SET AND NOT exclude)
    # By default if we allow libhipcxx to install into `CMAKE_INSTALL_INCLUDEDIR` alongside rmm (or
    # other packages) we will get a install tree that looks like this:

    # install/include/rmm install/include/cub install/include/libhipcxx

    # This is a problem for CMake+NVCC due to the rules around import targets, and user/system
    # includes. In this case both rmm and libhipcxx will specify an include path of
    # `install/include`, while libhipcxx tries to mark it as an user include, since rmm uses
    # CMake's default of system include. Compilers when provided the same include as both user and
    # system always goes with system.

    # Now while rmm could also mark `install/include` as system this just pushes the issue to
    # another dependency which isn't built by RAPIDS and comes by and marks `install/include` as
    # system.

    # Instead the more reliable option is to make sure that we get libhipcxx to be placed in an
    # unique include path that the other project will use. In the case of rapids-cmake we install
    # the headers to `include/rapids/libhipcxx`
    include(GNUInstallDirs)
    set(CMAKE_INSTALL_INCLUDEDIR "${CMAKE_INSTALL_INCLUDEDIR}/rapids/libhipcxx")

    # libhipcxx 1.8 has a bug where it doesn't generate proper exclude rules for the
    # `[cub|libhipcxx]-header-search` files, which causes the build tree version to be installed
    # instead of the install version
    # TODO Change file names containing cudacxx to hipcxx when corresponding changes are
    # completed in libhipcxx
    if(NOT EXISTS "${libhipcxx_BINARY_DIR}/cmake/libhipcxxInstallRulesForRapids.cmake")
      file(READ "${libhipcxx_SOURCE_DIR}/cmake/libhipcxxInstallRules.cmake" contents)
      string(REPLACE "PATTERN cub-header-search EXCLUDE" "REGEX cub-header-search.* EXCLUDE"
                     contents "${contents}")
      string(REPLACE "PATTERN libhipcxx-header-search EXCLUDE"
                     "REGEX libhipcxx-header-search.* EXCLUDE" contents "${contents}")
      file(WRITE "${libhipcxx_BINARY_DIR}/cmake/libhipcxxInstallRulesForRapids.cmake" ${contents})
    endif()
    set(libhipcxx_ENABLE_INSTALL_RULES ON)
    include("${libhipcxx_BINARY_DIR}/cmake/libhipcxxInstallRulesForRapids.cmake")
  endif()

  # Propagate up variables that CPMFindPackage provide
  set(libhipcxx_SOURCE_DIR "${libhipcxx_SOURCE_DIR}" PARENT_SCOPE)
  set(libhipcxx_BINARY_DIR "${libhipcxx_BINARY_DIR}" PARENT_SCOPE)
  set(libhipcxx_ADDED "${libhipcxx_ADDED}" PARENT_SCOPE)
  set(libhipcxx_VERSION ${version} PARENT_SCOPE)

  if (HIP_AS_CUDA)
    set(libcudacxx_SOURCE_DIR "${libhipcxx_SOURCE_DIR}" PARENT_SCOPE)
    set(libcudacxx_BINARY_DIR "${libhipcxx_BINARY_DIR}" PARENT_SCOPE)
    set(libcudacxx_ADDED "${libhipcxx_ADDED}" PARENT_SCOPE)
    set(libcudacxx_VERSION ${version} PARENT_SCOPE)
  endif()

endfunction()

if (HIP_AS_CUDA)
  function(rapids_cpm_libcudacxx)
    rapids_cpm_libhipcxx(${ARGN})
  endfunction()
endif()
