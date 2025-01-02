#!/bin/bash
# This script retrieves the CPU architecture on a Linux system and outputs it.

# Function to exit with an error message
function exitWithError {
    local errorMessage="$1"
    echo "[ERROR] $errorMessage" >&2
    exit 1
}

# Function to get CPU architecture
function get_cpu_arch {
    local commands=("$@")
    for cmd in "${commands[@]}"; do
        if command -v $cmd &>/dev/null; then
            local result=$($cmd 2>/dev/null)
            if [[ -n "$result" ]]; then
                echo "$result"
                return
            fi
        fi
    done
    return 1 # Return failure if no command succeeds
}

# Check if we are running on a supported Linux distribution
if [[ -f "/etc/os-release" ]]; then
    . /etc/os-release
    case "$ID" in
        "ubuntu"|"debian"|"linuxmint")
            # Debian-based distributions
            CpuArch=$(get_cpu_arch "dpkg-architecture -qDEB_HOST_ARCH_CPU" "uname -m")
            ;;
        "centos"|"fedora"|"rhel")
            # Red Hat-based distributions
            CpuArch=$(get_cpu_arch "uname -m" "arch")
            ;;
        *)
            # Other Linux distributions
            CpuArch=$(get_cpu_arch "uname -m")
            ;;
    esac
elif [[ -f "/etc/redhat-release" ]]; then
    # Older Red Hat-based distributions
    CpuArch=$(get_cpu_arch "uname -m" "arch")
else
    exitWithError "Unsupported Linux distribution"
fi

# Ensure we obtained the CPU architecture
if [[ -z "$CpuArch" ]]; then
    exitWithError "Failed to obtain CPU architecture"
fi

# Export the CPU architecture to make it available to the parent script
export CpuArch

# Output the CPU architecture for debugging
echo "CPU architecture: $CpuArch"
