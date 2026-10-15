# library-prefix = rocmBase
#
# ROCm base suite-level shared library.
# Installs only the packages that are missing, records them in a flag file
# and uses reference counting so that the packages installed by this suite
# are removed once, after the last test case finishes.
# Packages that were already present before the suite are never removed.
#
# Usage in each test file:
#   . "$(dirname "$0")/../lib.sh"
#
# Then call in rlPhaseStartSetup:
#   rlRun "rocmBaseSetup \"\${PACKAGES[@]}\"" 0 "Install ROCm packages"
# The cleanup is auto-registered via rlCleanupAppend.

ROCM_BASE_FLAG="/tmp/.beakerlib_rocm_base_suite"
ROCM_BASE_LOCK="${ROCM_BASE_FLAG}.lock"

rocmBaseRoot() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo -n "$@"
    fi
}

rocmBaseSetup() {
    local pkg rc=0
    local missing=()

    # Register cleanup first so a partial install is also rolled back
    rlCleanupAppend "rocmBaseCleanup"

    (
        flock 9
        for pkg in "$@"; do
            rpm -q "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
        done

        if [ "${#missing[@]}" -gt 0 ]; then
            rocmBaseRoot dnf install -y "${missing[@]}" || exit 1
            for pkg in "${missing[@]}"; do
                rpm -q "$pkg" >/dev/null 2>&1 && echo "pkg=$pkg" >> "$ROCM_BASE_FLAG"
            done
        fi

        ref=$(sed -n 's/^ref=//p' "$ROCM_BASE_FLAG" 2>/dev/null)
        ref=$(( ${ref:-0} + 1 ))
        sed -i '/^ref=/d' "$ROCM_BASE_FLAG" 2>/dev/null
        echo "ref=$ref" >> "$ROCM_BASE_FLAG"
    ) 9>"$ROCM_BASE_LOCK" || rc=$?

    return $rc
}

rocmBaseCleanup() {
    [ -f "$ROCM_BASE_FLAG" ] || return 0

    (
        flock 9
        local ref pkgs=()
        ref=$(sed -n 's/^ref=//p' "$ROCM_BASE_FLAG")
        ref=$(( ${ref:-1} - 1 ))

        if [ "$ref" -gt 0 ]; then
            sed -i '/^ref=/d' "$ROCM_BASE_FLAG"
            echo "ref=$ref" >> "$ROCM_BASE_FLAG"
            exit 0
        fi

        mapfile -t pkgs < <(sed -n 's/^pkg=//p' "$ROCM_BASE_FLAG")
        if [ "${#pkgs[@]}" -gt 0 ]; then
            rocmBaseRoot dnf remove -y "${pkgs[@]}" || true
        fi
        rm -f "$ROCM_BASE_FLAG"
    ) 9>"$ROCM_BASE_LOCK" || true
}
