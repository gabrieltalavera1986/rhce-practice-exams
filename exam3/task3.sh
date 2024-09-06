#!/bin/bash

# Initialize task status
task_status=0

# Function to update task status
update_status() {
    if [ $1 -ne 0 ]; then
        task_status=1
    fi
}

echo "Task 3 Verification: Ansible Configuration"
echo "========================================="

# Check if ~/rhce3 directory exists
if [ -d ~/rhce3 ]; then
    echo "[PASS] ~/rhce3 directory exists"
else
    echo "[FAIL] ~/rhce3 directory does not exist"
    update_status 1
fi

# Check if ansible.cfg file exists in ~/rhce3
if [ -f ~/rhce3/ansible.cfg ]; then
    echo "[PASS] ansible.cfg file exists in ~/rhce3"
else
    echo "[FAIL] ansible.cfg file does not exist in ~/rhce3"
    update_status 1
fi

# Function to check configuration
check_config() {
    local section=$1
    local key=$2
    local expected_value=$3
    local actual_value=$(sed -n "/^\[$section\]/,/^\[/p" ~/rhce3/ansible.cfg | grep "^$key[[:space:]]*=" | sed 's/^[^=]*=[[:space:]]*//')
    
    if [ "$actual_value" = "$expected_value" ]; then
        echo "[PASS] $section: $key is correctly set to $expected_value"
    else
        echo "[FAIL] $section: $key is not correctly set. Expected: $expected_value, Actual: $actual_value"
        update_status 1
    fi
}

# Check specific configurations
check_config "defaults" "become" "false"
check_config "privilege_escalation" "become_method" "sudo"
check_config "privilege_escalation" "become_user" "root"
check_config "ssh_connection" "host_key_checking" "False"

echo "========================================="
echo "Verification complete."

# Print final task status
if [ $task_status -eq 0 ]; then
    echo "Task completed"
else
    echo "Task failed"
fi

exit $task_status
