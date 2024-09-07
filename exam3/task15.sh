#!/bin/bash

# Initialize task status
task_status=0

# Function to update task status
update_status() {
    if [ $1 -ne 0 ]; then
        task_status=1
    fi
}

echo "Task 15 Verification: Create Users, Configure Sudo Privileges, and Manage Group Memberships"
echo "=========================================================================================="

# Function to run commands on remote hosts and check output
check_remote() {
    local host="$1"
    local command="$2"
    local expected="$3"
    local message="$4"
    
    output=$(ssh $host "$command")
    if echo "$output" | grep -q "$expected"; then
        echo "[PASS] $host: $message"
    else
        echo "[FAIL] $host: $message"
        echo "Expected: $expected"
        echo "Got: $output"
        update_status 1
    fi
}

# Function to check group membership
check_group_membership() {
    local host="$1"
    local user="$2"
    local groups="$3"
    local message="$4"
    
    output=$(ssh $host "sudo id $user")
    all_pass=true
    for group in $groups; do
        if ! echo "$output" | grep -q "$group"; then
            all_pass=false
            break
        fi
    done
    
    if $all_pass; then
        echo "[PASS] $host: $message"
    else
        echo "[FAIL] $host: $message"
        echo "Expected groups: $groups"
        echo "Got: $output"
        update_status 1
    fi
}

# Get list of all hosts
all_hosts=$(ansible all --list-hosts | grep -v "hosts" | sed 's/^ *//g')

for host in $all_hosts; do
    echo "Checking $host:"
    
    # Check user creation
    for user in gandalf sam frodo; do
        check_remote "$host" "sudo getent passwd $user" "$user:" "User $user exists"
    done
    
    # Check sudo privileges
    for user in gandalf sam frodo; do
        check_remote "$host" "sudo grep -r '$user.*NOPASSWD: ALL' /etc/sudoers /etc/sudoers.d" "NOPASSWD: ALL" "User $user has sudo privileges without password"
    done
    
    # Check group memberships
    check_group_membership "$host" "gandalf" "wheel adm" "Gandalf is in wheel and adm groups"
    check_group_membership "$host" "sam" "wheel devops" "Sam is in wheel and devops groups"
    check_group_membership "$host" "frodo" "wheel developers" "Frodo is in wheel and developers groups"
    
    # Check if the groups exist
    for group in wheel adm devops developers; do
        check_remote "$host" "sudo getent group $group" "$group:" "Group $group exists"
    done
    
    # Check if users can execute sudo commands
    for user in gandalf sam frodo; do
        check_remote "$host" "sudo -u $user sudo -n true && echo 'Sudo works'" "Sudo works" "User $user can execute sudo commands without password"
    done
    
    echo "--------------------"
done

echo "=========================================================================================="
echo "Verification complete."

# Print final task status
if [ $task_status -eq 0 ]; then
    echo "Task completed"
else
    echo "Task failed"
fi

exit $task_status
