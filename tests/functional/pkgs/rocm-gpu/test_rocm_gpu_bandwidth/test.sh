#!/bin/bash
# Functional test: run ROCm Bandwidth Test with exactly one AMD GPU.

. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
    rlPhaseStartSetup "Prepare bandwidth test output"
        TmpDir=$(mktemp -d)
        rlRun "test -r /dev/kfd && test -w /dev/kfd" 0 \
            "Check that the test user can access the KFD device"
    rlPhaseEnd

    rlPhaseStartTest "Run ROCm Bandwidth Test"
        rlRun "rocm-bandwidth-test > '$TmpDir/bandwidth.txt' 2>&1" 0 \
            "Measure data paths involving the GPU"
        rlRun "cat '$TmpDir/bandwidth.txt'" 0 "Print bandwidth test output"
        rlRun "test -s '$TmpDir/bandwidth.txt'" 0 "Check that bandwidth output is not empty"
        rlRun "grep -o 'GPU-[[:xdigit:]]\\+' '$TmpDir/bandwidth.txt' | sort -u > '$TmpDir/gpus.txt'" 0 \
            "Collect unique GPU identifiers"
        rlRun "test \"\$(wc -l < '$TmpDir/gpus.txt')\" -eq 1" 0 \
            "Check that the bandwidth test reports exactly one GPU"
        rlAssertGrep "Device:" "$TmpDir/bandwidth.txt"
        rlAssertNotGrep "No subcommand provided" "$TmpDir/bandwidth.txt"
        rlAssertNotGrep "Error:" "$TmpDir/bandwidth.txt"
    rlPhaseEnd

    rlPhaseStartCleanup "Remove bandwidth test output"
        if [ -n "$TmpDir" ] && [ -d "$TmpDir" ]; then
            rlRun "rm -rf '$TmpDir'" 0 "Remove temporary files"
        fi
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
