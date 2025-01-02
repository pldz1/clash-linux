#!/bin/bash

echo " "
echo "Start to execute clash_profile_conversion.sh ... ..."
echo " "

# Step 1: Load the raw content of the Clash configuration file
raw_content=$(cat ${Server_Dir}/temp/clash.yaml)

# Step 2: Check if the raw content matches the standard Clash configuration format
if echo "$raw_content" | awk '/^proxies:/{p=1} /^proxy-groups:/{g=1} /^rules:/{r=1} p&&g&&r{exit} END{if(p&&g&&r) exit 0; else exit 1}'; then
  # Step 2.1: If the raw content is valid, save it as the final Clash config file
  echo "Configuration matches Clash format"
  echo "$raw_content" > ${Server_Dir}/temp/clash_config.yaml
  echo "Configure successfully!"
  echo " "
  # Return success (0) as the configuration is valid
  exit 0
else
  # Step 3: If the raw content does not match the format, check if it is base64 encoded
  if echo "$raw_content" | base64 -d &>/dev/null; then
    # Step 3.1: If the content is base64 encoded, decode it
    decoded_content=$(echo "$raw_content" | base64 -d)

    # Step 4: Check if the decoded content matches the standard Clash configuration format
    if echo "$decoded_content" | awk '/^proxies:/{p=1} /^proxy-groups:/{g=1} /^rules:/{r=1} p&&g&&r{exit} END{if(p&&g&&r) exit 0; else exit 1}'; then
      # Step 4.1: If the decoded content is valid, save it as the final Clash config file
      echo "Decoded content matches Clash format"
      echo "$decoded_content" > ${Server_Dir}/temp/clash_config.yaml
      echo " "
      # Return success (0) as the decoded configuration is valid
      exit 0
    else
      # Step 5: If the decoded content doesn't match the format, attempt to convert it using subprocess
      echo "Decoded content doesn't match Clash format, attempting conversion"
      ${Server_Dir}/tools/subconverter/subconverter -g &>> ${Server_Dir}/logs/subconverter.log
      converted_file=${Server_Dir}/temp/clash_config.yaml

      # Step 6: Check if the converted content matches the Clash configuration format
      if awk '/^proxies:/{p=1} /^proxy-groups:/{g=1} /^rules:/{r=1} p&&g&&r{exit} END{if(p&&g&&r) exit 0; else exit 1}' $converted_file; then
        # Step 6.1: If the converted content is valid, it has been successfully converted
        echo "Configuration successfully converted to Clash format"
        echo " "
        # Return success (0) as the configuration is valid after conversion
        exit 0
      else
        # Step 7: If the conversion fails, report failure
        echo "Failed to convert configuration to Clash format"
        echo " "
        # Return failure (1) as conversion was unsuccessful
        exit 1
      fi
    fi
  else
    # Step 8: If the raw content is neither valid nor base64-encoded, report failure
    echo "Content doesn't match Clash format and can't be decoded to valid configuration"
    echo " "
    # Return failure (1) as the content is invalid
    exit 1
  fi
fi
