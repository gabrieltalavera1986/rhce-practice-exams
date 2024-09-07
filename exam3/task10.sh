#!/bin/bash

# Initialize task status
task_status=0

# Function to update task status
update_status() {
    if [ $1 -ne 0 ]; then
        task_status=1
    fi
}

echo "Task 10 Verification: Collect and Organize System Facts by Host"
echo "=============================================================="

# Check if collect_system_facts.yml exists in ~/rhce3
if [ -f ~/rhce3/collect_system_facts.yml ]; then
    echo "[PASS] collect_system_facts.yml exists in ~/rhce3"
else
    echo "[FAIL] collect_system_facts.yml does not exist in ~/rhce3"
    update_status 1
    exit $task_status
fi

# Check playbook content
echo "Checking playbook content:"

if grep -q "hosts: all" ~/rhce3/collect_system_facts.yml; then
    echo "[PASS] Playbook targets all hosts"
else
    echo "[FAIL] Playbook does not target all hosts"
    update_status 1
fi

if grep -q "path: /home/ansible/host_inventory" ~/rhce3/collect_system_facts.yml; then
    echo "[PASS] Playbook creates host_inventory directory"
else
    echo "[FAIL] Playbook does not create host_inventory directory"
    update_status 1
fi

if grep -q "ansible_memfree_mb" ~/rhce3/collect_system_facts.yml &&
   grep -q "ansible_bios_vendor" ~/rhce3/collect_system_facts.yml &&
   grep -q "ansible_bios_version" ~/rhce3/collect_system_facts.yml &&
   grep -q "ansible_kernel" ~/rhce3/collect_system_facts.yml; then
    echo "[PASS] Playbook collects required system facts"
else
    echo "[FAIL] Playbook does not collect all required system facts"
    update_status 1
fi

# Remote checks
echo "Performing remote checks..."

# Get list of all hosts
all_hosts=$(ansible all --list-hosts | grep -v "hosts" | sed 's/^ *//g')

for host in $all_hosts; do
    echo "Checking $host:"
    
    # Check if host_inventory directory exists
    if ssh $host '[ -d /home/ansible/host_inventory ]'; then
        echo "  [PASS] host_inventory directory exists on $host"
    else
        echo "  [FAIL] host_inventory directory does not exist on $host"
        update_status 1
        continue
    fi
    
    # Check if fact file exists for this host
    if ssh $host "[ -f /home/ansible/host_inventory/${host}.txt ]"; then
        echo "  [PASS] Fact file ${host}.txt exists"
        
        # Check content of the fact file
        fact_content=$(ssh $host "cat /home/ansible/host_inventory/${host}.txt")
        
        if echo "$fact_content" | grep -q "Hostname: $host" &&
           echo "$fact_content" | grep -q "Free Memory:" &&
           echo "$fact_content" | grep -q "BIOS Vendor:" &&
           echo "$fact_content" | grep -q "BIOS Version:" &&
           echo "$fact_content" | grep -q "Kernel Version:"; then
            echo "  [PASS] Fact file contains all required information"
        else
            echo "  [FAIL] Fact file is missing some required information"
            update_status 1
        fi
    else
        echo "  [FAIL] Fact file ${host}.txt does not exist on $host"
        update_status 1
    fi
done

echo "=============================================================="
echo "Verification complete."

# Print final task status
if [ $task_status -eq 0 ]; then
    echo "Task completed"
else
    echo "Task failed"
fi

exit $task_status
