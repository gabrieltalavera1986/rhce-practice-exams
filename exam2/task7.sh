#!/bin/bash

# Define users, groups, and UIDs
USERS=("alice" "bob" "carol")
GROUPS=("developers" "admins")
UIDS=("1001" "1002" "1003")

# Check if the playbook exists
if [[ ! -f ~/rhce2/myusers.yml ]]; then
    echo "myusers.yml playbook does not exist."
    exit 1
fi

# Check if the vault file exists
if [[ ! -f ~/rhce2/user_passwords.yml ]]; then
    echo "user_passwords.yml vault file does not exist."
    exit 1
fi

# Decrypt the vault temporarily to check its content
ansible-vault view ~/rhce2/user_passwords.yml --vault-password-file=<(echo "rocky!123") > /tmp/decrypted_vault.txt

# Check if the passwords are correctly set in the vault
if ! grep -q "alice_password: alicepass" /tmp/decrypted_vault.txt || \
   ! grep -q "bob_password: bobpass" /tmp/decrypted_vault.txt || \
   ! grep -q "carol_password: carolpass" /tmp/decrypted_vault.txt; then
    echo "Passwords in the vault are not set correctly."
    rm /tmp/decrypted_vault.txt
    exit 1
fi

rm /tmp/decrypted_vault.txt

# SSH into each host in the datacenter group and verify the settings
for host in $(ansible datacenter --list-hosts | tail -n +2); do
    echo "Checking $host..."

    # Check groups
    for group in "${GROUPS[@]}"; do
        if ! ssh "$host" "getent group $group"; then
            echo "Group $group does not exist on $host."
            exit 1
        fi
    done

    # Check users, UIDs, and group memberships
    for i in "${!USERS[@]}"; do
        if ! ssh "$host" "id -u ${USERS[$i]}" | grep -q "${UIDS[$i]}"; then
            echo "User ${USERS[$i]} does not have UID ${UIDS[$i]} on $host."
            exit 1
        fi

        if [[ "${USERS[$i]}" == "alice" || "${USERS[$i]}" == "bob" ]]; then
            if ! ssh "$host" "groups ${USERS[$i]}" | grep -q "developers"; then
                echo "User ${USERS[$i]} is not a member of the developers group on $host."
                exit 1
            fi
        fi

        if [[ "${USERS[$i]}" == "carol" ]]; then
            if ! ssh "$host" "groups ${USERS[$i]}" | grep -q "admins"; then
                echo "User ${USERS[$i]} is not a member of the admins group on $host."
                exit 1
            fi
        fi
    done
done

echo "All checks passed. The task has been completed successfully!"
exit 0
