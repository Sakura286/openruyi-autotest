# library-prefix = rocm-base
#
# Shared setup for the ROCm base package set.
# Install once and remove once across test cases.

PKG_FLAG="/tmp/.beakerlib_rocm_base_suite"

ROCM_BASE_PACKAGES=(
    gcc-c++
    cmake
    pciutils
    rocm-cmake
    hipcc
    rocm-device-libs
    rocm-comgr
    rocm-comgr-devel
    rocm-llvm-macros
    rocr-runtime
    rocr-runtime-devel
    rocm-hip
    rocm-hip-devel
    rocminfo
    rocm-smi
    rocm-smi-devel
    rocprofiler-register
    rocprofiler-register-devel
    rocblas
    rocblas-devel
    hipblas-common-devel
    hipblas
    hipblas-devel
    rocsolver
    rocsolver-devel
    rocsparse
    rocsparse-devel
    rocprim-devel
    hipify
    rocm-bandwidth-test
    python-tensile
)

rocmBaseSetup() {
    if [ ! -f "$PKG_FLAG" ]; then
        local missing=()
        local package

        for package in "${ROCM_BASE_PACKAGES[@]}"; do
            if ! rpm -q "$package" 2>/dev/null; then
                missing+=("$package")
            fi
        done

        if [ "${#missing[@]}" -gt 0 ]; then
            echo "${TEST_SERVER_1_PASSWORD:-openruyi}" | sudo -S dnf install -y "${missing[@]}" 2>/dev/null
            echo "installed=1" > "$PKG_FLAG"
            printf 'packages=%s\n' "${missing[*]}" >> "$PKG_FLAG"
            rlLogInfo "Installed ROCm base packages"
        else
            echo "installed=0" > "$PKG_FLAG"
            rlLogInfo "ROCm base packages already installed"
        fi

        echo "ref=1" >> "$PKG_FLAG"
    else
        local ref
        ref=$(grep "^ref=" "$PKG_FLAG" | cut -d= -f2)
        ref=$((ref + 1))
        sed -i "s/^ref=.*/ref=$ref/" "$PKG_FLAG"
        rlLogInfo "Reusing ROCm base packages; references: $ref"
    fi

    rlCleanupAppend "rocmBaseCleanup"
}

rocmBaseCleanup() {
    if [ ! -f "$PKG_FLAG" ]; then
        return 0
    fi

    local ref
    ref=$(grep "^ref=" "$PKG_FLAG" | cut -d= -f2)
    ref=$((ref - 1))

    if [ "$ref" -le 0 ]; then
        if grep -q "^installed=1" "$PKG_FLAG"; then
            local installed_packages
            local packages=()
            installed_packages=$(sed -n 's/^packages=//p' "$PKG_FLAG")
            read -r -a packages <<< "$installed_packages"
            if [ "${#packages[@]}" -gt 0 ]; then
                echo "${TEST_SERVER_1_PASSWORD:-openruyi}" | sudo -S dnf remove -y "${packages[@]}" 2>/dev/null || true
            fi
            rlLogInfo "Removed ROCm base packages installed by this suite"
        fi
        rm -f "$PKG_FLAG"
    else
        sed -i "s/^ref=.*/ref=$ref/" "$PKG_FLAG"
        rlLogInfo "Retaining ROCm base packages; references remaining: $ref"
    fi
}
