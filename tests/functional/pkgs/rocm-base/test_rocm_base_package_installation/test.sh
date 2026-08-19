#!/bin/bash
# Functional test: verify the openRuyi ROCm base package set.

. /usr/share/beakerlib/beakerlib.sh || exit 1
. "$(dirname "$0")/../lib.sh"

rlJournalStart
    rlPhaseStartSetup "Environment setup"
        rocmBaseSetup
        rlLogInfo "Architecture: $(uname -m)"
        rlLogInfo "Kernel: $(uname -r)"
    rlPhaseEnd

    rlPhaseStartTest "Verify ROCm package installation"
        for package in "${ROCM_BASE_PACKAGES[@]}"; do
            rlRun "rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\\n' '$package'" 0 \
                "Query installed package $package"
        done
    rlPhaseEnd

    rlPhaseStartCleanup "Clean up test environment"
        rlLogInfo "Shared library handles cleanup"
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
