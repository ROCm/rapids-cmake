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
rapids_hip_init_architectures
-------------------------------

.. versionadded:: v21.06.00

Extends :cmake:variable:`CMAKE_HIP_ARCHITECTURES <cmake:variable:CMAKE_HIP_ARCHITECTURES>`
to include support for `ALL` and `NATIVE` to make HIP architecture compilation easier.

  .. code-block:: cmake

    rapids_hip_init_architectures(<project_name>)

Used before enabling the HIP language either via :cmake:command:`project() <cmake:command:project>` to establish the
HIP architectures to be compiled for. Parses the :cmake:variable:`CMAKE_HIP_ARCHITECTURES <cmake:variable:CMAKE_HIP_ARCHITECTURES>`
for special values `ALL`, `RAPIDS`, `NATIVE` and `""`.

.. note::
  Required to be called before the first :cmake:command:`project() <cmake:command:project>` call.

  Will automatically call :cmake:command:`rapids_hip_set_architectures` immediately
  after :cmake:command:`project() <cmake:command:project>` with the same project name establishing
  the correct values for :cmake:variable:`CMAKE_HIP_ARCHITECTURES <cmake:variable:CMAKE_HIP_ARCHITECTURES>`.

``project_name``
  Name of the project in the subsequent :cmake:command:`project() <cmake:command:project>` call.

.. include:: supported_hip_architectures_values.txt

Example on how to properly use :cmake:command:`rapids_hip_init_architectures`:

.. code-block:: cmake

  cmake_minimum_required(...)

  if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/EXAMPLE_RAPIDS.cmake)
    file(DOWNLOAD https://raw.githubusercontent.com/ROCm/rapids-cmake/branch-<VERSION_MAJOR>.<VERSION_MINOR>/RAPIDS.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/EXAMPLE_RAPIDS.cmake)
  endif()
  include(${CMAKE_CURRENT_BINARY_DIR}/EXAMPLE_RAPIDS.cmake)
  include(rapids-hip)

  rapids_hip_init_architectures(ExampleProject)
  project(ExampleProject ...)




#]=======================================================================]
# cmake-lint: disable=W0105
function(rapids_hip_init_architectures project_name)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.hip.init_architectures")
  # If `CMAKE_HIP_ARCHITECTURES` is not defined, build for all supported architectures. If
  # `CMAKE_HIP_ARCHITECTURES` is set to an empty string (""), build for only the current
  # architecture. If `CMAKE_HIP_ARCHITECTURES` is specified by the user, use user setting.
  if(CMAKE_HIP_ARCHITECTURES STREQUAL "RAPIDS" OR CMAKE_HIP_ARCHITECTURES STREQUAL "ALL")
    set(hip_arch_mode "RAPIDS")
  elseif(CMAKE_HIP_ARCHITECTURES STREQUAL "" OR CMAKE_HIP_ARCHITECTURES STREQUAL "NATIVE")
    set(hip_arch_mode "NATIVE")
  elseif(NOT (DEFINED CMAKE_HIP_ARCHITECTURES))
    set(hip_arch_mode "RAPIDS")
  endif()

  # This needs to be run before enabling the HIP language since RAPIDS supports magic values like
  # `RAPIDS`, `ALL`, and `NATIVE` which if propagated cause CMake to fail to determine the HIP
  # compiler
  if(hip_arch_mode STREQUAL "RAPIDS")
    set(CMAKE_HIP_ARCHITECTURES OFF PARENT_SCOPE)
    set(load_file "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/detail/invoke_set_all_architectures.cmake")
  elseif(hip_arch_mode STREQUAL "NATIVE")
    set(CMAKE_HIP_ARCHITECTURES OFF PARENT_SCOPE)
    set(load_file "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/detail/invoke_set_native_architectures.cmake")
  endif()

  if(load_file)
    include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/set_architectures.cmake")

    # Setup to call to set CMAKE_HIP_ARCHITECTURES values to occur right after the project call
    # https://cmake.org/cmake/help/latest/command/project.html#code-injection
    #
    # If an existing file was specified for loading post `project` we will chain include them
    if(DEFINED CMAKE_PROJECT_${project_name}_INCLUDE)
      set(_RAPIDS_PREVIOUS_CMAKE_PROJECT_INCLUDE "${CMAKE_PROJECT_${project_name}_INCLUDE}"
          PARENT_SCOPE)
    endif()
    set(CMAKE_PROJECT_${project_name}_INCLUDE "${load_file}" PARENT_SCOPE)
  endif()

endfunction()

if (HIP_AS_CUDA)
  function(rapids_cuda_init_architectures project_name)
    rapids_hip_init_architectures(project_name)
    # TODO(HIP/AMD): Check if this is a good idea.
    set(CMAKE_CUDA_ARCHITECTURES ${CMAKE_HIP_ARCHITECTURES} PARENT_SCOPE)
  endfunction()
endif()
