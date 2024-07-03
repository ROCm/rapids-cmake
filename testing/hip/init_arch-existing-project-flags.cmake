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
include(${rapids-cmake-dir}/hip/init_architectures.cmake)


# Verify that `ALL` logic works correctly
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/fileA.cmake" "set(file_A MAGIC_VALUE)")
set(CMAKE_PROJECT_example_INCLUDE "${CMAKE_CURRENT_BINARY_DIR}/fileA.cmake")

set(CMAKE_HIP_ARCHITECTURES "ALL")
rapids_hip_init_architectures(example)

project(example LANGUAGES HIP)
enable_language(HIP)
if(NOT DEFINED file_A)
  message(FATAL_ERROR "rapids_hip_init_architectures can't overwrite existing `project()` include hooks")
endif()

# Verify that `NATIVE` logic works correctly
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/fileB.cmake" "set(file_B MAGIC_VALUE)")
set(CMAKE_PROJECT_example2_INCLUDE "${CMAKE_CURRENT_BINARY_DIR}/fileB.cmake")

set(CMAKE_HIP_ARCHITECTURES "NATIVE")
rapids_hip_init_architectures(example2)
project(example2 LANGUAGES HIP)

if(NOT DEFINED file_B)
  message(FATAL_ERROR "rapids_hip_init_architectures can't overwrite existing `project()` include hooks")
endif()
