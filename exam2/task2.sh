#!/bin/bash

# Define hosts
hosts=("web03" "web04" "staging01")

# Check if ansible and ansible-navigator are installed
if ! ansible --version >/dev/null 2>&1; then
    echo "ansible is NOT installed or not functioning properly."
    exit 1
fi

if ! ansible-navigator --version >/dev/null 2>&1; then
    echo "ansible-navigator is NOT installed or not functioning properly."
    exit 1
fi

# Check if SSH key exists for ansible user
if [[ ! -f "/home/ansible/.ssh/id_rsa" ]] || [[ ! -f "/home/ansible/.ssh/id_rsa.pub" ]]; then
    echo "SSH key pair for ansible user is missing."
    exit 1
fi

# Check for ansible user, sudo privileges, and SSH key authentication on each host
for host in "${hosts[@]}"; do
    echo "Checking $host..."

    # Check if ansible user exists
    if ! ssh "$host" "id ansible" >/dev/null 2>&1; then
        echo "ansible user does NOT exist on $host."
        exit 1
    fi

    # Check if ansible user has sudo access without password
    if ! ssh "$host" "echo '' | sudo -S -l -U ansible" | grep -q NOPASSWD; then
        echo "ansible user does NOT have sudo access without password on $host."
        exit 1
    fi

    # Check if control node can SSH into the host without password
    if ! ssh -o BatchMode=yes -o ConnectTimeout=5 ansible@"$host" "echo connected to $host" >/dev/null 2>&1; then
        echo "Cannot SSH into $host without a password."
        exit 1
    fi

    echo "$host is correctly configured."
done

echo "All checks passed. The setup is correctly configured!"
exit 0
