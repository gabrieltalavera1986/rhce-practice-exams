#!/bin/bash

# Initialize task status
task_status=0

# Function to update task status
update_status() {
    if [ $1 -ne 0 ]; then
        task_status=1
    fi
}

echo "Task 7 Verification: MOTD Configuration Using Jinja2 Templates"
echo "============================================================="

# Local checks
echo "Performing local checks..."

# Check if ~/rhce3 directory exists
if [ -d ~/rhce3 ]; then
    echo "[PASS] ~/rhce3 directory exists"
else
    echo "[FAIL] ~/rhce3 directory does not exist"
    update_status 1
fi

# Check if configure_motd.yml exists in ~/rhce3
if [ -f ~/rhce3/configure_motd.yml ]; then
    echo "[PASS] configure_motd.yml exists in ~/rhce3"
else
    echo "[FAIL] configure_motd.yml does not exist in ~/rhce3"
    update_status 1
fi

# Check if motd.j2 exists in ~/rhce3
if [ -f ~/rhce3/motd.j2 ]; then
    echo "[PASS] motd.j2 exists in ~/rhce3"
else
    echo "[FAIL] motd.j2 does not exist in ~/rhce3"
    update_status 1
fi

# Check playbook content
if [ -f ~/rhce3/configure_motd.yml ]; then
    if grep -q "hosts: all" ~/rhce3/configure_motd.yml &&
       grep -q "become: yes" ~/rhce3/configure_motd.yml &&
       grep -q "gather_facts: yes" ~/rhce3/configure_motd.yml &&
       grep -q "ansible.builtin.template:" ~/rhce3/configure_motd.yml &&
       grep -q "src: motd.j2" ~/rhce3/configure_motd.yml &&
       grep -q "dest: /etc/motd" ~/rhce3/configure_motd.yml; then
        echo "[PASS] configure_motd.yml contains required configuration"
    else
        echo "[FAIL] configure_motd.yml is missing required configuration"
        update_status 1
    fi
else
    echo "[FAIL] Unable to check playbook content as configure_motd.yml does not exist"
    update_status 1
fi

# Check template content
if [ -f ~/rhce3/motd.j2 ]; then
    if grep -q "Hostname: {{ ansible_hostname }}" ~/rhce3/motd.j2 &&
       grep -q "IP Address: {{ ansible_default_ipv4.address }}" ~/rhce3/motd.j2 &&
       grep -q "Groups:" ~/rhce3/motd.j2 &&
       grep -q "{% for group in groups %}" ~/rhce3/motd.j2 &&
       grep -q "{% if group != 'all' and group != 'ungrouped'" ~/rhce3/motd.j2 &&
       grep -q "Timezone: {{ ansible_date_time.tz }}" ~/rhce3/motd.j2; then
        echo "[PASS] motd.j2 contains required template structure"
    else
        echo "[FAIL] motd.j2 is missing required template structure"
        update_status 1
    fi
else
    echo "[FAIL] Unable to check template content as motd.j2 does not exist"
    update_status 1
fi

# Remote checks
echo "Performing remote checks..."

# List of servers to check
servers=("webserver01" "webserver02" "webserver03")

for server in "${servers[@]}"; do
    echo "Checking $server:"
    
    # Check if /etc/motd exists and has content
    if ssh $server '[ -s /etc/motd ]'; then
        echo "[PASS] /etc/motd exists and has content on $server"
        
        # Check MOTD content
        motd_content=$(ssh $server 'cat /etc/motd')
        
        if echo "$motd_content" | grep -q "Hostname: $server"; then
            echo "[PASS] MOTD contains correct hostname on $server"
        else
            echo "[FAIL] MOTD does not contain correct hostname on $server"
            update_status 1
        fi
        
        if echo "$motd_content" | grep -q "IP Address:"; then
            echo "[PASS] MOTD contains IP Address on $server"
        else
            echo "[FAIL] MOTD does not contain IP Address on $server"
            update_status 1
        fi
        
        if echo "$motd_content" | grep -q "Groups:"; then
            echo "[PASS] MOTD contains Groups section on $server"
        else
            echo "[FAIL] MOTD does not contain Groups section on $server"
            update_status 1
        fi
        
        if echo "$motd_content" | grep -q "Timezone:"; then
            echo "[PASS] MOTD contains Timezone on $server"
        else
            echo "[FAIL] MOTD does not contain Timezone on $server"
            update_status 1
        fi
    else
        echo "[FAIL] /etc/motd does not exist or is empty on $server"
        update_status 1
    fi
done

echo "============================================================="
echo "Verification complete."

# Print final task status
if [ $task_status -eq 0 ]; then
    echo "Task completed"
else
    echo "Task failed"
fi

exit $task_status
