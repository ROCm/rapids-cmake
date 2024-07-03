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
add_cmake_config_test( rapids-hip.cmake )

add_cmake_config_test( init_runtime-existing.cmake )
add_cmake_config_test( init_runtime-multiple.cmake )
add_cmake_config_test( init_runtime-shared.cmake )
add_cmake_config_test( init_runtime-static.cmake )

add_cmake_config_test( init_arch-all-via-undef )
add_cmake_config_test( init_arch-all-via-env.cmake )
add_cmake_config_test( init_arch-all.cmake )
add_cmake_config_test( init_arch-existing-project-flags.cmake )
add_cmake_config_test( init_arch-native.cmake )
add_cmake_config_test( init_arch-native-via-empty-str )
add_cmake_config_test( init_arch-native-via-env.cmake )
add_cmake_config_test( init_arch-rapids.cmake )
#add_cmake_config_test( init_arch-rapids-via-env.cmake )
add_cmake_config_test( init_arch-user.cmake )
#add_cmake_config_test( init_arch-user-via-env.cmake )

add_cmake_config_test( patch_toolkit.cmake )
add_cmake_config_test( patch_toolkit-nested )

add_cmake_config_test( set_arch-all.cmake )
add_cmake_config_test( set_arch-existing.cmake )
add_cmake_config_test( set_arch-invalid-mode.cmake )
add_cmake_config_test( set_arch-native.cmake )
add_cmake_config_test( set_arch-rapids.cmake )
