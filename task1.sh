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

# If both tools are installed and functioning, print a success message
if $all_installed; then
    echo "This task has been completed successfully!"
    exit 0
else
    exit 1
fi
