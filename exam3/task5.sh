#!/bin/bash

# Initialize task status
task_status=0

# Function to update task status
update_status() {
    if [ $1 -ne 0 ]; then
        task_status=1
    fi
}

echo "Task 5 Verification: Environment-Specific Software Installation"
echo "=============================================================="

# Check if ~/rhce3 directory exists
if [ -d ~/rhce3 ]; then
    echo "[PASS] ~/rhce3 directory exists"
else
    echo "[FAIL] ~/rhce3 directory does not exist"
    update_status 1
fi

# Check if software_install.yml exists in ~/rhce3
if [ -f ~/rhce3/software_install.yml ]; then
    echo "[PASS] software_install.yml exists in ~/rhce3"
else
    echo "[FAIL] software_install.yml does not exist in ~/rhce3"
    update_status 1
fi

# Check group_vars directory and files
if [ -d ~/rhce3/group_vars ]; then
    echo "[PASS] group_vars directory exists"
    for env in prod dev staging; do
        if [ -f ~/rhce3/group_vars/$env.yml ]; then
            echo "[PASS] $env.yml exists in group_vars"
            # Check content of group_vars files
            case $env in
                prod)
                    if grep -q "httpd" ~/rhce3/group_vars/$env.yml; then
                        echo "[PASS] prod.yml contains httpd package"
                    else
                        echo "[FAIL] prod.yml does not contain httpd package"
                        update_status 1
                    fi
                    ;;
                dev)
                    if grep -q "nginx" ~/rhce3/group_vars/$env.yml; then
                        echo "[PASS] dev.yml contains nginx package"
                    else
                        echo "[FAIL] dev.yml does not contain nginx package"
                        update_status 1
                    fi
                    ;;
                staging)
                    if grep -q "httpd" ~/rhce3/group_vars/$env.yml && grep -q "redis" ~/rhce3/group_vars/$env.yml; then
                        echo "[PASS] staging.yml contains httpd and redis packages"
                    else
                        echo "[FAIL] staging.yml does not contain both httpd and redis packages"
                        update_status 1
                    fi
                    ;;
            esac
        else
            echo "[FAIL] $env.yml does not exist in group_vars"
            update_status 1
        fi
    done
else
    echo "[FAIL] group_vars directory does not exist"
    update_status 1
fi

# Check host_vars directory and files
if [ -d ~/rhce3/host_vars ]; then
    echo "[PASS] host_vars directory exists"
    for server in webserver01 webserver02 webserver03; do
        if [ -f ~/rhce3/host_vars/$server.yml ]; then
            echo "[PASS] $server.yml exists in host_vars"
            # Check content of host_vars files
            case $server in
                webserver01)
                    if grep -q "nano" ~/rhce3/host_vars/$server.yml; then
                        echo "[PASS] webserver01.yml specifies nano as editor"
                    else
                        echo "[FAIL] webserver01.yml does not specify nano as editor"
                        update_status 1
                    fi
                    ;;
                webserver02)
                    if grep -q "vim" ~/rhce3/host_vars/$server.yml; then
                        echo "[PASS] webserver02.yml specifies vim as editor"
                    else
                        echo "[FAIL] webserver02.yml does not specify vim as editor"
                        update_status 1
                    fi
                    ;;
                webserver03)
                    if grep -q "emacs" ~/rhce3/host_vars/$server.yml; then
                        echo "[PASS] webserver03.yml specifies emacs as editor"
                    else
                        echo "[FAIL] webserver03.yml does not specify emacs as editor"
                        update_status 1
                    fi
                    ;;
            esac
        else
            echo "[FAIL] $server.yml does not exist in host_vars"
            update_status 1
        fi
    done
else
    echo "[FAIL] host_vars directory does not exist"
    update_status 1
fi

# Check playbook content
if [ -f ~/rhce3/software_install.yml ]; then
    if grep -q "ansible.builtin.yum" ~/rhce3/software_install.yml && 
       grep -q "when: web_packages is defined" ~/rhce3/software_install.yml &&
       grep -q "when: editor is defined" ~/rhce3/software_install.yml; then
        echo "[PASS] software_install.yml contains required tasks and conditions"
    else
        echo "[FAIL] software_install.yml is missing required tasks or conditions"
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
