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
rapids_hip_set_architectures
-------------------------------

.. versionadded:: v21.06.00

Sets up :cmake:variable:`CMAKE_HIP_ARCHITECTURES` based on the requested mode

.. code-block:: cmake

  rapids_hip_set_architectures( (NATIVE|ALL|RAPIDS) )


.. note::

   Specifying "ALL" and "RAPIDS" has the same effect.

Establishes what HIP architectures that will be compiled for, overriding
any existing :cmake:variable:`CMAKE_HIP_ARCHITECTURES` value.

This function should rarely be used, as :cmake:command:`rapids_hip_init_architectures`
allows for the expected workflow of using :cmake:variable:`CMAKE_HIP_ARCHITECTURES`
when configuring a project. If for some reason your project can't use
:cmake:command:`rapids_hip_init_architectures` then you can use :cmake:command:`rapids_hip_set_architectures`
directly.

.. note::
  
   This is automatically called by :cmake:command:`rapids_hip_init_architectures`

.. include:: supported_hip_architectures_values.txt

Result Variables
^^^^^^^^^^^^^^^^

  ``CMAKE_HIP_ARCHITECTURES`` will exist and set to the list of architectures
  that should be compiled for. Will overwrite any existing values.

#]=======================================================================]
function(rapids_hip_set_architectures mode)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.hip.set_architectures")

  # we limit the ALL=RAPIDS mde to 
  set(supported_archs gfx908 gfx90a gfx940 gfx941 gfx942)

  if(${mode} STREQUAL "RAPIDS" OR ${mode} STREQUAL "ALL")
    set(CMAKE_HIP_ARCHITECTURES ${supported_archs} PARENT_SCOPE)
  elseif(${mode} STREQUAL "NATIVE")
    include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/detail/detect_architectures.cmake)
    rapids_hip_detect_architectures(supported_archs CMAKE_HIP_ARCHITECTURES)

    set(CMAKE_HIP_ARCHITECTURES ${CMAKE_HIP_ARCHITECTURES} PARENT_SCOPE)
  endif()

endfunction()

if (HIP_AS_CUDA)
  function(rapids_cuda_set_architectures mode)
    rapids_hip_set_architectures(mode)
    set(CMAKE_CUDA_ARCHITECTURES ${CMAKE_HIP_ARCHITECTURES} PARENT_SCOPE)
  endfunction()
endif()
