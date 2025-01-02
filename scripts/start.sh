#!/bin/bash

#################### Step 1: Script Initialization ####################

# Get the absolute path of the script's working directory
export Server_Dir=$(cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)

# Set configuration, temporary, and log directory paths
Conf_Dir="$Server_Dir/conf"
Log_Dir="$Server_Dir/logs"

# Get CPU architecture from the previously sourced script
source $Server_Dir/scripts/get_cpu_arch.sh

# Read the secret from config.yaml if exists
Secret=$(grep -oP '^secret:\s*\K.*' $Conf_Dir/config.yaml)

# If secret is not found in the config file, generate a random secret
if [ -z "$Secret" ]; then
    echo "No secret found in config.yaml, generating a new one..."
    Secret=$(openssl rand -hex 32)
    # Optionally, add the generated secret to the config.yaml file
    echo "secret: $Secret" >> $Conf_Dir/config.yaml
fi

#################### Step 2: Start Clash Service ####################

echo "Starting Clash service..."

# Depending on CPU architecture, start the appropriate Clash binary
if [[ $CpuArch =~ "x86_64" || $CpuArch =~ "amd64"  ]]; then
    nohup $Server_Dir/bin/clash-linux-amd64 -d $Conf_Dir &> $Log_Dir/clash.log &
    ReturnStatus=$?
elif [[ $CpuArch =~ "aarch64" ||  $CpuArch =~ "arm64" ]]; then
    nohup $Server_Dir/bin/clash-linux-arm64 -d $Conf_Dir &> $Log_Dir/clash.log &
    ReturnStatus=$?
elif [[ $CpuArch =~ "armv7" ]]; then
    nohup $Server_Dir/bin/clash-linux-armv7 -d $Conf_Dir &> $Log_Dir/clash.log &
    ReturnStatus=$?
else
    echo "ERROR: Unsupported CPU Architecture!"
    exit 1
fi

# Check if the service started successfully
if [ $ReturnStatus -eq 0 ]; then
    echo "[ OK ] Service started successfully!"
else
    echo "[FAILED] Service failed to start!"
    exit 1
fi

#################### Step 3: Output Dashboard Access Information ####################

# Get Local IP Address
Local_IP=$(hostname -I | awk '{print $1}')

# Output UI Access Information
echo ""
echo "Clash Dashboard Access URL: http://${Local_IP}:9090/ui"
echo "Secret: ${Secret}"
echo ""

# Output Clash PID
pid=$(pgrep -f clash-linux)
echo "Clash service is running with PID: $pid"
