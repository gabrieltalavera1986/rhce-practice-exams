#!/bin/bash

# Define hosts
hosts=("web01" "web02" "dev01")

# Check if the role directory and required files exist
if [[ ! -d secure_ssh ]]; then
    echo "secure_ssh role directory does not exist."
    exit 1
fi

if [[ ! -f secure_ssh/tasks/main.yml ]] || [[ ! -f secure_ssh/handlers/main.yml ]]; then
    echo "Required files within the secure_ssh role are missing."
    exit 1
fi

# Check the SSH settings on each host
for host in "${hosts[@]}"; do
    echo "Checking $host..."

    # Check X11Forwarding
    if ! ssh "$host" "sudo grep -q '^X11Forwarding no' /etc/ssh/sshd_config"; then
        echo "X11Forwarding setting is incorrect on $host."
        exit 1
    fi

    # Check PermitRootLogin
    if ! ssh "$host" "sudo grep -q '^PermitRootLogin no' /etc/ssh/sshd_config"; then
        echo "PermitRootLogin setting is incorrect on $host."
        exit 1
    fi

    # Check MaxAuthTries
    if ! ssh "$host" "sudo grep -q '^MaxAuthTries 3' /etc/ssh/sshd_config"; then
        echo "MaxAuthTries setting is incorrect on $host."
        exit 1
    fi

    # Check AllowTcpForwarding
    if ! ssh "$host" "sudo grep -q '^AllowTcpForwarding no' /etc/ssh/sshd_config"; then
        echo "AllowTcpForwarding setting is incorrect on $host."
        exit 1
    fi

    echo "SSH settings are correctly configured on $host."
done

echo "All settings are correctly configured!"
exit 0
