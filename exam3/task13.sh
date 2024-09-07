#!/bin/bash

# Initialize task status
task_status=0

# Function to update task status
update_status() {
    if [ $1 -ne 0 ]; then
        task_status=1
    fi
}

echo "Task 13 Verification: Configure systemd Journal Using RHEL System Role"
echo "====================================================================="

# Local checks
# Check if configure_journal.yml exists in ~/rhce3/
if [ -f ~/rhce3/configure_journal.yml ]; then
    echo "[PASS] configure_journal.yml exists in ~/rhce3/"
else
    echo "[FAIL] configure_journal.yml does not exist in ~/rhce3/"
    update_status 1
    exit $task_status
fi

# Check playbook content
echo "Checking configure_journal.yml content:"

# Function to check for a string in the file
check_content() {
    if grep -q "$1" ~/rhce3/configure_journal.yml; then
        echo "[PASS] $2"
    else
        echo "[FAIL] $2"
        update_status 1
    fi
}

# Perform checks
check_content "hosts: all" "Playbook targets all hosts"
check_content "become: yes" "Playbook uses become for privilege escalation"
check_content "journald_persistent: true" "Persistent logging is enabled"
check_content "journald_max_disk_size: 4096" "Maximum disk space is set to 4096 MB"
check_content "journald_per_user: true" "Per-user logging is enabled"
check_content "journald_sync_interval: 5" "Sync interval is set to 5 minutes"
check_content "roles:" "Roles section is present"
check_content "rhel-system-roles.journald" "Journald RHEL system role is used"

# Check if the journald role is present in the roles directory
if [ -d ~/rhce3/roles/rhel-system-roles.journald ]; then
    echo "[PASS] Journald RHEL system role is present in ~/rhce3/roles/"
else
    echo "[FAIL] Journald RHEL system role is not present in ~/rhce3/roles/"
    update_status 1
fi

# Check ansible.cfg for correct roles_path
if [ -f ~/rhce3/ansible.cfg ]; then
    if grep -q "/rhce3/roles" ~/rhce3/ansible.cfg; then
        echo "[PASS] ansible.cfg contains correct roles_path"
    else
        echo "[FAIL] ansible.cfg does not contain correct roles_path"
        update_status 1
    fi
else
    echo "[FAIL] ansible.cfg does not exist in ~/rhce3/"
    update_status 1
fi

# Remote checks
echo "Performing remote checks..."

# Get list of all hosts
all_hosts=$(ansible all --list-hosts | grep -v "hosts" | sed 's/^ *//g')

for host in $all_hosts; do
    echo "Checking $host:"
    
    # Function to check configuration across all relevant files
    check_config() {
        local pattern="$1"
        local expected="$2"
        local message="$3"
        local compare_func="$4"
        
        if ssh $host "grep -q '$pattern' /etc/systemd/journald.conf /etc/systemd/journald.conf.d/*.conf 2>/dev/null"; then
            local value=$(ssh $host "grep '$pattern' /etc/systemd/journald.conf /etc/systemd/journald.conf.d/*.conf 2>/dev/null | tail -n1 | cut -d'=' -f2")
            if $compare_func "$value" "$expected"; then
                echo "  [PASS] $message on $host"
            else
                echo "  [FAIL] $message on $host (Expected: $expected, Found: $value)"
                update_status 1
            fi
        else
            echo "  [FAIL] $message not found on $host"
            update_status 1
        fi
    }

    # Comparison functions
    compare_storage() {
        [ "$1" = "$2" ]
    }

    compare_size() {
        [ "$1" = "$2" ] || [ "$1" = "4096M" -a "$2" = "4G" ]
    }

    compare_split_mode() {
        [ "$1" = "$2" ]
    }

    compare_time() {
        [ "$1" = "$2" ] || [ "$1" = "5m" -a "$2" = "5min" ]
    }
    
    # Check if persistent logging is enabled
    check_config "^Storage=" "persistent" "Persistent logging is enabled" compare_storage
    
    # Check maximum disk space setting
    check_config "^SystemMaxUse=" "4G" "Maximum disk space is set to 4G" compare_size
    
    # Check if per-user logging is enabled
    check_config "^SplitMode=" "uid" "Per-user logging is enabled" compare_split_mode
    
    # Check sync interval
    check_config "^SyncIntervalSec=" "5min" "Sync interval is set to 5 minutes" compare_time
done

echo "====================================================================="
echo "Verification complete."

# Print final task status
if [ $task_status -eq 0 ]; then
    echo "Task completed"
else
    echo "Task failed"
fi

exit $task_status
