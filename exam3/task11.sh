#!/bin/bash

# Initialize task status
task_status=0

# Function to update task status
update_status() {
    if [ $1 -ne 0 ]; then
        task_status=1
    fi
}

echo "Task 11 Verification: Configure ansible-navigator settings"
echo "=========================================================="

# Check if .ansible-navigator.yml exists in the ansible user's home directory
if [ -f /home/ansible/.ansible-navigator.yml ]; then
    echo "[PASS] .ansible-navigator.yml exists in /home/ansible/"
else
    echo "[FAIL] .ansible-navigator.yml does not exist in /home/ansible/"
    update_status 1
    exit $task_status
fi

# Check file content
echo "Checking .ansible-navigator.yml content:"

if grep -q "execution-environment:" /home/ansible/.ansible-navigator.yml; then
    echo "[PASS] execution-environment section is present"
else
    echo "[FAIL] execution-environment section is missing"
    update_status 1
fi

if grep -q "pull:" /home/ansible/.ansible-navigator.yml &&
   grep -q "policy: always" /home/ansible/.ansible-navigator.yml; then
    echo "[PASS] Execution environment is set to always pull"
else
    echo "[FAIL] Execution environment is not set to always pull"
    update_status 1
fi

if grep -q "playbook-artifact:" /home/ansible/.ansible-navigator.yml &&
   grep -q "enable: false" /home/ansible/.ansible-navigator.yml; then
    echo "[PASS] Playbook artifacts are disabled"
else
    echo "[FAIL] Playbook artifacts are not disabled"
    update_status 1
fi

echo "=========================================================="
echo "Verification complete."

# Print final task status
if [ $task_status -eq 0 ]; then
    echo "Task completed"
else
    echo "Task failed"
fi

exit $task_status
