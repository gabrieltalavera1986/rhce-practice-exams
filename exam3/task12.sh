#!/bin/bash

# Initialize task status
task_status=0

# Function to update task status
update_status() {
    if [ $1 -ne 0 ]; then
        task_status=1
    fi
}

echo "Task 12 Verification: Correct Backup Playbook"
echo "============================================"

# Check if fixme.yml exists in the current directory
if [ -f fixme.yml ]; then
    echo "[PASS] fixme.yml exists in the current directory"
else
    echo "[FAIL] fixme.yml does not exist in the current directory"
    update_status 1
    exit $task_status
fi

# Check playbook content
echo "Checking fixme.yml content:"

# Function to check for a string in the file
check_content() {
    if grep -q "$1" fixme.yml; then
        echo "[PASS] $2"
    else
        echo "[FAIL] $2"
        update_status 1
    fi
}

# Perform checks
check_content "hosts: dev" "Playbook targets dev group"
check_content "backup_dir: \"/tmp/backup\"" "Backup directory is correctly set to /tmp/backup"
check_content "module: file" "File module is used for directory creation"
check_content "src: \"/etc/ssh/sshd_config\"" "SSH config file path is correct"
check_content "src: \"/etc/resolv.conf\"" "DNS resolver config file path is correct"
check_content "copy:" "Copy module is used correctly"
check_content "src: \"/etc/hosts\"" "Hosts file path is correct"

# Check indentation for 'flat: yes'
if grep -q "^        flat: yes" fixme.yml; then
    echo "[PASS] 'flat: yes' is correctly indented"
else
    echo "[FAIL] 'flat: yes' is not correctly indented"
    update_status 1
fi

# Check if there are no occurrences of /tpm
if grep -q "/tpm" fixme.yml; then
    echo "[FAIL] Found incorrect '/tpm' path in the playbook"
    update_status 1
else
    echo "[PASS] No incorrect '/tpm' paths found in the playbook"
fi

# Check if there are no occurrences of ccpy
if grep -q "ccpy" fixme.yml; then
    echo "[FAIL] Found incorrect 'ccpy' module in the playbook"
    update_status 1
else
    echo "[PASS] No incorrect 'ccpy' module found in the playbook"
fi

echo "============================================"
echo "Verification complete."

# Print final task status
if [ $task_status -eq 0 ]; then
    echo "Task completed"
else
    echo "Task failed"
fi

exit $task_status
