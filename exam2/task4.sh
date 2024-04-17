#!/bin/bash

STAGING_HOST="staging01"
VSFTPD_CONFIG="/etc/vsftpd/vsftpd.conf"

# Check if vsftpd is installed
if ! ssh "$STAGING_HOST" "rpm -q vsftpd"; then
    echo "vsftpd is NOT installed on $STAGING_HOST."
    exit 1
fi

# Check if firewall is active and allows FTP traffic
if ! ssh "$STAGING_HOST" "sudo firewall-cmd --state" | grep -q "running"; then
    echo "Firewall is NOT active on $STAGING_HOST."
    exit 1
fi

if ! ssh "$STAGING_HOST" "sudo firewall-cmd --list-ports" | grep -q "21/tcp"; then
    echo "FTP traffic on port 21 is NOT allowed on $STAGING_HOST."
    exit 1
fi

# Check if vsftpd service is running
if ! ssh "$STAGING_HOST" "systemctl is-active vsftpd" | grep -q "active"; then
    echo "vsftpd service is NOT running on $STAGING_HOST."
    exit 1
fi

# Check if vsftpd service is enabled
if ! ssh "$STAGING_HOST" "systemctl is-enabled vsftpd" | grep -q "enabled"; then
    echo "vsftpd service is NOT enabled on $STAGING_HOST."
    exit 1
fi

# Check if welcome.txt exists in the default vsftpd directory
if ! ssh "$STAGING_HOST" "test -f /var/ftp/welcome.txt"; then
    echo "welcome.txt does NOT exist in the default vsftpd directory on $STAGING_HOST."
    exit 1
fi

# Check the content of welcome.txt
HOSTNAME=$(ssh "$STAGING_HOST" "hostname -s")
EXPECTED_CONTENT="welcome to the ftp service at $HOSTNAME"
if ! ssh "$STAGING_HOST" "cat /var/ftp/welcome.txt" | grep -q "$EXPECTED_CONTENT"; then
    echo "welcome.txt content is NOT correct on $STAGING_HOST."
    exit 1
fi

echo "All checks passed. The task has been completed successfully!"
exit 0
