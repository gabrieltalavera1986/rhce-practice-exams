#!/bin/bash

# Initialize task status
task_status=0

# Function to update task status
update_status() {
    if [ $1 -ne 0 ]; then
        task_status=1
    fi
}

echo "Task 9 Verification: Conditional MariaDB Installation"
echo "===================================================="

# Check if conditional_install.yml exists in ~/rhce3
if [ -f ~/rhce3/conditional_install.yml ]; then
    echo "[PASS] conditional_install.yml exists in ~/rhce3"
else
    echo "[FAIL] conditional_install.yml does not exist in ~/rhce3"
    update_status 1
    exit $task_status
fi

# Check playbook content
echo "Checking playbook content:"

if grep -q "hosts: dc1" ~/rhce3/conditional_install.yml; then
    echo "[PASS] Playbook targets dc1 group"
else
    echo "[FAIL] Playbook does not target dc1 group"
    update_status 1
fi

if grep -q "'postgresql' not" ~/rhce3/conditional_install.yml; then
    echo "[PASS] Playbook checks for absence of PostgreSQL"
else
    echo "[FAIL] Playbook does not check for absence of PostgreSQL"
    update_status 1
fi

if grep -q "'dev' in group_names" ~/rhce3/conditional_install.yml; then
    echo "[PASS] Playbook checks for dev environment"
else
    echo "[FAIL] Playbook does not check for dev environment"
    update_status 1
fi

# Remote checks
echo "Performing remote checks..."

# Get list of hosts in dc1 group
dc1_hosts=$(ansible dc1 --list-hosts | grep -v "hosts" | sed 's/^ *//g')

for host in $dc1_hosts; do
    echo "Checking $host:"
    
    # Check if the host is in dev group
    if ansible $host -m debug -a "var=group_names" | grep -q "dev"; then
        echo "  [INFO] $host is in dev group"
        
        # Check if MariaDB is installed
        if ssh $host 'rpm -q mariadb-server' &>/dev/null; then
            echo "  [PASS] MariaDB is installed on $host"
        else
            echo "  [INFO] MariaDB is not installed on $host"
        fi
    else
        echo "  [INFO] $host is not in dev group"
        
        # Check that MariaDB is not installed
        if ! ssh $host 'rpm -q mariadb-server' &>/dev/null; then
            echo "  [PASS] MariaDB is not installed on $host (as expected)"
        else
            echo "  [FAIL] MariaDB is installed on $host but it's not in dev group"
            update_status 1
        fi
    fi
    
    # Check PostgreSQL installation
    if ssh $host 'rpm -q postgresql-server' &>/dev/null; then
        echo "  [INFO] PostgreSQL is installed on $host"
    else
        echo "  [INFO] PostgreSQL is not installed on $host"
    fi
done

echo "===================================================="
echo "Verification complete."

# Print final task status
if [ $task_status -eq 0 ]; then
    echo "Task completed"
else
    echo "Task failed"
fi

exit $task_status
