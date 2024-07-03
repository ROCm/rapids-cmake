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
rapids_cpm_rocthrust
--------------------

Allow projects to find or build `rocthrust` via `CPM` with built-in
tracking of these dependencies for correct export support.

  rapids_cpm_rocthrust([BUILD_EXPORT_SET <export-name>]
                     [INSTALL_EXPORT_SET <export-name>]
                     [<CPM_ARGS> ...])

.. |PKG_NAME| replace:: rocthrust
.. include:: common_package_args.txt

Result Targets
^^^^^^^^^^^^^^
  roc::rocthrust target will be created
  <namespace>::Thrust target will be created (only available if HIP_AS_CUDA option is set).

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`rocthrust_SOURCE_DIR` is set to the path to the source directory of rocthrust.
  :cmake:variable:`rocthrust_BINARY_DIR` is set to the path to the build directory of  rocthrust.
  :cmake:variable:`rocthrust_ADDED`      is set to a true value if rocthrust has not been added before.
  :cmake:variable:`rocthrust_VERSION`    is set to the version of rocthrust specified by the versions.json.
  :cmake:variable:`Thrust_SOURCE_DIR` Same as ``rocthrust_``-prefixed variable (only available if HIP_AS_CUDA option is set).
  :cmake:variable:`Thrust_BINARY_DIR` Same as ``rocthrust_``-prefixed variable (only available if HIP_AS_CUDA option is set).
  :cmake:variable:`Thrust_ADDED`      Same as ``rocthrust_``-prefixed variable (only available if HIP_AS_CUDA option is set).
  :cmake:variable:`Thrust_VERSION`    Same as ``rocthrust_``-prefixed variable (only available if HIP_AS_CUDA option is set).

#]=======================================================================]
# cmake-lint: disable=R0915
# TODO(HIP/AMD): Namespace support is not really sorted out yet.
function(rapids_cpm_rocthrust)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.rocthrust")

  set(options)
  set(one_value BUILD_EXPORT_SET INSTALL_EXPORT_SET)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(_RAPIDS_INSTALL_EXPORT_SET)
    list(APPEND _RAPIDS_UNPARSED_ARGUMENTS INSTALL_EXPORT_SET ${_RAPIDS_INSTALL_EXPORT_SET})
  endif()

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(rocthrust version repository tag shallow exclude)
  set(to_exclude OFF)
  if(NOT _RAPIDS_INSTALL_EXPORT_SET OR exclude)
    set(to_exclude ON)
  endif()

  include("${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake")
  rapids_cpm_generate_patch_command(rocthrust ${version} patch_command)

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(rocthrust ${version} ${ARGN} {_RAPIDS_UNPARSED_ARGUMENTS}
                  GLOBAL_TARGETS roc::rocthrust roc::rocprim_hip
                  CPM_ARGS FIND_PACKAGE_ARGUMENTS EXACT
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow}
                  PATCH_COMMAND ${patch_command}
                  EXCLUDE_FROM_ALL ${exclude}
                  OPTIONS "THRUST_ENABLE_INSTALL_RULES ${to_install}")

  if(NOT TARGET roc::rocthrust)
    message(FATAL_ERROR "Expected roc::rocthrust to exist")
  endif()

  if(NOT TARGET roc::rocprim_hip)
    message(FATAL_ERROR "Expected roc::rocthrust to exist")
  endif()

  include("${rapids-cmake-dir}/cpm/detail/display_patch_status.cmake")
  rapids_cpm_display_patch_status(rocthrust)

  # Propagate up variables that CPMFindPackage provide
  set(rocthrust_SOURCE_DIR "${rocthrust_SOURCE_DIR}" PARENT_SCOPE)
  set(rocthrust_BINARY_DIR "${rocthrust_BINARY_DIR}" PARENT_SCOPE)
  set(rocthrust_ADDED "${rocthrust_ADDED}" PARENT_SCOPE)
  set(rocthrust_VERSION ${version} PARENT_SCOPE)

  if (HIP_AS_CUDA)
    set(Thrust_SOURCE_DIR "${rocthrust_SOURCE_DIR}" PARENT_SCOPE)
    set(Thrust_BINARY_DIR "${rocthrust_BINARY_DIR}" PARENT_SCOPE)
    set(Thrust_ADDED "${rocthrust_ADDED}" PARENT_SCOPE)
    set(Thrust_VERSION ${version} PARENT_SCOPE)
  endif()

endfunction()

if (HIP_AS_CUDA)
  function(rapids_cpm_thrust NAMESPACE namespaces_name)
    rapids_cpm_rocthrust(${ARGN})

    add_library(${namespaces_name}::Thrust ALIAS rocthrust::rocthrust)
  endfunction()
endif()
