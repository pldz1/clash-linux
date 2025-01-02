#!/bin/bash

#################### Step 1: Script Initialization ####################

# Get the absolute path of the script's working directory
export Server_Dir=$(cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)

# Load environment variables from .env file
source $Server_Dir/.env

# Set executable permissions for binary, scripts, etc.
chmod +x $Server_Dir/bin/*
chmod +x $Server_Dir/scripts/*
chmod +x $Server_Dir/tools/subconverter/subconverter

#################### Step 2: Variable Setup ####################

# Set configuration, temporary, and log directory paths
Conf_Dir="$Server_Dir/conf"
Temp_Dir="$Server_Dir/temp"
Log_Dir="$Server_Dir/logs"

# Get the value of CLASH_URL, if not set, leave it empty
URL=${CLASH_URL:-""}

# Get or generate a random secret for Clash
Secret=${CLASH_SECRET:-$(openssl rand -hex 32)}

#################### Step 3: Function Definitions ####################

# Success function for logging success messages
success() {
    echo -n "[ OK ]"
    return 0
}

# Failure function for logging failure messages
failure() {
    local rc=$?
    echo -n "[FAILED]"
    [ -x /bin/plymouth ] && /bin/plymouth --details
    return $rc
}

# General action function to execute commands and log the results
action() {
    local STRING rc
    STRING=$1
    echo -n "$STRING "
    shift
    "$@" && success || failure
    rc=$?
    echo
    return $rc
}

# Check if a command was successful or failed
if_success() {
    local ReturnStatus=$3
    if [ $ReturnStatus -eq 0 ]; then
        action "$1" /bin/true
    else
        action "$2" /bin/false
        exit 1
    fi
}

#################### Step 4: Task Execution ####################

# Step 4.1: Get CPU Architecture Information
# Source the script to get the CPU architecture
source $Server_Dir/scripts/get_cpu_arch.sh

# Check if the CPU architecture was successfully obtained
if [[ -z "$CpuArch" ]]; then
    echo "Failed to obtain CPU architecture"
    exit 1
fi

# Step 4.2: Unset Proxy Environment Variables
# Temporarily unset proxy settings
unset http_proxy
unset https_proxy
unset no_proxy
unset HTTP_PROXY
unset HTTPS_PROXY
unset NO_PROXY

# Step 4.3: Skip Subscription URL Check if Not Set
if [[ -z "$URL" ]]; then
    echo "CLASH_URL is empty, skipping subscription address check and config file download..."
else
    # Step 4.4: Check if Clash Subscription URL is Reachable
    echo "Checking subscription URL..."
    Text1="Clash subscription URL is reachable!"
    Text2="Clash subscription URL is unreachable!"
    curl -o /dev/null -L -k -sS --retry 5 -m 10 --connect-timeout 10 -w "%{http_code}" $URL | grep -E '^[23][0-9]{2}$' &>/dev/null
    ReturnStatus=$?
    if_success "$Text1" "$Text2" $ReturnStatus

    # Step 4.5: Download Clash Config File
    echo "Downloading Clash configuration file..."
    Text3="Config file config.yaml downloaded successfully!"
    Text4="Config file config.yaml download failed, exiting!"
    
    # Attempt to download using curl
    curl -L -k -sS --retry 5 -m 10 -o $Temp_Dir/clash.yaml $URL
    ReturnStatus=$?
    
    if [ $ReturnStatus -ne 0 ]; then
        # If curl fails, try downloading with wget
        for i in {1..10}
        do
            wget -q --no-check-certificate -O $Temp_Dir/clash.yaml $URL
            ReturnStatus=$?
            if [ $ReturnStatus -eq 0 ]; then
                break
            fi
        done
    fi
    if_success "$Text3" "$Text4" $ReturnStatus

    # Step 4.6: Rename the Clash Config File
    cp -a $Temp_Dir/clash.yaml $Temp_Dir/clash_config.yaml
fi

# Step 4.7: Validate and Convert the Clash Subscription File (only for x86_64 and amd64 architectures)
if [[ $CpuArch =~ "x86_64" || $CpuArch =~ "amd64"  ]]; then
    echo "Validating if the subscription content follows the Clash config file standard..."
    bash $Server_Dir/scripts/clash_profile_conversion.sh
    sleep 3
fi

# Step 4.8: Reformat the Clash Config File
# Extract proxy-related configuration
sed -n '/^proxies:/,$p' $Temp_Dir/clash_config.yaml > $Temp_Dir/proxy.txt

# Create the new config.yaml by merging the template and proxy configuration
cat $Temp_Dir/templete_config.yaml > $Temp_Dir/config.yaml
cat $Temp_Dir/proxy.txt >> $Temp_Dir/config.yaml

# Copy the final config.yaml to the configuration directory
cp $Temp_Dir/config.yaml $Conf_Dir/

# Step 4.9: Configure Clash Dashboard
Dashboard_Dir="${Server_Dir}/dashboard/public"
sed -ri "s@^# external-ui:.*@external-ui: ${Dashboard_Dir}@g" $Conf_Dir/config.yaml
sed -r -i '/^secret: /s@(secret: ).*@\1'${Secret}'@g' $Conf_Dir/config.yaml
