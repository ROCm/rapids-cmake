#=============================================================================
# Copyright (c) 2022, NVIDIA CORPORATION.
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
rapids_cpm_hipco
---------------------

.. versionadded:: v22.08.00

Allow projects to find or build `hipcollections` via `CPM` with built-in
tracking of these dependencies for correct export support.

Uses the version of hipcollections :ref:`specified in the version file <cpm_versions>` for consistency
across all RAPIDS projects.

.. note::

  If the option `HIP_AS_CUDA` is set, ``cuco``-prefixed result variables and targets are available too after calling this function.

.. code-block:: cmake

  rapids_cpm_hipco( [BUILD_EXPORT_SET <export-name>]
                   [INSTALL_EXPORT_SET <export-name>]
                   [<CPM_ARGS> ...])

.. |PKG_NAME| replace:: hipco
.. include:: common_package_args.txt

Result Targets
^^^^^^^^^^^^^^

hipco::hipco target will be created.
cuco::cuco alias target for hipco::hipco will be created (only available if HIP_AS_CUDA option is set).

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`hipco_SOURCE_DIR` is set to the path to the source directory of hipco.
  :cmake:variable:`hipco_BINARY_DIR` is set to the path to the build directory of hipco.
  :cmake:variable:`hipco_ADDED`      is set to a true value if hipco has not been added before.
  :cmake:variable:`hipco_VERSION`    is set to the version of hipco specified by the versions.json.
  :cmake:variable:`cuco_SOURCE_DIR` Same as ``hipco_``-prefixed variable (only available if HIP_AS_CUDA option is set).
  :cmake:variable:`cuco_BINARY_DIR` Same as ``hipco_``-prefixed variable (only available if HIP_AS_CUDA option is set).
  :cmake:variable:`cuco_ADDED`      Same as ``hipco_``-prefixed variable (only available if HIP_AS_CUDA option is set).
  :cmake:variable:`cuco_VERSION`    Same as ``hipco_``-prefixed variable (only available if HIP_AS_CUDA option is set).

#]=======================================================================]

function(rapids_cpm_hipco)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.hipco")

  set(options)
  set(one_value INSTALL_EXPORT_SET)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  # Fix up _RAPIDS_UNPARSED_ARGUMENTS to have INSTALL_EXPORT_SET as this is need for rapids_cpm_find
  set(to_install OFF)
  if(_RAPIDS_INSTALL_EXPORT_SET)
    list(APPEND _RAPIDS_UNPARSED_ARGUMENTS INSTALL_EXPORT_SET ${_RAPIDS_INSTALL_EXPORT_SET})
    set(to_install ON)
  endif()

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(hipco version repository tag shallow exclude)

  set(to_exclude OFF)
  if(NOT to_install OR exclude)
    set(to_exclude ON)
  endif()

  include("${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake")
  rapids_cpm_generate_patch_command(hipco ${version} patch_command)

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(hipco ${version} ${_RAPIDS_UNPARSED_ARGUMENTS}
                  GLOBAL_TARGETS hipco::hipco
                  CPM_ARGS
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow}
                  PATCH_COMMAND ${patch_command}
                  EXCLUDE_FROM_ALL ${to_exclude}
                  OPTIONS "BUILD_TESTS OFF" "BUILD_BENCHMARKS OFF" "BUILD_EXAMPLES OFF"
                          "INSTALL_HIPCO ${to_install}")

  if (HIP_AS_CUDA)
    if (NOT TARGET cuco::cuco)
      get_property(hipco_orig TARGET hipco::hipco PROPERTY ALIASED_TARGET)
      if ("${hipco_orig}" STREQUAL "")
        add_library(cuco::cuco ALIAS hipco::hipco)
      else()
        add_library(cuco::cuco ALIAS "${hipco_orig}")
      endif()
    endif()
  endif()

  include("${rapids-cmake-dir}/cpm/detail/display_patch_status.cmake")
  rapids_cpm_display_patch_status(hipco)

  # Propagate up variables that CPMFindPackage provide
  set(hipco_SOURCE_DIR "${hipco_SOURCE_DIR}" PARENT_SCOPE)
  set(hipco_BINARY_DIR "${hipco_BINARY_DIR}" PARENT_SCOPE)
  set(hipco_ADDED "${hipco_ADDED}" PARENT_SCOPE)
  set(hipco_VERSION ${version} PARENT_SCOPE)

  if (HIP_AS_CUDA)
    set(cuco_SOURCE_DIR "${hipco_SOURCE_DIR}" PARENT_SCOPE)
    set(cuco_BINARY_DIR "${hipco_BINARY_DIR}" PARENT_SCOPE)
    set(cuco_ADDED "${hipco_ADDED}" PARENT_SCOPE)
    set(cuco_VERSION ${version} PARENT_SCOPE)
  endif()

endfunction()

if (HIP_AS_CUDA)
  function(rapids_cpm_cuco)
    rapids_cpm_hipco(${ARGN})
  endfunction()
endif()
