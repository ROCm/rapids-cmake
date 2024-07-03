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
rapids_test_record_install
--------------------------

.. versionadded:: v23.04.00

Record that the provided target should have install rules specified when
:cmake:command:`rapids_test_install_relocatable` is called with the given component.

  .. code-block:: cmake

    rapids_test_record_install(TARGET <name> COMPONENT <set>)

#]=======================================================================]
function(rapids_test_record_install)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.test.record_install")

  set(options)
  set(one_value TARGET COMPONENT)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS_TEST "${options}" "${one_value}" "${multi_value}" ${ARGN})

  set(component ${_RAPIDS_TEST_COMPONENT})
  set_property(TARGET rapids_test_install_${component} APPEND PROPERTY TARGETS_TO_INSTALL
                                                                       "${_RAPIDS_TEST_TARGET}")
endfunction()
