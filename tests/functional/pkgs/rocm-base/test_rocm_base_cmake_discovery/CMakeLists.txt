cmake_minimum_required(VERSION 3.20)

project(rocm_base_package_discovery LANGUAGES C CXX)

find_package(ROCmCMakeBuildTools CONFIG REQUIRED)

set(ROCM_CONFIG_PACKAGES
    AMDDeviceLibs
    amd_comgr
    hsa-runtime64
    hip
    rocprofiler-register
    rocblas
    hipblas-common
    hipblas
    rocsolver
    rocsparse
    rocprim
)

foreach(package IN LISTS ROCM_CONFIG_PACKAGES)
    message(STATUS "Discovering ROCm CMake package: ${package}")
    find_package(${package} CONFIG REQUIRED)
endforeach()

message(STATUS "ROCm base CMake package discovery: PASS")
