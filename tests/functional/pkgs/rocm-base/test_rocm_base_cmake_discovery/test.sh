#!/bin/bash
# Functional test: discover ROCm packages with CMake.

. /usr/share/beakerlib/beakerlib.sh || exit 1
. "$(dirname "$0")/../lib.sh"

rlJournalStart
    rlPhaseStartSetup "Environment setup"
        rocmBaseSetup
        TmpDir=$(mktemp -d)
        rlRun "cp $(dirname "$0")/CMakeLists.txt $TmpDir/" 0 "Copy CMakeLists.txt"
        rlRun "cd $TmpDir" 0
    rlPhaseEnd

    rlPhaseStartTest "Discover ROCm CMake packages"
        rlRun "cmake -S . -B build -DHIP_PLATFORM=amd > configure.log 2>&1" 0 \
            "Configure ROCm package discovery"
        rlRun "sed -n '1,240p' configure.log" 0 "Print configure log"
        rlAssertGrep "ROCm base CMake package discovery: PASS" configure.log
    rlPhaseEnd

    rlPhaseStartCleanup "Clean up test environment"
        rlRun "cd /" 0
        if [ -n "$TmpDir" ] && [ -d "$TmpDir" ]; then
            rlRun "rm -rf '$TmpDir'" 0 "Remove temporary files"
        fi
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
