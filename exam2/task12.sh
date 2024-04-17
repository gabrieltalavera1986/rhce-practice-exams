#!/bin/bash

# Define the directory where the role should be installed
ROLE_DIR="$HOME/rhce2/roles"

# Define the ansible.cfg path
ANSIBLE_CFG="$HOME/rhce2/ansible.cfg"

# Check if the HAProxy role is installed in the specified directory
echo "Checking if the geerlingguy.haproxy role is installed correctly..."
if [ -d "$ROLE_DIR/geerlingguy.haproxy" ]; then
    echo "Success: geerlingguy.haproxy role is installed in $ROLE_DIR."
else
    echo "Error: geerlingguy.haproxy role is not installed in $ROLE_DIR."
    exit 1
fi

# Check if the Ansible configuration file has the correct roles_path set
echo "Verifying if the roles_path is correctly set in ansible.cfg..."
if grep -q "roles_path.*roles" "$ANSIBLE_CFG"; then
    echo "Success: roles_path contains 'roles' in $ANSIBLE_CFG."
else
    echo "Error: roles_path does not contain 'roles' in $ANSIBLE_CFG."
    exit 1
fi

# Optionally, you can also verify by listing installed roles using ansible-galaxy
echo "Listing installed roles to confirm the HAProxy role is recognized by Ansible:"
ansible-galaxy role list | grep "geerlingguy.haproxy"
if [ $? -eq 0 ]; then
    echo "Success: geerlingguy.haproxy role is recognized by Ansible."
else
    echo "Error: geerlingguy.haproxy role is not recognized by Ansible."
    exit 1
fi

echo "All checks passed. The installation and configuration are correct."
exit 0
