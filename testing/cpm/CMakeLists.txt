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
add_cmake_config_test( rapids-cpm.cmake )

add_cmake_config_test( cpm_find-add-pkg-source )
add_cmake_config_test( cpm_find-and-find_package )
add_cmake_config_test( cpm_find-components )
add_cmake_config_test( cpm_find-existing-build-dir )
add_cmake_config_test( cpm_find-existing-target )
add_cmake_config_test( cpm_find-existing-target-to-export-sets )
add_cmake_config_test( cpm_find-gtest-no-gmock )
add_cmake_config_test( cpm_find-options-escaped )
add_cmake_config_test( cpm_find-patch-command NO_CPM_CACHE)
add_cmake_config_test( cpm_find-restore-cpm-vars )
if(CUDA_BACKEND)
add_cmake_config_test( cpm_find-version-explicit-install.cmake )
endif()

add_cmake_build_test( cpm_generate_pins-format-patches NO_CPM_CACHE)
add_cmake_build_test( cpm_generate_pins-nested NO_CPM_CACHE)
add_cmake_build_test( cpm_generate_pins-no-src-dir )
add_cmake_build_test( cpm_generate_pins-override NO_CPM_CACHE)
add_cmake_build_test( cpm_generate_pins-pure-cpm )
add_cmake_build_test( cpm_generate_pins-simple NO_CPM_CACHE)
add_cmake_build_test( cpm_generate_pins-simple-via-variable NO_CPM_CACHE)
add_cmake_build_test( cpm_generate_pins-var-and-arg NO_CPM_CACHE)

add_cmake_config_test( cpm_init-bad-default-path.cmake SHOULD_FAIL "rapids_cpm_init can't load")
add_cmake_config_test( cpm_init-bad-default-cmake-var.cmake SHOULD_FAIL "rapids_cpm_init can't load")
add_cmake_config_test( cpm_init-bad-override-path.cmake SHOULD_FAIL "rapids_cpm_package_override can't load")
if(CUDA_BACKEND)
add_cmake_config_test( cpm_init-bad-override-cmake-var.cmake SHOULD_FAIL "rapids_cpm_package_override can't load")
add_cmake_config_test( cpm_init-custom-default-simple.cmake)
add_cmake_config_test( cpm_init-custom-default-multiple.cmake)
add_cmake_config_test( cpm_init-custom-default-via-cmake-var.cmake)
add_cmake_config_test( cpm_init-override-simple.cmake)
add_cmake_config_test( cpm_init-override-multiple.cmake)
add_cmake_config_test( cpm_init-override-via-cmake-var.cmake)
endif()
add_cmake_config_test( cpm_package_override-add-new-project.cmake )
add_cmake_config_test( cpm_package_override-bad-path.cmake SHOULD_FAIL "rapids_cpm_package_override can't load")
add_cmake_config_test( cpm_package_override-before-init.cmake )
add_cmake_config_test( cpm_package_override-empty.cmake )
add_cmake_config_test( cpm_package_override-empty-patches.cmake )
add_cmake_config_test( cpm_package_override-env-var-support.cmake )
if(CUDA_BACKEND)
add_cmake_config_test( cpm_package_override-multiple.cmake )
add_cmake_config_test( cpm_package_override-no-version-value.cmake SHOULD_FAIL "rapids_cmake can't parse")
add_cmake_config_test( cpm_package_override-obey-cpm-source-var.cmake )
endif()
add_cmake_config_test( cpm_package_override-patches.cmake )
add_cmake_config_test( cpm_package_override-simple.cmake )

add_cmake_config_test( cpm_generate_patch_command-invalid.cmake )
add_cmake_config_test( cpm_generate_patch_command-override.cmake )
add_cmake_config_test( cpm_generate_patch_command-current_json_dir.cmake )
add_cmake_config_test( cpm_generate_patch_command-verify-copyright-header.cmake )

add_cmake_config_test( cpm_cccl-simple.cmake )
add_cmake_config_test( cpm_cccl-export.cmake )
add_cmake_build_test( cpm_cccl-preserve-custom-install-loc )

if(CUDA_BACKEND)
add_cmake_config_test( cpm_cuco-simple.cmake )
add_cmake_config_test( cpm_cuco-export.cmake )
add_cmake_config_test( cpm_cuco-libcudacxx-no-install-export.cmake )
else()
add_cmake_config_test( cpm_hipco-simple.cmake )
add_cmake_config_test( cpm_hipco-export.cmake )
add_cmake_config_test( cpm_hipco-libhipcxx-no-install-export.cmake )
endif()

add_cmake_config_test( cpm_fmt-export.cmake )
add_cmake_config_test( cpm_fmt-simple.cmake )
add_cmake_build_test( cpm_fmt-static-lib.cmake )

add_cmake_config_test( cpm_gbench-export.cmake )
add_cmake_config_test( cpm_gbench-simple.cmake )
add_cmake_config_test( cpm_gbench-explicit-static.cmake)

add_cmake_config_test( cpm_gtest-export.cmake )
add_cmake_config_test( cpm_gtest-simple.cmake )
add_cmake_config_test( cpm_gtest-static.cmake )
add_cmake_config_test( cpm_gtest-explicit-static.cmake )

if(NOT CUDA_BACKEND)
add_cmake_config_test( cpm_libhipcxx-after_cpmfind.cmake )
add_cmake_config_test( cpm_libhipcxx-export.cmake )
add_cmake_config_test( cpm_libhipcxx-simple.cmake )

add_cmake_config_test( cpm_hipcomp-export.cmake )
add_cmake_config_test( cpm_hipcomp-simple.cmake )

else()
add_cmake_config_test( cpm_libcudacxx-after_cpmfind.cmake )
add_cmake_config_test( cpm_libcudacxx-export.cmake )
add_cmake_config_test( cpm_libcudacxx-simple.cmake )
add_cmake_build_test( cpm_libcudacxx-verify-install-custom-libdir )

add_cmake_config_test( cpm_nvbench-export.cmake SERIAL)
add_cmake_config_test( cpm_nvbench-simple.cmake SERIAL)
add_cmake_config_test( cpm_nvbench-already-found-fmt.cmake SERIAL)
add_cmake_build_test( cpm_nvbench-conda.cmake SERIAL)
add_cmake_build_test( cpm_nvbench-conda-fmt.cmake SERIAL)
add_cmake_config_test( cpm_nvbench-explicit-static.cmake SERIAL)

add_cmake_config_test( cpm_nvcomp-export.cmake )
add_cmake_config_test( cpm_nvcomp-proprietary-off.cmake )
add_cmake_config_test( cpm_nvcomp-proprietary-on.cmake )
add_cmake_config_test( cpm_nvcomp-simple.cmake )
add_cmake_config_test( cpm_nvcomp-invalid-arch.cmake )
add_cmake_config_test( cpm_nvcomp-always-download-proprietary_binary.cmake SERIAL)
add_cmake_config_test( cpm_nvcomp-override-clears-proprietary_binary.cmake SERIAL)
add_cmake_build_test( cpm_nvcomp-proprietary_binary-lib-location.cmake SERIAL NO_CPM_CACHE)

add_cmake_build_test( cpm_nvtx-build-config-works.cmake )
add_cmake_build_test( cpm_nvtx-install-config-works.cmake )
add_cmake_config_test( cpm_nvtx-export.cmake )
add_cmake_config_test( cpm_nvtx-simple.cmake )

add_cmake_config_test( cpm_proprietary-url-ctk-version-find-ctk.cmake )
add_cmake_config_test( cpm_proprietary-url-ctk-version.cmake )
add_cmake_config_test( cpm_proprietary-url-no-ctk-parsing.cmake )

add_cmake_config_test( cpm_rmm-export.cmake )
add_cmake_config_test( cpm_rmm-simple.cmake )
endif()

add_cmake_build_test( cpm_spdlog-external-fmt.cmake )
add_cmake_config_test( cpm_spdlog-export.cmake )
add_cmake_config_test( cpm_spdlog-simple.cmake )

if(NOT CUDA_BACKEND)
add_cmake_config_test( cpm_rocthrust-export.cmake )
add_cmake_config_test( cpm_rocthrust-simple.cmake )
else()
add_cmake_config_test( cpm_thrust-export.cmake )
add_cmake_config_test( cpm_thrust-simple.cmake )
add_cmake_build_test( cpm_thrust-verify-post-find-code )
endif()
