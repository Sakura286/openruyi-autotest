# library-prefix = rocm-base
#
# Shared package list for ROCm base tests.
# Packages are installed by tmt via FMF require: and are not removed.

ROCM_BASE_PACKAGES=(
    gcc-c++
    cmake
    pciutils
    rocm-cmake
    hipcc
    rocm-device-libs
    rocm-comgr
    rocm-comgr-devel
    rocm-llvm-macros
    rocr-runtime
    rocr-runtime-devel
    rocm-hip
    rocm-hip-devel
    rocminfo
    rocm-smi
    rocm-smi-devel
    rocprofiler-register
    rocprofiler-register-devel
    rocblas
    rocblas-devel
    hipblas-common-devel
    hipblas
    hipblas-devel
    rocsolver
    rocsolver-devel
    rocsparse
    rocsparse-devel
    rocprim-devel
    hipify
    rocm-bandwidth-test
    python-tensile
)
