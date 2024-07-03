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
cmake_minimum_required(VERSION 3.23.1)

if(DEFINED ENV{CTEST_RESOURCE_GROUP_COUNT})
  # cmake-lint: disable=E1120
  foreach(index RANGE 0 ${CTEST_RESOURCE_GROUP_COUNT})
    set(allocation $ENV{CTEST_RESOURCE_GROUP_${index}_GPUS})
    if(DEFINED allocation)
      # strings look like "id:value,slots:value" so let's make a super lazy parser by deleting `id:`
      # and replacing `,slots:` with `;` so we have a list with two items.
      string(REPLACE "id:" "" allocation "${allocation}")
      string(REPLACE ",slots:" ";" allocation "${allocation}")
      list(GET allocation 0 device_ids)
      # slots are the cmake test requirements term for what we call percent. So we can ignore the
      # second item in the list
      set(ENV{HIP_VISIBLE_DEVICES} ${device_ids})
      set(ENV{CUDA_VISIBLE_DEVICES} ${device_ids})
    endif()
  endforeach()
endif()
execute_process(COMMAND ${command_to_run} ${command_args} COMMAND_ECHO STDOUT
                        COMMAND_ERROR_IS_FATAL ANY)
