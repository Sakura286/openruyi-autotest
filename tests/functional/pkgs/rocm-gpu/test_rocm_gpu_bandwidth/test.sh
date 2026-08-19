#!/bin/bash
# Test ROCm bandwidth on one AMD GPU.

. /usr/share/beakerlib/beakerlib.sh || exit 1
. "$(dirname "$0")/../lib.sh"

rlJournalStart
    rlPhaseStartSetup "Environment setup"
        rocmGpuSetup
        TmpDir=$(mktemp -d)
        rlRun "cd $TmpDir" 0
        rlRun "test -r /dev/kfd && test -w /dev/kfd" 0 "Check KFD access"
    rlPhaseEnd

    rlPhaseStartTest "Run ROCm Bandwidth Test"
        rlRun "rocm-bandwidth-test > bandwidth.txt 2>&1" 0 \
            "Run bandwidth test"
        rlRun "cat bandwidth.txt" 0 "Print bandwidth output"
        rlRun "test -s bandwidth.txt" 0 "Check for bandwidth output"
        rlRun "grep -o 'GPU-[[:xdigit:]]\\+' bandwidth.txt | sort -u > gpus.txt" 0 \
            "Find GPU identifiers"
        rlRun "test \"\$(wc -l < gpus.txt)\" -eq 1" 0 \
            "Check for one GPU"
        rlAssertGrep "Device:" bandwidth.txt
        rlAssertNotGrep "No subcommand provided" bandwidth.txt
        rlAssertNotGrep "Error:" bandwidth.txt
    rlPhaseEnd

    rlPhaseStartCleanup "Clean up test environment"
        rlRun "cd /" 0
        if [ -n "$TmpDir" ] && [ -d "$TmpDir" ]; then
            rlRun "rm -rf $TmpDir" 0 "Remove temporary files"
        fi
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
