#=============================================================================
# Copyright (c) 2021, NVIDIA CORPORATION.
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

#[=======================================================================[.rst:
rapids_cpm_hipbench
------------------

.. versionadded:: v21.10.00

Allow projects to find or build `hipbench` via `CPM` with built-in
tracking of these dependencies for correct export support.

Uses the version of hipbench :ref:`specified in the version file <cpm_versions>` for consistency
across all RAPIDS projects.

.. code-block:: cmake

  rapids_cpm_hipbench( [BUILD_EXPORT_SET <export-name>]
                      [<CPM_ARGS> ...])

``BUILD_EXPORT_SET``
  Record that a :cmake:command:`CPMFindPackage(nvbench)` call needs to occur as part of
  our build directory export set.

``CPM_ARGS``
  Any arguments after `CPM_ARGS` will be forwarded to the underlying :cmake:command:`CPMFindPackage(<PackageName> ...)` call

.. note::

  RAPIDS-cmake will error out if an INSTALL_EXPORT_SET is provided, as nvbench
  doesn't provide any support for installation.


.. note::

  Always sets both ``hipbench``- and ``nvbench``-prefixed variables and targets.
  In contrast to other projects, ``hipBench`` provides ``nvbench``-prefixed variable and target names instead
  of `hipbench``-prefixed ones.

Result Targets
^^^^^^^^^^^^^^
  ``hipbench::hipbench`` target will be created.
  ``hipbench::main`` target will be created.

  ``nvbench::nvbench`` target will be created.
  ``nvbench::main`` target will be created.

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`hipbench_SOURCE_DIR` is set to the path to the source directory of nvbench.
  :cmake:variable:`hipbench_BINARY_DIR` is set to the path to the build directory of  nvbench.
  :cmake:variable:`hipbench_ADDED`      is set to a true value if nvbench has not been added before.
  :cmake:variable:`hipbench_VERSION`    is set to the version of nvbench specified by the versions.json.
  :cmake:variable:`nvbench_SOURCE_DIR` Same as ``hipbench_``-prefixed variable (always created).
  :cmake:variable:`nvbench_BINARY_DIR` Same as ``hipbench_``-prefixed variable (always created).
  :cmake:variable:`nvbench_ADDED`      Same as ``hipbench_``-prefixed variable (always created).
  :cmake:variable:`nvbench_VERSION`    Same as ``hipbench_``-prefixed variable (always created).

#]=======================================================================]
function(rapids_cpm_hipbench)
  #: note(HIP/AMD): 
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.hipbench")

  set(to_install FALSE)
  if(INSTALL_EXPORT_SET IN_LIST ARGN)
    message(FATAL_ERROR "hipbench doesn't provide install rules.
            It can't be part of an INSTALL_EXPORT_SET")
  endif()

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(nvbench version repository tag shallow exclude)

  # CUDA::nvml is an optional package and might not be installed ( aka conda )
  #: find_package(CUDAToolkit REQUIRED)
  #: TODO(HIP/AMD): Lookup pyrsmi instead
  set(hipbench_with_nvml "OFF")
  #: if(TARGET CUDA::nvml)
  #:   set(hipbench_with_nvml "ON")
  #: endif()

  include("${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake")
  rapids_cpm_generate_patch_command(nvbench ${version} patch_command)

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(hipbench ${version} ${ARGN}
                  GLOBAL_TARGETS nvbench::nvbench nvbench::main
                  CPM_ARGS
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow}
                  PATCH_COMMAND ${patch_command}
                  EXCLUDE_FROM_ALL ${exclude}
                  OPTIONS "NVBench_ENABLE_NVML ${hipbench_with_nvml}" "NVBench_ENABLE_EXAMPLES OFF"
                          "NVBench_ENABLE_TESTING OFF")

  #: NOTE(HIP/AMD): also provide hip-prefixed targets
  add_library(hipbench::hipbench ALIAS nvbench::nvbench)
  add_library(hipbench::main ALIAS nvbench::main)

  include("${rapids-cmake-dir}/cpm/detail/display_patch_status.cmake")
  rapids_cpm_display_patch_status(nvbench)

  # Propagate up variables that CPMFindPackage provide
  set(nvbench_SOURCE_DIR "${nvbench_SOURCE_DIR}" PARENT_SCOPE)
  set(nvbench_BINARY_DIR "${nvbench_BINARY_DIR}" PARENT_SCOPE)
  set(nvbench_ADDED "${nvbench_ADDED}" PARENT_SCOPE)
  set(nvbench_VERSION ${version} PARENT_SCOPE)
  #: NOTE(HIP/AMD): also provide hip-prefixed variables
  set(hipbench_SOURCE_DIR "${nvbench_SOURCE_DIR}" PARENT_SCOPE)
  set(hipbench_BINARY_DIR "${nvbench_BINARY_DIR}" PARENT_SCOPE)
  set(hipbench_ADDED "${nvbench_ADDED}" PARENT_SCOPE)
  set(hipbench_VERSION ${version} PARENT_SCOPE)

  # nvbench creates the correct namespace aliases
endfunction()
