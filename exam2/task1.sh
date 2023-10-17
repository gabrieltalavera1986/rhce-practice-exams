#!/bin/bash

# Define the path to the inventory file
INVENTORY_PATH="/home/ansible/rhce2/hosts"

# Check if the rhce2 directory exists
if [[ ! -d "/home/ansible/rhce2" ]]; then
    echo "The rhce2 directory does not exist in the ansible user's home folder."
    exit 1
fi

# Check if the inventory file exists
if [[ ! -f "$INVENTORY_PATH" ]]; then
    echo "The inventory file 'hosts' does not exist in the rhce2 directory."
    exit 1
fi

# Check the content of the inventory file
if ! grep -q "^\[web\]$" "$INVENTORY_PATH" || \
   ! grep -q "^web03" "$INVENTORY_PATH" || \
   ! grep -q "^web04" "$INVENTORY_PATH" || \
   ! grep -q "^\[staging\]$" "$INVENTORY_PATH" || \
   ! grep -q "^staging01" "$INVENTORY_PATH" || \
   ! grep -q "^\[datacenter:children\]$" "$INVENTORY_PATH" || \
   ! grep -q "^web" "$INVENTORY_PATH" || \
   ! grep -q "^staging" "$INVENTORY_PATH"; then
    echo "The inventory file does not have the correct structure or content."
    exit 1
fi

# Optionally, you can add checks for specific IP addresses if you know the expected subnet.
# For example:
# if ! grep -q "^web03 ansible_host=192.168.1." "$INVENTORY_PATH"; then
#     echo "The IP address for web03 is not correctly set."
#     exit 1
# fi

echo "All checks passed. The inventory file is correctly set up!"
exit 0
