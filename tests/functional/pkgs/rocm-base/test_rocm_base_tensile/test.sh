#!/bin/bash
# Functional test: validate GPU-independent Tensile tools.

. /usr/share/beakerlib/beakerlib.sh || exit 1
. "$(dirname "$0")/../lib.sh"

ROCM_BASE_TEST_PACKAGES=(
    python-tensile
)

rlJournalStart
    rlPhaseStartSetup "Environment setup"
        rlRun "rocmBaseSetup \"\${ROCM_BASE_TEST_PACKAGES[@]}\"" 0 "Install ROCm packages"
        TmpDir=$(mktemp -d)
        rlRun "cd $TmpDir" 0 "Enter temporary directory"
    rlPhaseEnd

    rlPhaseStartTest "Import the Tensile Python module"
        rlRun "python3 -c 'import Tensile; print(Tensile.__file__)' > tensile-module.txt" 0 \
            "Import Tensile and record module path"
        rlRun "test -s tensile-module.txt" 0 "Check module path"
        TensileModule=$(cat tensile-module.txt)
        rlRun "test -f '$TensileModule'" 0 "Check module file"
    rlPhaseEnd

    rlPhaseStartTest "Validate Tensile command entry points"
        rlRun "TensileGetPath > tensile-root.txt" 0 "Run TensileGetPath"
        rlRun "test -s tensile-root.txt" 0 "Check Tensile root"
        TensileRoot=$(cat tensile-root.txt)
        rlRun "test -d '$TensileRoot'" 0 "Check Tensile root directory"

        rlRun "Tensile --version > tensile-version.txt 2>&1" 0 "Print Tensile version"
        rlAssertGrep "Tensile" "tensile-version.txt"
        rlRun "Tensile --help > tensile-help.txt 2>&1" 0 "Print Tensile help"
        rlRun "test -s tensile-help.txt" 0 "Check Tensile help output"
    rlPhaseEnd

    rlPhaseStartCleanup "Clean up test environment"
        rlRun "cd /" 0 "Leave temporary directory"
        if [ -n "$TmpDir" ] && [ -d "$TmpDir" ]; then
            rlRun "rm -rf $TmpDir" 0 "Remove temporary files"
        fi
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
