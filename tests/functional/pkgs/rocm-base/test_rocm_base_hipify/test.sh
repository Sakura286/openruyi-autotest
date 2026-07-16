#!/bin/bash
# Functional test: translate CUDA API names with HIPIFY without a CUDA SDK.

. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
    rlPhaseStartSetup "Create HIPIFY input"
        TmpDir=$(mktemp -d)
        rlRun "cd '$TmpDir'" 0 "Enter temporary directory"
        rlRun "printf '%s\\n' 'void f(int *a, const cudaDeviceProp *b) { cudaChooseDevice(a,b); }' > hipify-input.cu" 0 \
            "Create a minimal CUDA API input"
    rlPhaseEnd

    rlPhaseStartTest "Translate CUDA API names"
        rlRun "hipify-perl hipify-input.cu -o hipify-output.cpp" 0 "Run hipify-perl"
        rlAssertGrep "hipDeviceProp_t" "hipify-output.cpp"
        rlAssertGrep "hipChooseDevice" "hipify-output.cpp"

        rlRun "hipify-clang --version > hipify-clang-version.txt 2>&1" 0 \
            "Run the hipify-clang command entry point"
        rlRun "test -s hipify-clang-version.txt" 0 "Check hipify-clang version output"
    rlPhaseEnd

    rlPhaseStartCleanup "Remove HIPIFY files"
        rlRun "cd /" 0 "Leave temporary directory"
        if [ -n "$TmpDir" ] && [ -d "$TmpDir" ]; then
            rlRun "rm -rf '$TmpDir'" 0 "Remove temporary files"
        fi
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
