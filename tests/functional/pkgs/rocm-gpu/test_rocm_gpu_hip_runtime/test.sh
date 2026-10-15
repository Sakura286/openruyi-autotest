#!/bin/bash
# Compile and run a HIP vector add on one AMD GPU.

. /usr/share/beakerlib/beakerlib.sh || exit 1
. "$(dirname "$0")/../lib.sh"

ROCM_GPU_TEST_PACKAGES=(
    gcc-c++
    hipcc
    rocm-device-libs
    rocr-runtime
    rocm-hip
    rocm-hip-devel
    rocminfo
)

rlJournalStart
    rlPhaseStartSetup "Environment setup"
        rlRun "rocmGpuSetup \"\${ROCM_GPU_TEST_PACKAGES[@]}\"" 0 "Install ROCm packages"
        TmpDir=$(mktemp -d)
        rlRun "cp $(dirname "$0")/vector_add.cpp $TmpDir/" 0 \
            "Copy HIP source"
        rlRun "cd $TmpDir" 0
        rlRun "rocminfo > rocminfo.txt 2>&1" 0 "Query GPU"
        rlRun "grep -E '^[[:space:]]*Name:[[:space:]]+gfx[0-9]+' rocminfo.txt | awk '{print \$2}' | head -n 1 > gpu-architecture.txt" 0 \
            "Find GPU architecture"
        rlRun "test -s gpu-architecture.txt" 0 "Check for a GPU architecture"
        GPU_ARCH=$(cat gpu-architecture.txt)
        rlLogInfo "GPU architecture: $GPU_ARCH"
    rlPhaseEnd

    rlPhaseStartTest "Compile and run HIP vector addition"
        rlRun "hipcc --version" 0 "Print hipcc version"
        rlRun "hipcc --offload-arch='$GPU_ARCH' vector_add.cpp -o vector_add" 0 \
            "Compile HIP vector add"
        rlRun "./vector_add > run.txt 2>&1" 0 \
            "Run HIP vector add"
        rlRun "cat run.txt" 0 "Print HIP output"
        rlAssertGrep "HIP vector add: PASS" run.txt
        rlAssertGrep "arch=$GPU_ARCH" run.txt
    rlPhaseEnd

    rlPhaseStartCleanup "Clean up test environment"
        rlRun "cd /" 0
        if [ -n "$TmpDir" ] && [ -d "$TmpDir" ]; then
            rlRun "rm -rf $TmpDir" 0 "Remove temporary files"
        fi
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
