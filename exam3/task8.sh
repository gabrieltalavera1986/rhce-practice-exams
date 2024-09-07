#!/bin/bash

# Initialize task status
task_status=0

# Function to update task status
update_status() {
    if [ $1 -ne 0 ]; then
        task_status=1
    fi
}

echo "Task 8 Verification: Install an External Ansible Role from a Compressed Archive"
echo "==============================================================================="

# Check if ~/rhce3/roles directory exists
if [ -d ~/rhce3/roles ]; then
    echo "[PASS] ~/rhce3/roles directory exists"
else
    echo "[FAIL] ~/rhce3/roles directory does not exist"
    update_status 1
fi

# Check if ~/rhce3/install.yml file exists
if [ -f ~/rhce3/install.yml ]; then
    echo "[PASS] ~/rhce3/install.yml file exists"
else
    echo "[FAIL] ~/rhce3/install.yml file does not exist"
    update_status 1
fi

# Check content of install.yml file
if [ -f ~/rhce3/install.yml ]; then
    if grep -q "src: https://github.com/gabrieltalavera1986/rhce-practice-exams/raw/main/exam3/varnish.tar.gz" ~/rhce3/install.yml &&
       grep -q "name: varnish" ~/rhce3/install.yml; then
        echo "[PASS] install.yml contains correct role information"
    else
        echo "[FAIL] install.yml does not contain correct role information"
        update_status 1
    fi
else
    echo "[FAIL] Unable to check install.yml content as file does not exist"
    update_status 1
fi

# Check if ansible.cfg file exists and contains correct roles_path
if [ -f ~/rhce3/ansible.cfg ]; then
    if grep -q "roles_path = ~/rhce3/roles" ~/rhce3/ansible.cfg; then
        echo "[PASS] ansible.cfg contains correct roles_path"
    else
        echo "[FAIL] ansible.cfg does not contain correct roles_path"
        update_status 1
    fi
else
    echo "[FAIL] ansible.cfg file does not exist in ~/rhce3 directory"
    update_status 1
fi

# Check if varnish role is installed
if ansible-galaxy role list | grep -q "varnish"; then
    echo "[PASS] varnish role is installed and listed by ansible-galaxy"
else
    echo "[FAIL] varnish role is not installed or not listed by ansible-galaxy"
    update_status 1
fi

# Check if varnish role directory exists
if [ -d ~/rhce3/roles/varnish ]; then
    echo "[PASS] varnish role directory exists in ~/rhce3/roles"
else
    echo "[FAIL] varnish role directory does not exist in ~/rhce3/roles"
    update_status 1
fi

echo "==============================================================================="
echo "Verification complete."

# Print final task status
if [ $task_status -eq 0 ]; then
    echo "Task completed"
else
    echo "Task failed"
fi

exit $task_status
