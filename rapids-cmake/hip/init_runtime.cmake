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
rapids_hip_init_runtime
-------------------------------

.. versionadded:: v21.06.00

Establish what HIP runtime library should be propagated

  .. code-block:: cmake

    rapids_hip_init_runtime( USE_STATIC (TRUE|FALSE) )

  Establishes what HIP runtime will be used, if not already explicitly
  specified, via the :cmake:variable:`CMAKE_HIP_RUNTIME_LIBRARY <cmake:variable:CMAKE_HIP_RUNTIME_LIBRARY>`
  variable. We also set :cmake:variable:`HIP_USE_STATIC_HIP_RUNTIME <cmake:module:FindHIP>` to control
  targets using the legacy `FindHIP.cmake`

  When `USE_STATIC TRUE` is provided all targets will link to a
    statically-linked HIP runtime library.

  When `USE_STATIC FALSE` is provided all targets will link to a
    shared-linked HIP runtime library.


#]=======================================================================]
function(rapids_hip_init_runtime use_static value)
  #: TODO(HIP/AMD): Do we ship a to-be-statically-linked HIP library?
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.hip.init_runtime")

  if(NOT DEFINED CMAKE_HIP_RUNTIME_LIBRARY)
    # TODO(HIP/AMD): No static libs in ROCm
    if(${value})
        message(FATAL_ERROR "Cannot use static runtime with HIP")
    #   set(CMAKE_HIP_RUNTIME_LIBRARY STATIC PARENT_SCOPE)
    else()
      set(CMAKE_HIP_RUNTIME_LIBRARY SHARED PARENT_SCOPE)
    endif()
  endif()

  # Control legacy FindHIP.cmake behavior too
  if(NOT DEFINED HIP_USE_STATIC_HIP_RUNTIME)
    # if(${value})
    #   set(HIP_USE_STATIC_HIP_RUNTIME ON PARENT_SCOPE)
    # else()
      set(HIP_USE_STATIC_HIP_RUNTIME OFF PARENT_SCOPE)
    # endif()
  endif()

endfunction()

if (HIP_AS_CUDA)
  function(rapids_cuda_init_runtime use_static value)
    rapids_hip_init_runtime(${use_static} ${value})
    # TODO(HIP/AMD): Check if this is a good idea.
    set(CMAKE_CUDA_RUNTIME_LIBRARY ${CMAKE_HIP_RUNTIME_LIBRARY} PARENT_SCOPE)
    set(CUDA_USE_STATIC_CUDA_RUNTIME ${HIP_USE_STATIC_HIP_RUNTIME} PARENT_SCOPE)
  endfunction()
endif()
