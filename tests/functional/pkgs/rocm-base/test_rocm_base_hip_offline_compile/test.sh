#!/bin/bash
# Functional test: compile HIP code without a GPU.

. /usr/share/beakerlib/beakerlib.sh || exit 1
. "$(dirname "$0")/../lib.sh"

GPU_ARCHITECTURES=(gfx1100 gfx1201)

ROCM_BASE_TEST_PACKAGES=(
    gcc-c++
    hipcc
    rocm-device-libs
    rocm-comgr
    rocm-comgr-devel
    rocr-runtime
    rocr-runtime-devel
    rocm-hip
    rocm-hip-devel
)

rlJournalStart
    rlPhaseStartSetup "Environment setup"
        rlRun "rocmBaseSetup \"\${ROCM_BASE_TEST_PACKAGES[@]}\"" 0 "Install ROCm packages"
        TmpDir=$(mktemp -d)
        rlRun "cp $(dirname "$0")/vector_add.cpp $TmpDir/" 0 "Copy vector_add.cpp"
        rlRun "cd $TmpDir" 0 "Enter temporary directory"
        rlRun "hipcc --version" 0 "Print hipcc version"
    rlPhaseEnd

    rlPhaseStartTest "Compile and inspect AMDGPU code objects"
        for architecture in "${GPU_ARCHITECTURES[@]}"; do
            executable="vector_add_$architecture"
            rlRun "hipcc --offload-arch='$architecture' vector_add.cpp -o '$executable'" 0 \
                "Compile vector add for $architecture"

            rlRun "ldd '$executable' > 'ldd_$architecture.txt'" 0 \
                "Resolve dependencies for $architecture"
            rlAssertNotGrep "not found" "ldd_$architecture.txt"

            rlRun "roc-obj-ls '$executable' > 'code_objects_$architecture.txt'" 0 \
                "List code objects for $architecture"
            rlAssertGrep "amdgcn-amd-amdhsa--$architecture" "code_objects_$architecture.txt"
        done
    rlPhaseEnd

    rlPhaseStartCleanup "Clean up test environment"
        rlRun "cd /" 0 "Leave temporary directory"
        if [ -n "$TmpDir" ] && [ -d "$TmpDir" ]; then
            rlRun "rm -rf $TmpDir" 0 "Remove temporary files"
        fi
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
