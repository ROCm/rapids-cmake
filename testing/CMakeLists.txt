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

cmake_minimum_required(VERSION 3.23.1 FATAL_ERROR)
project(rapids-cmake-testing LANGUAGES NONE)

enable_testing()
include(utils/cmake_config_test.cmake)
include(utils/cmake_ctest_test.cmake)
include(utils/cmake_build_test.cmake)

option(CUDA_BACKEND "Use the CUDA backend" FALSE)

add_subdirectory(cmake)
add_subdirectory(${RAPIDS_CMAKE_PLATFORM})
add_subdirectory(export)
add_subdirectory(find)

include("${CMAKE_CURRENT_SOURCE_DIR}/utils/determine_gpu_count.cmake")
determine_gpu_count()
add_subdirectory(test)

option(RAPIDS_CMAKE_ENABLE_DOWNLOAD_TESTS "Enable tests that require downloads" ON)
if(RAPIDS_CMAKE_ENABLE_DOWNLOAD_TESTS)
  # Setup and fill the cpm cache, and specify CPM_SOURCE_CACHE
  # so that all subsequent tests in this directory use the
  # shared CPM_SOURCE_CACHE
  include("${CMAKE_CURRENT_SOURCE_DIR}/utils/setup_cpm_cache.cmake")
  setup_cpm_cache()

  add_subdirectory(cpm)
  add_subdirectory(cython)
  add_subdirectory(cython-core)
  add_subdirectory(other)
endif()
