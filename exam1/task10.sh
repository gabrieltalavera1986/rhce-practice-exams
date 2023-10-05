#!/bin/bash

# Check if ansible.posix and community.general collections are installed
if ansible-galaxy collection list ansible.posix | grep -q "ansible.posix"; then
    echo "ansible.posix collection is installed."
else
    echo "ansible.posix collection is NOT installed."
    exit 1
fi

if ansible-galaxy collection list community.general | grep -q "community.general"; then
    echo "community.general collection is installed."
else
    echo "community.general collection is NOT installed."
    exit 1
fi

# SSH into dev01 and verify the settings
HOST="dev01"

# Check SELinux mode
if ssh "$HOST" "getenforce" | grep -q "Enforcing"; then
    echo "SELinux is in enforcing mode on $HOST."
else
    echo "SELinux is NOT in enforcing mode on $HOST."
    exit 1
fi

# Check if httpd is installed, running, and enabled
if ssh "$HOST" "rpm -q httpd" && ssh "$HOST" "systemctl is-active httpd" | grep -q "active" && ssh "$HOST" "systemctl is-enabled httpd" | grep -q "enabled"; then
    echo "httpd is installed, running, and enabled on $HOST."
else
    echo "httpd is NOT correctly set up on $HOST."
    exit 1
fi

# Check if SELinux allows Apache to listen on TCP port 82
if ssh "$HOST" "sudo semanage port -l | grep http_port_t" | grep -q "82"; then
    echo "SELinux allows Apache to listen on TCP port 82 on $HOST."
else
    echo "SELinux does NOT allow Apache to listen on TCP port 82 on $HOST."
    exit 1
fi

# Check if Apache is set to listen on port 82
if ssh "$HOST" "grep '^Listen 82' /etc/httpd/conf/httpd.conf"; then
    echo "Apache is set to listen on port 82 on $HOST."
else
    echo "Apache is NOT set to listen on port 82 on $HOST."
    exit 1
fi

echo "All checks passed. The task has been completed successfully!"
exit 0
