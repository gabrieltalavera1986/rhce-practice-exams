#!/bin/bash

# Path to the fetch_host_info.sh script
script_path="./fetch_host_info.sh"

# Initialize a flag to track if all settings are correct
all_settings_correct=true

# Check if fetch_host_info.sh exists
if [[ ! -f $script_path ]]; then
    echo "fetch_host_info.sh does not exist in the current directory."
    exit 1
fi

# Extract the ansible-navigator command from the script
ansible_navigator_command=$(grep "ansible-navigator" $script_path)

# Check if the required parameters are present in the ansible-navigator command
if [[ "$ansible_navigator_command" == *"ansible-navigator inventory"* && 
      "$ansible_navigator_command" == *"-i inventory"* && 
      "$ansible_navigator_command" == *"-m stdout"* && 
      "$ansible_navigator_command" == *"--host web01"* ]]; then
    echo "ansible-navigator command in fetch_host_info.sh is correctly set."
else
    echo "ansible-navigator command in fetch_host_info.sh is NOT correctly set."
    all_settings_correct=false
fi

# Print final result
if $all_settings_correct; then
    echo "All settings for the task are correctly configured!"
    echo "This task has been completed successfully!"
    exit 0
else
    echo "Some settings for the task are not correctly configured."
    exit 1
fi
