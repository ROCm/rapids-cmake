# RAPIDS CMake Testing for HIP/CUDA

## Synopsis

This is a collection of CMake tests to verify that rapids-cmake works as
expected.

## Requirements

- ROCM installation (or CUDA installation)
- PNG Library ( for find_package tests )
- ZLIB Library ( for find_package tests )

## Invocation

1. Set your GitHub user and password/token:

   ```bash
   export GITHUB_USER=<github_ubser
   export GITHUB_PASS=<github_pw_or_token>
   ```
3. Run tests:

   1. HIP platform:

      ```bash
      export CMAKE_PREFIX_PATH="/opt/rocm/hip/lib/cmake;/opt/rocm/lib/cmake"
      cmake ../
      ```
   1. CUDA platform:

      ```bash
      cmake ../ -DCUDA_BACKEND=ON
      ```
