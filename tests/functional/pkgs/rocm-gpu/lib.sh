# library-prefix = rocm-gpu
#
# Shared setup for the ROCm GPU test suite.
# Install once and remove once across test cases.

PKG_FLAG="/tmp/.beakerlib_rocm_gpu_suite"

ROCM_GPU_PACKAGES=(
    gcc-c++
    hipcc
    rocm-device-libs
    rocr-runtime
    rocm-hip
    rocm-hip-devel
    rocminfo
    rocm-smi
    rocm-bandwidth-test
)

rocmGpuSetup() {
    if [ ! -f "$PKG_FLAG" ]; then
        local missing=()
        local package

        for package in "${ROCM_GPU_PACKAGES[@]}"; do
            if ! rpm -q "$package" 2>/dev/null; then
                missing+=("$package")
            fi
        done

        if [ "${#missing[@]}" -gt 0 ]; then
            if ! rlRun "echo '${TEST_SERVER_1_PASSWORD:-openruyi}' | sudo -S dnf install -y ${missing[*]}" 0 \
                "Install ROCm GPU dependencies"; then
                return 1
            fi
            rlLogInfo "Installed ROCm GPU dependencies"
        else
            rlLogInfo "ROCm GPU dependencies are already installed"
        fi

        echo "installed=${missing[*]}" > "$PKG_FLAG"
        echo "ref=1" >> "$PKG_FLAG"
    else
        local ref
        ref=$(grep "^ref=" "$PKG_FLAG" | cut -d= -f2)
        ref=$((ref + 1))
        sed -i "s/^ref=.*/ref=$ref/" "$PKG_FLAG"
        rlLogInfo "ROCm GPU dependency reference count: $ref"
    fi

    rlCleanupAppend "rocmGpuCleanup"
}

rocmGpuCleanup() {
    if [ ! -f "$PKG_FLAG" ]; then
        return 0
    fi

    local ref
    ref=$(grep "^ref=" "$PKG_FLAG" | cut -d= -f2)
    ref=$((ref - 1))

    if [ "$ref" -le 0 ]; then
        local installed
        installed=$(grep "^installed=" "$PKG_FLAG" | cut -d= -f2)
        if [ -n "$installed" ]; then
            echo "${TEST_SERVER_1_PASSWORD:-openruyi}" | sudo -S dnf remove -y $installed 2>/dev/null || true
            rlLogInfo "Removed ROCm GPU dependencies"
        fi
        rm -f "$PKG_FLAG"
    else
        sed -i "s/^ref=.*/ref=$ref/" "$PKG_FLAG"
        rlLogInfo "Kept ROCm GPU dependencies; references remaining: $ref"
    fi
}
