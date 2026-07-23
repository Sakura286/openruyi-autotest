#!/bin/bash
# Functional test: compile and inspect HIP code without executing it on a GPU.

. /usr/share/beakerlib/beakerlib.sh || exit 1

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
GPU_ARCHITECTURES=(gfx1100 gfx1201)

rlJournalStart
    rlPhaseStartSetup "Prepare HIP source"
        TmpDir=$(mktemp -d)
        rlRun "cp '$SCRIPT_DIR/vector_add.cpp' '$TmpDir/'" 0 "Copy HIP source to a temporary directory"
        rlRun "cd '$TmpDir'" 0 "Enter temporary directory"
        rlRun "hipcc --version" 0 "Print hipcc version"
    rlPhaseEnd

    rlPhaseStartTest "Compile and inspect AMDGPU code objects"
        for architecture in "${GPU_ARCHITECTURES[@]}"; do
            executable="vector_add_$architecture"
            rlRun "hipcc --offload-arch='$architecture' vector_add.cpp -o '$executable'" 0 \
                "Compile HIP vector add for $architecture without GPU discovery"
            rlAssertExists "$executable"

            rlRun "file '$executable' > 'file_$architecture.txt'" 0 \
                "Inspect the host executable for $architecture"
            rlAssertGrep "ELF.*executable" "file_$architecture.txt"

            rlRun "ldd '$executable' > 'ldd_$architecture.txt'" 0 \
                "Resolve dynamic dependencies for $architecture"
            rlAssertNotGrep "not found" "ldd_$architecture.txt"

            rlRun "roc-obj-ls '$executable' > 'code_objects_$architecture.txt'" 0 \
                "List embedded AMDGPU code objects for $architecture"
            rlAssertGrep "amdgcn-amd-amdhsa--$architecture" "code_objects_$architecture.txt"
        done
    rlPhaseEnd

    rlPhaseStartCleanup "Remove HIP build products"
        rlRun "cd /" 0 "Leave temporary directory"
        if [ -n "$TmpDir" ] && [ -d "$TmpDir" ]; then
            rlRun "rm -rf '$TmpDir'" 0 "Remove temporary files"
        fi
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
