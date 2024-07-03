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
add_cmake_config_test( rapids-export.cmake )

add_cmake_config_test( export_cpm-build-possible-dir.cmake )
add_cmake_config_test( export_cpm-build.cmake )
add_cmake_config_test( export_cpm-install.cmake )
add_cmake_config_test( export_cpm-options-escaped.cmake )

add_cmake_build_test( export-verify-build-components-dependencies )
add_cmake_build_test( export-verify-build-components-targets )
add_cmake_build_test( export-verify-build-multiple-export-sets-to-single-component )
add_cmake_build_test( export-verify-build-namespaces )
add_cmake_build_test( export-verify-code-block )
add_cmake_build_test( export-verify-doc-string )
add_cmake_build_test( export-verify-global-targets )
add_cmake_build_test( export-verify-install-components )
add_cmake_build_test( export-verify-no-namespace )

add_cmake_config_test( export-verify-bad-code-block-var.cmake SHOULD_FAIL "FINAL_CODE_BLOCK variable `var_doesn't_exist` doesn't exist")
add_cmake_config_test( export-verify-missing-components.cmake SHOULD_FAIL "is missing COMPONENTS as COMPONENTS_EXPORT_SET was provided")
add_cmake_config_test( export-verify-missing-components-export.cmake SHOULD_FAIL "is missing COMPONENTS_EXPOR22T_SET as COMPONENTS was provided")
add_cmake_config_test( export-verify-bad-doc-var.cmake SHOULD_FAIL "DOCUMENTATION variable `var_doesn't_exist` doesn't exist")
add_cmake_config_test( export-verify-calendar-version-matching.cmake )
add_cmake_config_test( export-verify-explicit-disabled-version.cmake )
add_cmake_config_test( export-verify-explicit-major-version-only-matching.cmake )
add_cmake_config_test( export-verify-explicit-patch-version-value-of-zero.cmake )
add_cmake_config_test( export-verify-explicit-version-all-zeros.cmake )
add_cmake_config_test( export-verify-explicit-version-value.cmake )
add_cmake_config_test( export-verify-file-names.cmake )
add_cmake_config_test( export-verify-implicit-disabled-version.cmake )
add_cmake_config_test( export-verify-implicit-major-version-only-matching.cmake )
add_cmake_config_test( export-verify-version.cmake )
add_cmake_config_test( export-verify-copyright-header.cmake )

add_cmake_config_test( export_component-build )

add_cmake_config_test( export_package-build-possible-dir.cmake )
add_cmake_config_test( export_package-build-post-find-code.cmake )
add_cmake_config_test( export_package-build-with-components-and-version.cmake )
add_cmake_config_test( export_package-build-with-components.cmake )
add_cmake_config_test( export_package-build-with-empty-components.cmake )
add_cmake_config_test( export_package-build-with-version.cmake )
add_cmake_config_test( export_package-build.cmake )
add_cmake_config_test( export_package-install-possible-dir.cmake )
add_cmake_config_test( export_package-install-post-find-code.cmake )
add_cmake_config_test( export_package-install-with-components-and-version.cmake )
add_cmake_config_test( export_package-install-with-components.cmake )
add_cmake_config_test( export_package-install-with-version.cmake )
add_cmake_config_test( export_package-install.cmake )
add_cmake_config_test( export_package-multiple-export_sets.cmake )

add_cmake_config_test( write_dependencies-cpm-preserve-options.cmake )
add_cmake_config_test( write_dependencies-duplicate-cpm.cmake )
add_cmake_config_test( write_dependencies-duplicate-packages.cmake )
add_cmake_config_test( write_dependencies-duplicate-cpm-and-package.cmake )
add_cmake_config_test( write_dependencies-multiple-directories )
add_cmake_config_test( write_dependencies-root-dirs.cmake )

if(CUDA_BACKEND)
add_cmake_build_test( write_language-multiple-nested-enables )
add_cmake_build_test( write_language-nested-dirs )
endif()

set(deprecated_message [=[rapids-cmake policy [deprecated=23.12 removed=24.02]: Usage of ]=])
add_cmake_config_test( find_package_file-deprecated.cmake SHOULD_FAIL "${deprecated_message}")
add_cmake_config_test( find_package_root-deprecated.cmake SHOULD_FAIL "${deprecated_message}")
