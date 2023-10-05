#!/bin/bash

PLAYBOOK_PATH="fixme.yml"
HOST="web01"

# Check the playbook for the mentioned corrections
if grep -q 'install_package: "vsftpd"' "$PLAYBOOK_PATH" && \
   grep -q 'service_name: "vsftpd"' "$PLAYBOOK_PATH" && \
   grep -q 'name: "{{ install_package }}"' "$PLAYBOOK_PATH" && \
   grep -q 'state: "installed"' "$PLAYBOOK_PATH" && \
   grep -q 'name: "{{ service_name }}"' "$PLAYBOOK_PATH" && \
   grep -q 'state: started' "$PLAYBOOK_PATH"; then
    echo "Playbook corrections are in place."
else
    echo "Playbook corrections are NOT in place."
    exit 1
fi

# SSH into web01 and verify the settings

# Check if vsftpd is installed
if ssh "$HOST" "rpm -q vsftpd"; then
    echo "vsftpd is installed on $HOST."
else
    echo "vsftpd is NOT installed on $HOST."
    exit 1
fi

# Check if vsftpd service is running and enabled
if ssh "$HOST" "systemctl is-active vsftpd" | grep -q "active" && \
   ssh "$HOST" "systemctl is-enabled vsftpd" | grep -q "enabled"; then
    echo "vsftpd service is running and enabled on $HOST."
else
    echo "vsftpd service is NOT correctly set up on $HOST."
    exit 1
fi

echo "All checks passed. The task has been completed successfully!"
exit 0
