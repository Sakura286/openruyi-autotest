#!/bin/bash
# Discover one AMD GPU agent with rocminfo.

. /usr/share/beakerlib/beakerlib.sh || exit 1
. "$(dirname "$0")/../lib.sh"

ROCM_GPU_TEST_PACKAGES=(
    rocminfo
)

rlJournalStart
    rlPhaseStartSetup "Environment setup"
        rlRun "rocmGpuSetup \"\${ROCM_GPU_TEST_PACKAGES[@]}\"" 0 "Install ROCm packages"
        TmpDir=$(mktemp -d)
        rlRun "cd $TmpDir" 0
        rlRun "test -r /dev/kfd && test -w /dev/kfd" 0 "Check KFD access"
    rlPhaseEnd

    rlPhaseStartTest "Discover a single AMD GPU agent"
        rlRun "rocminfo > rocminfo.txt 2>&1" 0 \
            "Query HSA agents"
        rlRun "cat rocminfo.txt" 0 "Print rocminfo output"
        rlRun "grep -E '^[[:space:]]*Uuid:[[:space:]]+GPU-' rocminfo.txt > gpu-agents.txt" 0 \
            "Find GPU agents"
        rlRun "test \"\$(wc -l < gpu-agents.txt)\" -eq 1" 0 \
            "Check for one GPU agent"
        rlRun "grep -E '^[[:space:]]*Name:[[:space:]]+gfx[0-9]+' rocminfo.txt | awk '{print \$2}' | sort -u > gpu-architectures.txt" 0 \
            "Find GPU architectures"
        rlRun "cat gpu-architectures.txt" 0 "Print GPU architecture"
        rlAssertGrep "Marketing Name:[[:space:]]*[^[:space:]]" rocminfo.txt
    rlPhaseEnd

    rlPhaseStartCleanup "Clean up test environment"
        rlRun "cd /" 0
        if [ -n "$TmpDir" ] && [ -d "$TmpDir" ]; then
            rlRun "rm -rf $TmpDir" 0 "Remove temporary files"
        fi
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
