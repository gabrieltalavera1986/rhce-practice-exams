#!/bin/bash

# Define the expected API key
EXPECTED_API_KEY="f3eb0782983d3a417de12b96eb551a90"

# Check if the playbook and vault password file exist
if [[ ! -f playbook-secret.yml ]]; then
    echo "Error: playbook-secret.yml does not exist."
    exit 1
fi

if [[ ! -f vault-key.txt ]]; then
    echo "Error: vault-key.txt does not exist."
    exit 1
fi

# Run the playbook and capture the output
OUTPUT=$(ansible-playbook playbook-secret.yml --vault-password-file=vault-key.txt 2>&1)

# Check if there were any errors during playbook execution
if [[ $? -ne 0 ]]; then
    echo "Error executing the playbook:"
    echo "$OUTPUT"
    exit 1
fi

# Check if the expected API key is in the output
if echo "$OUTPUT" | grep -q "This is the api key: $EXPECTED_API_KEY"; then
    echo "The API key is correctly set in the vault."
    echo "This task has been completed successfully!"
    exit 0
else
    echo "The API key from the vault does not match the expected value."
    exit 1
fi
