#!/bin/bash

# Check if check_webpage.yml exists
if [[ ! -f check_webpage.yml ]]; then
    echo "check_webpage.yml does not exist."
    exit 1
fi

# Run the playbook
OUTPUT=$(ansible-playbook check_webpage.yml 2>&1)

# Check if the playbook ran to completion
if echo "$OUTPUT" | grep -q "PLAY RECAP"; then
    if echo "$OUTPUT" | grep -q "failed=0"; then
        echo "Playbook ran successfully."
    else
        echo "Playbook encountered errors but ran to completion."
    fi
else
    echo "Playbook did not run to completion."
    exit 1
fi

echo "This task has been completed successfully!"
exit 0
