#!/bin/bash

# Initialize task status
task_status=0

# Function to update task status
update_status() {
    if [ $1 -ne 0 ]; then
        task_status=1
    fi
}

echo "Task 2 Verification: Ansible Inventory Management"
echo "================================================"

# Check if ansible-inventory command exists
if ! command -v ansible-inventory &> /dev/null; then
    echo "[FAIL] ansible-inventory command not found. Is Ansible installed correctly?"
    update_status 1
    echo "Task failed"
    exit 1
fi

# Get inventory in graph format
inventory=$(ansible-inventory --graph 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "[FAIL] Unable to read Ansible inventory. Check if the inventory file is correctly formatted."
    update_status 1
else
    echo "[PASS] Able to read Ansible inventory"

    # Check for correct structure
    expected_structure=(
        "@all:"
        "  |--@ungrouped:"
        "  |--@dc1:"
        "  |  |--@prod:"
        "  |  |  |--webserver01"
        "  |  |--@dev:"
        "  |  |  |--webserver02"
        "  |--@dc2:"
        "  |  |--@staging:"
        "  |  |  |--webserver03"
    )

    # Compare actual inventory with expected structure
    for line in "${expected_structure[@]}"; do
        if ! echo "$inventory" | grep -Fq "$line"; then
            echo "[FAIL] Missing or incorrect line: $line"
            update_status 1
        fi
    done

    # If no failures were recorded above, all checks passed
    if [ $task_status -eq 0 ]; then
        echo "[PASS] All inventory structure checks passed"
    fi

    # Additional checks for group memberships
    if echo "$inventory" | grep -q "  |--@dc1:" && 
       echo "$inventory" | grep -q "  |  |--@prod:" &&
       echo "$inventory" | grep -q "  |  |--@dev:"; then
        echo "[PASS] dc1 group includes prod and dev"
    else
        echo "[FAIL] dc1 group does not include both prod and dev"
        update_status 1
    fi

    if echo "$inventory" | grep -q "  |--@dc2:" && 
       echo "$inventory" | grep -q "  |  |--@staging:"; then
        echo "[PASS] dc2 group includes staging"
    else
        echo "[FAIL] dc2 group does not include staging"
        update_status 1
    fi
fi

echo "================================================"
echo "Verification complete."

# Print final task status
if [ $task_status -eq 0 ]; then
    echo "Task completed"
else
    echo "Task failed"
fi

exit $task_status
