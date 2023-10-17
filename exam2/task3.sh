#!/bin/bash

CONFIG_PATH="/home/ansible/rhce2/ansible.cfg"

# Check if ansible.cfg exists in the specified directory
if [[ ! -f "$CONFIG_PATH" ]]; then
    echo "ansible.cfg does not exist in ~/rhce2/."
    exit 1
fi

# Define a function to check a configuration value in ansible.cfg
check_config_value() {
    local key="$1"
    local expected_value="$2"
    local value
    value=$(grep "^$key" "$CONFIG_PATH" | awk -F'=' '{print $2}' | tr -d ' ')
    # Resolve paths to their absolute forms
    if [[ "$key" =~ (inventory|roles_path|retry_files_save_path|log_path) ]]; then
        # Expand ~ to the home directory
        value="${value/#\~/$HOME}"
        value=$(realpath "$value")
        expected_value=$(realpath "$expected_value")
    fi
    if [[ "$value" != "$expected_value" ]]; then
        echo "Configuration $key is not set to $expected_value. Current value: $value"
        exit 1
    fi
}

# Check various configuration values
check_config_value "inventory" "/home/ansible/rhce2/hosts"
check_config_value "timeout" "60"
check_config_value "forks" "5"
check_config_value "roles_path" "/home/ansible/rhce2/roles/"
check_config_value "retry_files_enabled" "True"
check_config_value "retry_files_save_path" "/home/ansible/rhce2/retries/"
check_config_value "log_path" "/home/ansible/rhce2/ansible.log"
check_config_value "deprecation_warnings" "True"
check_config_value "host_key_checking" "False"

echo "All checks passed. The ansible.cfg is correctly configured!"
exit 0
