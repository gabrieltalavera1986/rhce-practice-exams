#!/bin/bash

# Path to the ansible.cfg file
cfg_file="/home/ansible/rhce1/ansible.cfg"

# Initialize a flag to track if all settings are correct
all_settings_correct=true

# Check if ansible.cfg exists
if [[ ! -f $cfg_file ]]; then
    echo "ansible.cfg does not exist in the current directory."
    exit 1
fi

# Check if the default inventory is set to 'inventory', './inventory', or '/home/ansible/rhce1/inventory'
if grep -qE '^\s*inventory\s*=\s*(./)?inventory\s*$' "$cfg_file" || grep -qE '^\s*inventory\s*=\s*/home/ansible/rhce1/inventory\s*$' "$cfg_file"; then
    echo "Default inventory is correctly set."
else
    echo "Default inventory is NOT correctly set."
    all_settings_correct=false
fi

# Check for control connection timeout of 120 seconds
if grep -qE '^\s*timeout\s*=\s*120\s*$' "$cfg_file"; then
    echo "Control connection timeout is correctly set to 120 seconds."
else
    echo "Control connection timeout is NOT correctly set."
    all_settings_correct=false
fi

# Check for 3 threads by default
if grep -qE '^\s*forks\s*=\s*3\s*$' "$cfg_file"; then
    echo "Ansible is correctly set to use 3 threads by default."
else
    echo "Ansible is NOT set to use 3 threads by default."
    all_settings_correct=false
fi

# Check for privilege escalation
if grep -qE '^\s*become\s*=\s*(yes|True)\s*$' "$cfg_file"; then
    echo "Privilege escalation is correctly set by default for all tasks."
else
    echo "Privilege escalation is NOT set by default for all tasks."
    all_settings_correct=false
fi

# Check for default remote user as 'ansible'
if grep -qE '^\s*remote_user\s*=\s*ansible\s*$' "$cfg_file"; then
    echo "Default remote user is correctly set to 'ansible'."
else
    echo "Default remote user is NOT set to 'ansible'."
    all_settings_correct=false
fi

# Print final result
if $all_settings_correct; then
    echo "All settings are correctly configured in ansible.cfg!"
    echo "This task has been completed successfully!"
    exit 0
else
    echo "Some settings in ansible.cfg are not correctly configured."
    exit 1
fi
