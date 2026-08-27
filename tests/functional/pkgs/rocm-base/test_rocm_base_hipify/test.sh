#!/bin/bash
# Functional test: translate CUDA APIs with HIPIFY.

. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
    rlPhaseStartSetup "Environment setup"
        TmpDir=$(mktemp -d)
        rlRun "cd $TmpDir" 0 "Enter temporary directory"
        rlRun "printf '%s\\n' 'void f(int *a, const cudaDeviceProp *b) { cudaChooseDevice(a,b); }' > hipify-input.cu" 0 \
            "Create a minimal CUDA API input"
    rlPhaseEnd

    rlPhaseStartTest "Translate CUDA API names"
        rlRun "hipify-perl hipify-input.cu -o hipify-output.cpp" 0 "Run hipify-perl"
        rlAssertGrep "hipDeviceProp_t" "hipify-output.cpp"
        rlAssertGrep "hipChooseDevice" "hipify-output.cpp"

        rlRun "hipify-clang --version > hipify-clang-version.txt 2>&1" 0 \
            "Run hipify-clang"
        rlRun "test -s hipify-clang-version.txt" 0 "Check version output"
    rlPhaseEnd

    rlPhaseStartCleanup "Clean up test environment"
        rlRun "cd /" 0 "Leave temporary directory"
        if [ -n "$TmpDir" ] && [ -d "$TmpDir" ]; then
            rlRun "rm -rf $TmpDir" 0 "Remove temporary files"
        fi
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
