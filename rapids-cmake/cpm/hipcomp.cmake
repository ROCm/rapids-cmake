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
rapids_cpm_hipcomp
-----------------
.. versionadded:: v22.06.00

Allow projects to find or build `hipcomp` via `CPM` with built-in
tracking of these dependencies for correct export support.

Uses the version of hipcomp :ref:`specified in the version file <cpm_versions>` for consistency
across all RAPIDS projects.

.. code-block:: cmake

  rapids_cpm_hipcomp( [USE_PROPRIETARY_BINARY <ON|OFF>]
                     [BUILD_EXPORT_SET <export-name>]
                     [INSTALL_EXPORT_SET <export-name>]
                     [<CPM_ARGS> ...])

.. note:
  If the option `HIP_AS_CUDA` is set, ``cuco_`` prefixed result variables are available too after calling this function.

.. |PKG_NAME| replace:: hipcomp
.. include:: common_package_args.txt

Result Targets
^^^^^^^^^^^^^^
  hipcomp::hipcomp and hipcomp targets will be created.

  nvcomp::nvcomp and nvcomp target may be created (only available if HIP_AS_CUDA option is set).

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`hipcomp_SOURCE_DIR` is set to the path to the source directory of hipcomp.
  :cmake:variable:`hipcomp_BINARY_DIR` is set to the path to the build directory of hipcomp.
  :cmake:variable:`hipcomp_ADDED`      is set to a true value if hipcomp has not been added before.
  :cmake:variable:`hipcomp_VERSION`    is set to the version of hipcomp specified by the versions.json.
  :cmake:variable:`hipcomp_proprietary_binary` is set to ON if the proprietary binary is being used
  :cmake:variable:`nvcomp_SOURCE_DIR` Same as ``hipcomp_``-prefixed variable (only available if HIP_AS_CUDA option is set).
  :cmake:variable:`nvcomp_BINARY_DIR` Same as ``hipcomp_``-prefixed variable (only available if HIP_AS_CUDA option is set).
  :cmake:variable:`nvcomp_ADDED`      Same as ``hipcomp_``-prefixed variable (only available if HIP_AS_CUDA option is set).
  :cmake:variable:`nvcomp_VERSION`    Same as ``hipcomp_``-prefixed variable (only available if HIP_AS_CUDA option is set).

#]=======================================================================]
# cmake-lint: disable=R0915
function(rapids_cpm_hipcomp)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.hipcomp")

  set(options)
  set(one_value USE_PROPRIETARY_BINARY BUILD_EXPORT_SET INSTALL_EXPORT_SET)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  # Fix up _RAPIDS_UNPARSED_ARGUMENTS to have EXPORT_SETS as this is need for rapids_cpm_find
  if(_RAPIDS_INSTALL_EXPORT_SET)
    list(APPEND _RAPIDS_UNPARSED_ARGUMENTS INSTALL_EXPORT_SET ${_RAPIDS_INSTALL_EXPORT_SET})
  endif()
  if(_RAPIDS_BUILD_EXPORT_SET)
    list(APPEND _RAPIDS_UNPARSED_ARGUMENTS BUILD_EXPORT_SET ${_RAPIDS_BUILD_EXPORT_SET})
  endif()

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(hipcomp version repository tag shallow exclude)
  set(to_exclude OFF)
  if(NOT _RAPIDS_INSTALL_EXPORT_SET OR exclude)
    set(to_exclude ON)
  endif()

  # first see if we have a proprietary pre-built binary listed in versions.json and it if requested.
  set(hipcomp_proprietary_binary OFF) # will be set to true by rapids_cpm_get_proprietary_binary
  if(_RAPIDS_USE_PROPRIETARY_BINARY)
    include("${rapids-cmake-dir}/cpm/detail/get_proprietary_binary.cmake")
    rapids_cpm_get_proprietary_binary(hipcomp ${version})

    # Record the hipcomp_DIR so that if USE_PROPRIETARY_BINARY is disabled we can safely clear the
    # hipcomp_DIR value
    if(hipcomp_proprietary_binary)
      set(hipcomp_proprietary_binary_dir "${hipcomp_ROOT}/lib/cmake/hipcomp")
      cmake_path(NORMAL_PATH hipcomp_proprietary_binary_dir)
      set(rapids_cpm_hipcomp_proprietary_binary_dir "${hipcomp_proprietary_binary_dir}"
          CACHE INTERNAL "hipcomp proprietary location")
    endif()
  elseif(DEFINED hipcomp_DIR)
    cmake_path(NORMAL_PATH hipcomp_DIR)
    if(hipcomp_DIR STREQUAL rapids_cpm_hipcomp_proprietary_binary_dir)
      unset(hipcomp_DIR)
      unset(hipcomp_DIR CACHE)
    endif()
  endif()

  include("${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake")
  rapids_cpm_generate_patch_command(hipcomp ${version} patch_command)

  # Apply any patch commands to the proprietary binary
  if(hipcomp_proprietary_binary AND patch_command)
    execute_process(COMMAND ${patch_command} WORKING_DIRECTORY ${hipcomp_ROOT})
  endif()

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(hipcomp ${version} ${_RAPIDS_UNPARSED_ARGUMENTS}
                  GLOBAL_TARGETS hipcomp::hipcomp
                  CPM_ARGS
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow}
                  EXCLUDE_FROM_ALL ${to_exclude}
                  PATCH_COMMAND ${patch_command}
                  OPTIONS "BUILD_STATIC ON" "BUILD_TESTS OFF" "BUILD_BENCHMARKS OFF"
                          "BUILD_EXAMPLES OFF")

  include("${rapids-cmake-dir}/cpm/detail/display_patch_status.cmake")
  rapids_cpm_display_patch_status(hipcomp)

  # provide consistent targets between a found hipcomp and one building from source
  if(NOT TARGET hipcomp::hipcomp AND TARGET hipcomp)
    add_library(hipcomp::hipcomp ALIAS hipcomp)
    set(hipcomp_orig hipcomp)
  elseif(TARGET hipcomp::hipcomp AND NOT TARGET hipcomp)
    add_library(hipcomp ALIAS hipcomp::hipcomp)
    set(hipcomp_orig hipcomp::hipcomp)
  endif()

  if (HIP_AS_CUDA)
    add_library(nvcomp::nvcomp ALIAS hipcomp_orig)
    add_library(nvcomp ALIAS hipcomp_orig)
  endif()

  # Propagate up variables that CPMFindPackage provide
  set(hipcomp_SOURCE_DIR "${hipcomp_SOURCE_DIR}" PARENT_SCOPE)
  set(hipcomp_BINARY_DIR "${hipcomp_BINARY_DIR}" PARENT_SCOPE)
  set(hipcomp_ADDED "${hipcomp_ADDED}" PARENT_SCOPE)
  set(hipcomp_VERSION ${version} PARENT_SCOPE)
  set(hipcomp_proprietary_binary ${hipcomp_proprietary_binary} PARENT_SCOPE)
  if (HIP_AS_CUDA)
    set(nvcomp_SOURCE_DIR "${hipcomp_SOURCE_DIR}" PARENT_SCOPE)
    set(nvcomp_BINARY_DIR "${hipcomp_BINARY_DIR}" PARENT_SCOPE)
    set(nvcomp_ADDED "${hipcomp_ADDED}" PARENT_SCOPE)
    set(nvcomp_VERSION ${version} PARENT_SCOPE)
    set(nvcomp_proprietary_binary ${hipcomp_proprietary_binary} PARENT_SCOPE)
  endif()

  # Set up up install rules when using the proprietary_binary. When building from source, hipcomp
  # will set the correct install rules
  include("${rapids-cmake-dir}/export/find_package_root.cmake")
  if(NOT to_exclude AND hipcomp_proprietary_binary)
    include(GNUInstallDirs)
    install(DIRECTORY "${hipcomp_ROOT}/lib/" DESTINATION lib)
    install(DIRECTORY "${hipcomp_ROOT}/include/" DESTINATION include)
    # place the license information in the location that conda uses
    install(FILES "${hipcomp_ROOT}/NOTICE" DESTINATION info/ RENAME HIPCOMP_NOTICE)
    install(FILES "${hipcomp_ROOT}/LICENSE" DESTINATION info/ RENAME HIPCOMP_LICENSE)
  endif()

  if(_RAPIDS_BUILD_EXPORT_SET AND hipcomp_proprietary_binary)
    # point our consumers to where they can find the pre-built version
    rapids_export_find_package_root(BUILD hipcomp "${hipcomp_ROOT}" ${_RAPIDS_BUILD_EXPORT_SET})
    if (HIP_AS_CUDA)
      rapids_export_find_package_root(BUILD nvcomp "${hipcomp_ROOT}" ${_RAPIDS_BUILD_EXPORT_SET})
    endif()
  endif()

endfunction()

if (HIP_AS_CUDA)
  function(rapids_cpm_nvcomp)
    rapids_cpm_hipcomp(${ARGN})
  endfunction()
endif()
