#=============================================================================
# Copyright (c) 2022-2023, NVIDIA CORPORATION.
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
rapids_test_generate_resource_spec
----------------------------------

.. versionadded:: v23.04.00

Generates a JSON resource specification file representing the machine's GPUs
using system introspection.

  .. code-block:: cmake

    rapids_test_generate_resource_spec( DESTINATION filepath )

Generates a JSON resource specification file representing the machine's GPUs
using system introspection. This will allow CTest to schedule multiple
single-GPU tests in parallel on multi-GPU machines.

For the majority of projects :cmake:command:`rapids_test_init` should be used.
This command should be used directly projects that require multiple spec
files to be generated.

``DESTINATION``
  Location that the JSON output from the detection should be written to

.. note::
    Unlike rapids_test_init this doesn't set CTEST_RESOURCE_SPEC_FILE

#]=======================================================================]
function(rapids_test_generate_resource_spec DESTINATION filepath)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.test.generate_resource_spec")

  if(NOT DEFINED CMAKE_CUDA_COMPILER AND NOT DEFINED CMAKE_CXX_COMPILER)
    message(FATAL_ERROR "rapids_test_generate_resource_spec Requires the CUDA or C++ language to be enabled."
    )
  endif()

  set(gpu_json_contents
      [=[
{
"version": {"major": 1, "minor": 0},
"local": [{
  "gpus": [{"id":"0", "slots": 0}]
}]
}
]=])

  # TODO device dependent
  include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/detail/default_names.cmake)
  set(eval_file ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/detail/generate_resource_spec.cpp)
  set(eval_exe ${PROJECT_BINARY_DIR}/rapids-cmake/${rapids_test_generate_exe_name})
  set(error_file ${PROJECT_BINARY_DIR}/rapids-cmake/detect_gpus.stderr.log)

  if(NOT EXISTS "${eval_exe}")
    file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/rapids-cmake/")
    find_package(HIP QUIET)
    if (HIP_FOUND)
      if (HIP_PLATFORM STREQUAL "amd")
        set(compile_options "-I${HIP_INCLUDE_DIRS}" "-DHAVE_HIP" "-D__HIP_PLATFORM_AMD__=1 -D__HIP_PLATFORM_HCC__=1")
        set(link_options "-L${hip_LIB_INSTALL_DIR} -lamdhip64")
        set(compiler "${CMAKE_CXX_COMPILER}")
        if(NOT DEFINED CMAKE_CXX_COMPILER)
          set(compiler "${CMAKE_HIP_COMPILER}")
        endif()
      elseif (HIP_PLATFORM STREQUAL "nvidia")
        set(compile_options "-I${HIP_INCLUDE_DIRS}" "-DHAVE_HIP" "-D__HIP_PLATFORM_NVIDIA__=1 -D__HIP_PLATFORM_NVCC__=1")
        find_package(CUDAToolkit QUIET)
        set(link_options ${CUDA_cudart_LIBRARY})
        set(compiler "${CMAKE_CXX_COMPILER}")
        if(NOT DEFINED CMAKE_CXX_COMPILER)
          set(compiler "${CMAKE_CUDA_COMPILER}")
        endif()
      endif()
    endif()

    execute_process(COMMAND "${compiler}" "${eval_file}" ${compile_options} ${link_options} -o
                            "${eval_exe}" OUTPUT_VARIABLE compile_output
                    ERROR_VARIABLE compile_output)
  endif()

  if(NOT EXISTS "${eval_exe}")
    message(STATUS "rapids_test_generate_resource_spec failed to build detection executable, presuming no GPUs."
    )
    message(STATUS "rapids_test_generate_resource_spec compile[${compiler} ${compile_options} ${link_options}] failure details are ${compile_output}"
    )
    file(WRITE "${filepath}" "${gpu_json_contents}")
  else()
    execute_process(COMMAND ${eval_exe} OUTPUT_FILE "${filepath}")
  endif()

endfunction()
