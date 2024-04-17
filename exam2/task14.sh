#!/bin/bash

# Define paths and passwords
VAULT_FILE="$HOME/rhce2/secrets.yml"
OLD_PASSWORD="rocky"
NEW_PASSWORD="rocky!123"

# Function to check vault access with a given password
check_vault_access() {
    local password=$1
    local operation=$2

    # Try to view the vault with the provided password
    if echo "$password" | ansible-vault view --vault-password-file=<(echo "$password") "$VAULT_FILE" &> /dev/null; then
        if [ "$operation" == "should_fail" ]; then
            echo "Error: Vault is still accessible with the old password."
            exit 1
        elif [ "$operation" == "should_succeed" ]; then
            echo "Success: Vault is accessible with the new password."
        fi
    else
        if [ "$operation" == "should_fail" ]; then
            echo "Success: Vault is not accessible with the old password, as expected."
        elif [ "$operation" == "should_succeed" ]; then
            echo "Error: Cannot access the vault with the new password."
            exit 1
        fi
    fi
}

echo "Checking vault access with the old password (should fail)..."
check_vault_access "$OLD_PASSWORD" "should_fail"

echo "Checking vault access with the new password (should succeed)..."
check_vault_access "$NEW_PASSWORD" "should_succeed"

echo "All checks passed. The rekeying process was successful."
exit 0
