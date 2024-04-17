#!/bin/bash

# Define the hosts
HOSTS=("web03" "web04" "staging01")  # Replace with your actual hostnames or IP addresses

# SSH Options to disable strict host key checking if necessary
SSH_OPTIONS="-o StrictHostKeyChecking=no"

# Function to execute SSH command
ssh_exec() {
    ssh $SSH_OPTIONS "$1" "$2"
}

for HOST in "${HOSTS[@]}"; do
    echo "Checking default boot target on $HOST..."

    # Execute the command to check the default target
    RESULT=$(ssh_exec $HOST "systemctl get-default")

    # Check if the result is what we expect
    if [[ "$RESULT" == "multi-user.target" ]]; then
        echo "  Success: The default boot target on $HOST is correctly set to multi-user.target."
    else
        echo "  Error: The default boot target on $HOST is not set to multi-user.target. Current target: $RESULT"
    fi
done

echo "Validation complete."
exit 0
