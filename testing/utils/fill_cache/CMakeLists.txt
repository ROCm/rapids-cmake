#=============================================================================
# Copyright (c) 2021-2024, NVIDIA CORPORATION.
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
cmake_minimum_required(VERSION 3.26.4)

project(fill_cache LANGUAGES CXX)

include(${rapids-cmake-dir}/cpm/init.cmake)

if(NOT CUDA_BACKEND)
include(${rapids-cmake-dir}/cpm/hipco.cmake)
include(${rapids-cmake-dir}/cpm/libhipcxx.cmake)
include(${rapids-cmake-dir}/cpm/hipbench.cmake)
include(${rapids-cmake-dir}/cpm/hipcomp.cmake)
include(${rapids-cmake-dir}/cpm/rocthrust.cmake)
else()
include(${rapids-cmake-dir}/cpm/cccl.cmake)
include(${rapids-cmake-dir}/cpm/cuco.cmake)
include(${rapids-cmake-dir}/cpm/libcudacxx.cmake)
include(${rapids-cmake-dir}/cpm/nvbench.cmake)
include(${rapids-cmake-dir}/cpm/nvcomp.cmake)
include(${rapids-cmake-dir}/cpm/nvtx3.cmake)
include(${rapids-cmake-dir}/cpm/thrust.cmake)
endif()
include(${rapids-cmake-dir}/cpm/gbench.cmake)
include(${rapids-cmake-dir}/cpm/gtest.cmake)
if(NOT
include(${rapids-cmake-dir}/cpm/hiprmm.cmake) CUDA_BACKEND)
else()
include(${rapids-cmake-dir}/cpm/rmm.cmake)
endif()
include(${rapids-cmake-dir}/cpm/spdlog.cmake)
include(${rapids-cmake-dir}/cpm/fmt.cmake)

rapids_cpm_init(GENERATE_PINNED_VERSIONS)

set(CPM_SOURCE_CACHE "${CMAKE_BINARY_DIR}")

# Download all source packages
set(CPM_DOWNLOAD_ALL "ON")
if(NOT CUDA_BACKEND)
rapids_cpm_hipco(DOWNLOAD_ONLY ON)
rapids_cpm_libhipcxx(DOWNLOAD_ONLY ON)
rapids_cpm_hipbench(DOWNLOAD_ONLY ON)
rapids_cpm_rocthrust(temp DOWNLOAD_ONLY ON)
else()
rapids_cpm_cccl(DOWNLOAD_ONLY ON)
rapids_cpm_cuco(DOWNLOAD_ONLY ON)
rapids_cpm_libcudacxx(DOWNLOAD_ONLY ON)
rapids_cpm_nvbench(DOWNLOAD_ONLY ON)
rapids_cpm_nvtx3(DOWNLOAD_ONLY ON)
rapids_cpm_thrust(temp DOWNLOAD_ONLY ON)
endif()
rapids_cpm_gbench(DOWNLOAD_ONLY ON)
rapids_cpm_gtest(DOWNLOAD_ONLY ON)
if(NOT CUDA_BACKEND)
rapids_cpm_hiprmm(DOWNLOAD_ONLY ON)
else()
rapids_cpm_rmm(DOWNLOAD_ONLY ON)
endif()
rapids_cpm_spdlog(DOWNLOAD_ONLY ON)
rapids_cpm_fmt(DOWNLOAD_ONLY ON)
rapids_cpm_find(skbuild 0.14.1
                GIT_REPOSITORY https://github.com/scikit-build/scikit-build.git
                GIT_TAG 0.14.1
                )

# Download all binary packages
set(CPM_DOWNLOAD_ALL "OFF")
if(CUDA_BACKEND)
rapids_cpm_nvcomp(USE_PROPRIETARY_BINARY ON DOWNLOAD_ONLY ON)
endif()
