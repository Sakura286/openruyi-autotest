#!/bin/bash
# Functional test: compile and execute HIP vector addition on one AMD GPU.

. /usr/share/beakerlib/beakerlib.sh || exit 1

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

rlJournalStart
    rlPhaseStartSetup "Detect the GPU architecture"
        TmpDir=$(mktemp -d)
        rlRun "cp '$SCRIPT_DIR/vector_add.cpp' '$TmpDir/'" 0 \
            "Copy the HIP source to a temporary directory"
        rlRun "cd '$TmpDir'" 0 "Enter the temporary directory"
        rlRun "rocminfo > rocminfo.txt 2>&1" 0 "Query the installed GPU"
        rlRun "grep -E '^[[:space:]]*Name:[[:space:]]+gfx[0-9]+' rocminfo.txt | awk '{print \$2}' | sort -u > gpu-architectures.txt" 0 \
            "Collect GPU architectures"
        rlRun "test \"\$(wc -l < gpu-architectures.txt)\" -eq 1" 0 \
            "Check that exactly one GPU architecture is detected"
        GPU_ARCH=$(cat gpu-architectures.txt)
        rlLogInfo "Detected GPU architecture: $GPU_ARCH"
    rlPhaseEnd

    rlPhaseStartTest "Compile and run HIP vector addition"
        rlRun "hipcc --version" 0 "Print the HIP compiler version"
        rlRun "hipcc --offload-arch='$GPU_ARCH' vector_add.cpp -o vector_add" 0 \
            "Compile HIP code for the installed GPU"
        rlRun "./vector_add > run.txt 2>&1" 0 \
            "Execute HIP vector addition on the GPU"
        rlRun "cat run.txt" 0 "Print HIP program output"
        rlAssertGrep "HIP vector add: PASS" "run.txt"
        rlAssertGrep "arch=$GPU_ARCH" "run.txt"
    rlPhaseEnd

    rlPhaseStartCleanup "Remove HIP build products"
        rlRun "cd /" 0 "Leave the temporary directory"
        if [ -n "$TmpDir" ] && [ -d "$TmpDir" ]; then
            rlRun "rm -rf '$TmpDir'" 0 "Remove temporary files"
        fi
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
