#!/bin/bash
# Functional test: validate GPU-independent Tensile module and CLI entry points.

. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
    rlPhaseStartSetup "Create a temporary output directory"
        TmpDir=$(mktemp -d)
        rlRun "cd '$TmpDir'" 0 "Enter temporary directory"
    rlPhaseEnd

    rlPhaseStartTest "Import the Tensile Python module"
        rlRun "python3 -c 'import Tensile; print(Tensile.__file__)' > tensile-module.txt" 0 \
            "Import Tensile and record its module path"
        rlRun "test -s tensile-module.txt" 0 "Check the recorded Tensile module path"
        TensileModule=$(cat tensile-module.txt)
        rlRun "test -f '$TensileModule'" 0 "Check that the Tensile module file exists"
    rlPhaseEnd

    rlPhaseStartTest "Validate Tensile command entry points"
        rlRun "TensileGetPath > tensile-root.txt" 0 "Run TensileGetPath"
        rlRun "test -s tensile-root.txt" 0 "Check the recorded Tensile root"
        TensileRoot=$(cat tensile-root.txt)
        rlRun "test -d '$TensileRoot'" 0 "Check that the Tensile root exists"

        rlRun "Tensile --version > tensile-version.txt 2>&1" 0 "Print Tensile version"
        rlAssertGrep "Tensile" "tensile-version.txt"
        rlRun "Tensile --help > tensile-help.txt 2>&1" 0 "Print Tensile help"
        rlRun "test -s tensile-help.txt" 0 "Check Tensile help output"
    rlPhaseEnd

    rlPhaseStartCleanup "Remove Tensile output files"
        rlRun "cd /" 0 "Leave temporary directory"
        if [ -n "$TmpDir" ] && [ -d "$TmpDir" ]; then
            rlRun "rm -rf '$TmpDir'" 0 "Remove temporary files"
        fi
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
