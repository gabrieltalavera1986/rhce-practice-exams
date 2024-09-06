#!/bin/bash

# Initialize task status
task_status=0

# Function to update task status
update_status() {
    if [ $1 -ne 0 ]; then
        task_status=1
    fi
}

echo "Task 4 Verification: Document Command for Red Hat Registry Login"
echo "=============================================================="

# Check if /tmp/registrylogin.txt file exists
if [ -f /tmp/registrylogin.txt ]; then
    echo "[PASS] /tmp/registrylogin.txt file exists"
else
    echo "[FAIL] /tmp/registrylogin.txt file does not exist"
    update_status 1
fi

# Check the content of the file
if [ -f /tmp/registrylogin.txt ]; then
    content=$(cat /tmp/registrylogin.txt | tr -d '[:space:]')
    expected_content="podmanloginregistry.redhat.io"

    if [ "$content" = "$expected_content" ]; then
        echo "[PASS] The file contains the correct command: podman login registry.redhat.io"
    else
        echo "[FAIL] The file does not contain the correct command"
        echo "Expected: podman login registry.redhat.io"
        echo "Actual: $(cat /tmp/registrylogin.txt)"
        update_status 1
    fi
fi

echo "=============================================================="
echo "Verification complete."

# Print final task status
if [ $task_status -eq 0 ]; then
    echo "Task completed"
else
    echo "Task failed"
fi

exit $task_status
