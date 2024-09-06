#!/bin/bash

# Initialize a variable to track overall task status
task_status=0

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to update task status
update_status() {
    if [ $1 -ne 0 ]; then
        task_status=1
    fi
}

echo "Task 1 Verification:"
echo "===================="

# Check Ansible and Ansible Navigator installation on control host
echo "Checking Ansible and Ansible Navigator installation:"
if command_exists ansible && command_exists ansible-navigator; then
    echo "  [PASS] Ansible and Ansible Navigator are installed"
else
    echo "  [FAIL] Ansible and/or Ansible Navigator are not installed"
    update_status 1
fi

# Check ansible user and sudo privileges on all hosts
for host in webserver01 webserver02 webserver03; do
    echo "Checking ansible user and sudo privileges on $host:"
    if ssh $host "id ansible && sudo -l -U ansible | grep -q 'NOPASSWD: ALL'" 2>/dev/null; then
        echo "  [PASS] ansible user exists and has correct sudo privileges on $host"
    else
        echo "  [FAIL] ansible user does not exist or does not have correct sudo privileges on $host"
        update_status 1
    fi
done

# Check if control node can reach each server using short name
echo "Checking connectivity to servers using short names:"
for server in webserver01 webserver02 webserver03; do
    if ping -c 1 $server >/dev/null 2>&1; then
        echo "  [PASS] Can reach $server using short name"
    else
        echo "  [FAIL] Cannot reach $server using short name"
        update_status 1
    fi
done

# Check SSH key-based authentication
echo "Checking SSH key-based authentication:"
for server in webserver01 webserver02 webserver03; do
    if ssh -o PasswordAuthentication=no ansible@$server "echo 'SSH connection successful'" >/dev/null 2>&1; then
        echo "  [PASS] SSH key-based authentication successful for $server"
    else
        echo "  [FAIL] SSH key-based authentication failed for $server"
        update_status 1
    fi
done

echo "===================="
echo "Verification complete."

# Print final task status
if [ $task_status -eq 0 ]; then
    echo "Task completed"
else
    echo "Task failed"
fi

exit $task_status
