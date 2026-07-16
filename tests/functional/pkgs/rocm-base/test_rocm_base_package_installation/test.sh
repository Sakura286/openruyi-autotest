#!/bin/bash
# Functional test: verify that the openRuyi Base ROCm package set is installed.
# Package installation is performed by tmt from the currently enabled repos.

. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGES=(
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

rlJournalStart
    rlPhaseStartSetup "Record test environment"
        rlLogInfo "Host architecture: $(uname -m)"
        rlLogInfo "Kernel release: $(uname -r)"
    rlPhaseEnd

    rlPhaseStartTest "Verify ROCm package installation"
        for package in "${PACKAGES[@]}"; do
            rlRun "rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\\n' '$package'" 0 \
                "Query installed package $package"
        done
    rlPhaseEnd

    rlPhaseStartCleanup "No package cleanup required"
        rlLogInfo "Packages are managed by the tmt prepare phase"
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
