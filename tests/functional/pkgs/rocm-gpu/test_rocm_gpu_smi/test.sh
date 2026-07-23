#!/bin/bash
# Functional test: query exactly one AMD GPU through rocm-smi.

. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
    rlPhaseStartSetup "Prepare rocm-smi output"
        TmpDir=$(mktemp -d)
        rlRun "test -r /dev/kfd && test -w /dev/kfd" 0 \
            "Check that the test user can access the KFD device"
    rlPhaseEnd

    rlPhaseStartTest "Query a single AMD GPU"
        rlRun "rocm-smi --showproductname --showuniqueid --showbus > '$TmpDir/rocm-smi.txt' 2>&1" 0 \
            "Query GPU identity with rocm-smi"
        rlRun "cat '$TmpDir/rocm-smi.txt'" 0 "Print rocm-smi output"
        rlRun "grep -o 'GPU\\[[0-9]\\+\\]' '$TmpDir/rocm-smi.txt' | sort -u > '$TmpDir/gpus.txt'" 0 \
            "Collect unique GPU indices"
        rlRun "test \"\$(wc -l < '$TmpDir/gpus.txt')\" -eq 1" 0 \
            "Check that rocm-smi reports exactly one GPU"
        rlAssertNotGrep "No AMD GPUs specified" "$TmpDir/rocm-smi.txt"
        rlAssertNotGrep "ERROR:" "$TmpDir/rocm-smi.txt"
    rlPhaseEnd

    rlPhaseStartCleanup "Remove rocm-smi output"
        if [ -n "$TmpDir" ] && [ -d "$TmpDir" ]; then
            rlRun "rm -rf '$TmpDir'" 0 "Remove temporary files"
        fi
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
