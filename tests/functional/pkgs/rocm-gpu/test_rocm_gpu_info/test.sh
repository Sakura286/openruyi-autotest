#!/bin/bash
# Functional test: discover exactly one AMD GPU agent through rocminfo.

. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
    rlPhaseStartSetup "Prepare rocminfo output"
        TmpDir=$(mktemp -d)
        rlRun "test -r /dev/kfd && test -w /dev/kfd" 0 \
            "Check that the test user can access the KFD device"
    rlPhaseEnd

    rlPhaseStartTest "Discover a single AMD GPU agent"
        rlRun "rocminfo > '$TmpDir/rocminfo.txt' 2>&1" 0 \
            "Query HSA agents with rocminfo"
        rlRun "cat '$TmpDir/rocminfo.txt'" 0 "Print rocminfo output"
        rlRun "grep -E '^[[:space:]]*Uuid:[[:space:]]+GPU-' '$TmpDir/rocminfo.txt' > '$TmpDir/gpu-agents.txt'" 0 \
            "Collect GPU agent identifiers"
        rlRun "test \"\$(wc -l < '$TmpDir/gpu-agents.txt')\" -eq 1" 0 \
            "Check that rocminfo reports exactly one GPU agent"
        rlRun "grep -E '^[[:space:]]*Name:[[:space:]]+gfx[0-9]+' '$TmpDir/rocminfo.txt' | awk '{print \$2}' | sort -u > '$TmpDir/gpu-architectures.txt'" 0 \
            "Collect GPU architectures"
        rlRun "test \"\$(wc -l < '$TmpDir/gpu-architectures.txt')\" -eq 1" 0 \
            "Check that rocminfo reports one GPU architecture"
        rlRun "cat '$TmpDir/gpu-architectures.txt'" 0 "Print the detected GPU architecture"
        rlAssertGrep "Marketing Name:[[:space:]]*[^[:space:]]" "$TmpDir/rocminfo.txt"
    rlPhaseEnd

    rlPhaseStartCleanup "Remove rocminfo output"
        if [ -n "$TmpDir" ] && [ -d "$TmpDir" ]; then
            rlRun "rm -rf '$TmpDir'" 0 "Remove temporary files"
        fi
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
