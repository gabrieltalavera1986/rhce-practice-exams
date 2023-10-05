#!/bin/bash

# Initialize a flag to track installation status
all_installed=true

# Check ansible version
echo "Checking if ansible is installed..."
if ansible --version >/dev/null 2>&1; then
    echo "ansible is installed successfully."
else
    echo "ansible is NOT installed or not functioning properly."
    all_installed=false
fi

# Check ansible-navigator version
echo "Checking if ansible-navigator is installed..."
if ansible-navigator --version >/dev/null 2>&1; then
    echo "ansible-navigator is installed successfully."
else
    echo "ansible-navigator is NOT installed or not functioning properly."
    all_installed=false
fi

# Check if ansible user exists and has sudo access without password on web01, web02, and dev01
for host in web01 web02 dev01; do
    echo "Checking if ansible user exists on $host..."
    if ssh $host "id ansible" >/dev/null 2>&1; then
        echo "ansible user exists on $host."
        
        echo "Checking if ansible user has sudo access without password on $host..."
        if ssh $host "echo '' | sudo -S -l -U ansible" | grep -q NOPASSWD; then
            echo "ansible user has sudo access without password on $host."
        else
            echo "ansible user does NOT have sudo access without password on $host."
            all_installed=false
        fi
    else
        echo "ansible user does NOT exist on $host."
        all_installed=false
    fi
done

# If all checks are successful, print a success message
if $all_installed; then
    echo "This task has been completed successfully!"
    exit 0
else
    exit 1
fi
