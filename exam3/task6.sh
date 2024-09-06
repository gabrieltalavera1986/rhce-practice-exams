#!/bin/bash

# Initialize task status
task_status=0

# Function to update task status
update_status() {
    if [ $1 -ne 0 ]; then
        task_status=1
    fi
}

echo "Task 6 Verification: Dynamically Configure Apache to Listen on Specific IP Address"
echo "=================================================================================="

# Local checks
echo "Performing local checks..."

# Check if ~/rhce3 directory exists
if [ -d ~/rhce3 ]; then
    echo "[PASS] ~/rhce3 directory exists"
else
    echo "[FAIL] ~/rhce3 directory does not exist"
    update_status 1
fi

# Check if configure_apache.yml exists in ~/rhce3
if [ -f ~/rhce3/configure_apache.yml ]; then
    echo "[PASS] configure_apache.yml exists in ~/rhce3"
else
    echo "[FAIL] configure_apache.yml does not exist in ~/rhce3"
    update_status 1
fi

# Check playbook content
if [ -f ~/rhce3/configure_apache.yml ]; then
    # Check for necessary components in the playbook
    if grep -q "hosts: all" ~/rhce3/configure_apache.yml; then
        echo "[PASS] Playbook targets all hosts"
    else
        echo "[FAIL] Playbook does not target all hosts"
        update_status 1
    fi

    if grep -q "gather_facts: yes" ~/rhce3/configure_apache.yml; then
        echo "[PASS] Playbook gathers facts"
    else
        echo "[FAIL] Playbook does not gather facts"
        update_status 1
    fi

    if grep -q "ansible.builtin.package_facts:" ~/rhce3/configure_apache.yml; then
        echo "[PASS] Playbook gathers package facts"
    else
        echo "[FAIL] Playbook does not gather package facts"
        update_status 1
    fi

    if grep -q "ansible.builtin.lineinfile:" ~/rhce3/configure_apache.yml &&
       grep -q "path: /etc/httpd/conf/httpd.conf" ~/rhce3/configure_apache.yml &&
       grep -q "regexp: '\^Listen'" ~/rhce3/configure_apache.yml &&
       grep -q "line: \"Listen {{ ansible_default_ipv4.address }}:80\"" ~/rhce3/configure_apache.yml; then
        echo "[PASS] Playbook configures Apache to listen on specific IP"
    else
        echo "[FAIL] Playbook does not correctly configure Apache to listen on specific IP"
        update_status 1
    fi

    if grep -q "when: \"'httpd' in ansible_facts.packages\"" ~/rhce3/configure_apache.yml; then
        echo "[PASS] Playbook includes condition to run only where Apache is installed"
    else
        echo "[FAIL] Playbook does not include condition to run only where Apache is installed"
        update_status 1
    fi

    if grep -q "handlers:" ~/rhce3/configure_apache.yml &&
       grep -q "restart apache" ~/rhce3/configure_apache.yml &&
       grep -q "ansible.builtin.service:" ~/rhce3/configure_apache.yml &&
       grep -q "name: httpd" ~/rhce3/configure_apache.yml &&
       grep -q "state: restarted" ~/rhce3/configure_apache.yml; then
        echo "[PASS] Playbook includes handler to restart Apache"
    else
        echo "[FAIL] Playbook does not include handler to restart Apache"
        update_status 1
    fi
else
    echo "[FAIL] Unable to check playbook content as configure_apache.yml does not exist"
    update_status 1
fi

# Remote checks
echo "Performing remote checks..."

# List of servers to check
servers=("webserver01" "webserver02" "webserver03")

for server in "${servers[@]}"; do
    echo "Checking $server:"
    
    # Check if Apache is installed
    if ssh $server 'rpm -q httpd' &>/dev/null; then
        echo "[PASS] Apache (httpd) is installed on $server"
        
        # Check the Listen directive in httpd.conf
        listen_ip=$(ssh $server "grep '^Listen' /etc/httpd/conf/httpd.conf | awk '{print \$2}' | cut -d':' -f1")
        server_ip=$(ssh $server "hostname -I | awk '{print \$1}'")
        
        if [ "$listen_ip" == "$server_ip" ]; then
            echo "[PASS] Apache is configured to listen on the correct IP ($listen_ip) on $server"
        else
            echo "[FAIL] Apache is not configured to listen on the correct IP on $server"
            echo "       Expected: $server_ip, Actual: $listen_ip"
            update_status 1
        fi
    else
        echo "[INFO] Apache (httpd) is not installed on $server"
    fi
done

echo "=================================================================================="
echo "Verification complete."

# Print final task status
if [ $task_status -eq 0 ]; then
    echo "Task completed"
else
    echo "Task failed"
fi

exit $task_status
