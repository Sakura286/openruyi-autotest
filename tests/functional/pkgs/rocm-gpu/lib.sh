# library-prefix = rocmGpu
#
# ROCm GPU suite-level shared library.
# Installs only the packages that are missing, records them in a flag file
# and uses reference counting so that the packages installed by this suite
# are removed once, after the last test case finishes.
# Packages that were already present before the suite are never removed.
#
# Usage in each test file:
#   . "$(dirname "$0")/../lib.sh"
#
# Then call in rlPhaseStartSetup:
#   rlRun "rocmGpuSetup \"\${PACKAGES[@]}\"" 0 "Install ROCm packages"
# The cleanup is auto-registered via rlCleanupAppend.

ROCM_GPU_FLAG="/tmp/.beakerlib_rocm_gpu_suite"
ROCM_GPU_LOCK="${ROCM_GPU_FLAG}.lock"

rocmGpuRoot() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo -n "$@"
    fi
}

rocmGpuSetup() {
    local pkg rc=0
    local missing=()

    # Register cleanup first so a partial install is also rolled back
    rlCleanupAppend "rocmGpuCleanup"

    (
        flock 9
        for pkg in "$@"; do
            rpm -q "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
        done

        if [ "${#missing[@]}" -gt 0 ]; then
            rocmGpuRoot dnf install -y "${missing[@]}" || exit 1
            for pkg in "${missing[@]}"; do
                rpm -q "$pkg" >/dev/null 2>&1 && echo "pkg=$pkg" >> "$ROCM_GPU_FLAG"
            done
        fi

        ref=$(sed -n 's/^ref=//p' "$ROCM_GPU_FLAG" 2>/dev/null)
        ref=$(( ${ref:-0} + 1 ))
        sed -i '/^ref=/d' "$ROCM_GPU_FLAG" 2>/dev/null
        echo "ref=$ref" >> "$ROCM_GPU_FLAG"
    ) 9>"$ROCM_GPU_LOCK" || rc=$?

    return $rc
}

rocmGpuCleanup() {
    [ -f "$ROCM_GPU_FLAG" ] || return 0

    (
        flock 9
        local ref pkgs=()
        ref=$(sed -n 's/^ref=//p' "$ROCM_GPU_FLAG")
        ref=$(( ${ref:-1} - 1 ))

        if [ "$ref" -gt 0 ]; then
            sed -i '/^ref=/d' "$ROCM_GPU_FLAG"
            echo "ref=$ref" >> "$ROCM_GPU_FLAG"
            exit 0
        fi

        mapfile -t pkgs < <(sed -n 's/^pkg=//p' "$ROCM_GPU_FLAG")
        if [ "${#pkgs[@]}" -gt 0 ]; then
            rocmGpuRoot dnf remove -y "${pkgs[@]}" || true
        fi
        rm -f "$ROCM_GPU_FLAG"
    ) 9>"$ROCM_GPU_LOCK" || true
}
