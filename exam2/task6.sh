#!/bin/bash

# Define the managed hosts
MANAGED_HOSTS=("web03" "web04" "staging01")

# Check if the playbook exists
if [[ ! -f backup_hosts.yml ]]; then
    echo "backup_hosts.yml playbook does not exist."
    exit 1
fi

# Check if the fetch module is used in the playbook
if ! grep -q "fetch:" backup_hosts.yml; then
    echo "The fetch module is not being used in backup_hosts.yml."
    exit 1
fi

# Check if the backup directory exists
if [[ ! -d /tmp/hosts_backup/ ]]; then
    echo "/tmp/hosts_backup/ directory does not exist."
    exit 1
fi

# Check if the /etc/hosts file from each managed host is present in the backup directory
for host in "${MANAGED_HOSTS[@]}"; do
    if [[ ! -f /tmp/hosts_backup/hosts-$host ]]; then
        echo "/etc/hosts file from $host is not backed up in /tmp/hosts_backup/hosts-$host."
        exit 1
    fi
done

echo "All checks passed. The task has been completed successfully!"
exit 0
