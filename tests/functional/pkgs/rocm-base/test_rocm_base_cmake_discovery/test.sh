#!/bin/bash
# Functional test: discover ROCm packages with CMake.

. /usr/share/beakerlib/beakerlib.sh || exit 1
. "$(dirname "$0")/../lib.sh"

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

rlJournalStart
    rlPhaseStartSetup "Environment setup"
        rocmBaseSetup
        TmpDir=$(mktemp -d)
    rlPhaseEnd

    rlPhaseStartTest "Discover ROCm CMake packages"
        rlRun "cmake -S '$SCRIPT_DIR' -B '$TmpDir/build' -DHIP_PLATFORM=amd > '$TmpDir/configure.log' 2>&1" 0 \
            "Configure ROCm package discovery"
        rlRun "sed -n '1,240p' '$TmpDir/configure.log'" 0 "Print configure log"
        rlAssertGrep "ROCm base CMake package discovery: PASS" "$TmpDir/configure.log"
    rlPhaseEnd

    rlPhaseStartCleanup "Clean up test environment"
        if [ -n "$TmpDir" ] && [ -d "$TmpDir" ]; then
            rlRun "rm -rf '$TmpDir'" 0 "Remove temporary files"
        fi
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
