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

# Function uses the HIP runtime API to query the compute capability of the device, so if a user
# doesn't pass any architecture options to CMake we only build the current architecture
function(rapids_hip_detect_architectures possible_archs_var gpu_archs)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.hip.detect_architectures")

  # Unset this first in case it's set to <empty_string> Which can happen inside rapids
  set(CMAKE_HIP_ARCHITECTURES OFF)
  set(__gpu_archs ${${possible_archs_var}})

  set(eval_file ${PROJECT_BINARY_DIR}/eval_gpu_archs.cpp)
  set(eval_exe ${PROJECT_BINARY_DIR}/eval_gpu_archs)
  set(error_file ${PROJECT_BINARY_DIR}/eval_gpu_archs.stderr.log)

  if(NOT DEFINED CMAKE_HIP_COMPILER)
    message(FATAL_ERROR "No HIP compiler specified, unable to determine machine's GPUs.")
  endif()

  if(NOT EXISTS "${eval_exe}")
    file(WRITE ${eval_file}
         "
#include <cstdio>
#include <set>
#include <string>
#include <hip/hip_runtime_api.h>
using namespace std;
int main(int argc, char** argv) {
  set<string> archs;
  int nDevices;
  if((hipGetDeviceCount(&nDevices) == hipSuccess) && (nDevices > 0)) {
    for(int dev=0;dev<nDevices;++dev) {
      char buff[32];
      hipDeviceProp_t prop;
      if(hipGetDeviceProperties(&prop, dev) != hipSuccess) continue;
	 sprintf(buff, \"%s\", strtok(prop.gcnArchName, \":\")); //TODO(HIP/AMD): are there cases where full specification such as gfx90a:sramecc+:xnack- is desired?
      archs.insert(buff);
    }
  }
  if(archs.empty()) {
    printf(\"${__gpu_archs}\");
  } else {
    bool first = true;
    for(const auto& arch : archs) {
      printf(first? \"%s\" : \";%s\", arch.c_str());
      first = false;
    }
  }
  printf(\"\\n\");
  return 0;
  }
  ")
  execute_process(COMMAND ${CMAKE_HIP_COMPILER} -std=c++11 -D__HIP_PLATFORM_AMD__
    -I${CMAKE_HIP_COMPILER_ROCM_ROOT}/include -lamdhip64
    -L${CMAKE_HIP_COMPILER_ROCM_ROOT}/lib -o "${eval_exe}" "${eval_file}"
    ERROR_FILE "${error_file}")
  endif()

  if(EXISTS "${eval_exe}")
    execute_process(COMMAND "${eval_exe}" OUTPUT_VARIABLE __gpu_archs
                    OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_FILE "${error_file}")
    message(STATUS "Auto detection of gpu-archs: ${__gpu_archs}")
  else()
    message(STATUS "Failed auto detection of gpu-archs. Falling back to using ${__gpu_archs}.")
  endif()

  set(${gpu_archs} ${__gpu_archs} PARENT_SCOPE)

endfunction()
