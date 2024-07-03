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

#[=======================================================================[.rst:
rapids_hip_patch_toolkit
---------------------------------

.. versionadded:: v22.10.00

Corrects missing dependencies in the HIP toolkit

  .. code-block:: cmake

    rapids_hip_patch_toolkit( )

For CMake versions 3.23.1-3, and 3.24.1 the dependencies
of cublas and cusolver targets are incorrect. This module must be called
from the same CMakeLists.txt as the first `find_project(HIPToolkit)` to
patch the targets.

.. note::
  :cmake:command:`rapids_cpm_find` will automatically call this module
  when asked to find the HIPToolkit.

#]=======================================================================]
function(rapids_hip_patch_toolkit)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.hip.patch_toolkit")

  # NOTE(HIP/AMD): Below is the original RAPIDS code:
  # get_directory_property(itargets IMPORTED_TARGETS)
  # if(CMAKE_VERSION VERSION_LESS 3.24.2)
  #   if(HIP::cublas IN_LIST itargets)
  #     target_link_libraries(HIP::cublas INTERFACE HIP::cublasLt)
  #   endif()

  #   if(HIP::cublas_static IN_LIST itargets)
  #     target_link_libraries(HIP::cublas_static INTERFACE HIP::cublasLt_static)
  #   endif()

  #   if(HIP::cusolver_static IN_LIST itargets)
  #     target_link_libraries(HIP::cusolver_static INTERFACE HIP::cusolver_lapack_static)
  #   endif()
  # endif()
endfunction()

if (HIP_AS_CUDA)
  function(rapids_cuda_patch_toolkit)
    rapids_hip_patch_toolkit()
  endfunction()
endif()
