#!/bin/bash
# Query one AMD GPU with rocm-smi.

. /usr/share/beakerlib/beakerlib.sh || exit 1
. "$(dirname "$0")/../lib.sh"

rlJournalStart
    rlPhaseStartSetup "Environment setup"
        rocmGpuSetup
        TmpDir=$(mktemp -d)
        rlRun "test -r /dev/kfd && test -w /dev/kfd" 0 "Check KFD access"
    rlPhaseEnd

    rlPhaseStartTest "Query a single AMD GPU"
        rlRun "rocm-smi --showproductname --showuniqueid --showbus > rocm-smi.txt 2>&1" 0 \
            "Query GPU identity"
        rlRun "cat rocm-smi.txt" 0 "Print rocm-smi output"
        rlRun "grep -o 'GPU\\[[0-9]\\+\\]' rocm-smi.txt | sort -u > gpus.txt" 0 \
            "Find GPU indices"
        rlRun "test \"\$(wc -l < gpus.txt)\" -eq 1" 0 \
            "Check for one GPU"
        rlAssertNotGrep "No AMD GPUs specified" rocm-smi.txt
        rlAssertNotGrep "ERROR:" rocm-smi.txt
    rlPhaseEnd

    rlPhaseStartCleanup "Clean up test environment"
        if [ -n "$TmpDir" ] && [ -d "$TmpDir" ]; then
            rlRun "rm -rf '$TmpDir'" 0 "Remove temporary files"
        fi
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
