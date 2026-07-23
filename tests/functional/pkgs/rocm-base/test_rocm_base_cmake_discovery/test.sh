#!/bin/bash
# Functional test: discover installed ROCm development packages with CMake.

. /usr/share/beakerlib/beakerlib.sh || exit 1

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

rlJournalStart
    rlPhaseStartSetup "Create an out-of-tree CMake build directory"
        TmpDir=$(mktemp -d)
        rlAssertExists "$SCRIPT_DIR/CMakeLists.txt"
    rlPhaseEnd

    rlPhaseStartTest "Discover ROCm CMake packages"
        rlRun "cmake -S '$SCRIPT_DIR' -B '$TmpDir/build' -DHIP_PLATFORM=amd > '$TmpDir/configure.log' 2>&1" 0 \
            "Configure a project using packaged ROCm CMake metadata"
        rlRun "sed -n '1,240p' '$TmpDir/configure.log'" 0 "Print the CMake configure log"
        rlAssertGrep "ROCm base CMake package discovery: PASS" "$TmpDir/configure.log"
    rlPhaseEnd

    rlPhaseStartCleanup "Remove the CMake build directory"
        if [ -n "$TmpDir" ] && [ -d "$TmpDir" ]; then
            rlRun "rm -rf '$TmpDir'" 0 "Remove temporary files"
        fi
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
