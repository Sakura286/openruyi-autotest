#!/bin/bash
# Test ROCm bandwidth on one AMD GPU.

. /usr/share/beakerlib/beakerlib.sh || exit 1
. "$(dirname "$0")/../lib.sh"

ROCM_GPU_TEST_PACKAGES=(
    rocm-bandwidth-test
)

rlJournalStart
    rlPhaseStartSetup "Environment setup"
        rlRun "rocmGpuSetup \"\${ROCM_GPU_TEST_PACKAGES[@]}\"" 0 "Install ROCm packages"
        TmpDir=$(mktemp -d)
        rlRun "cd $TmpDir" 0
        rlRun "test -r /dev/kfd && test -w /dev/kfd" 0 "Check KFD access"
    rlPhaseEnd

    rlPhaseStartTest "Run ROCm Bandwidth Test"
        rlRun "rocm-bandwidth-test > bandwidth.txt 2>&1" 0 \
            "Run bandwidth test"
        rlRun "cat bandwidth.txt" 0 "Print bandwidth output"
        rlAssertGrep 'GPU-[[:xdigit:]]\+' bandwidth.txt
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
