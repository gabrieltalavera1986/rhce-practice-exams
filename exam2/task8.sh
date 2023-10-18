#!/bin/bash

PLAYBOOK_PATH="./security_poc.yml"
HOST_GROUP="staging"
TARGET_HOST="staging01"  # Assuming staging01 is the only host in the 'staging' group for simplicity

# Check if the playbook exists
if [[ ! -f $PLAYBOOK_PATH ]]; then
    echo "security_poc.yml playbook does not exist."
    exit 1
fi

# Check if the playbook targets the staging host group
if ! grep -q "hosts: $HOST_GROUP" $PLAYBOOK_PATH; then
    echo "The playbook does not target the $HOST_GROUP host group."
    exit 1
fi

# Check if the playbook registers the result in the correct variable
if ! grep -q "register: file_creation_result" $PLAYBOOK_PATH; then
    echo "The playbook does not register the result in the file_creation_result variable."
    exit 1
fi

# Check if the playbook displays the correct error message
if ! grep -q "\"Unable to create the file in alice's home directory.\"" $PLAYBOOK_PATH; then
    echo "The playbook does not display the correct error message."
    exit 1
fi

# Check if the playbook handles errors using either ignore_errors, block/rescue, or block/rescue/register
if ! grep -q "ignore_errors: yes" $PLAYBOOK_PATH && \
   ! grep -q "block:" $PLAYBOOK_PATH && \
   ! grep -q "rescue:" $PLAYBOOK_PATH; then
    echo "The playbook does not handle errors using either ignore_errors, block/rescue, or block/rescue/register."
    exit 1
fi

# SSH into the target host and check if the file was created
if ssh "$TARGET_HOST" "[[ -f /home/alice/testfile.txt ]]"; then
    echo "testfile.txt was created in alice's home directory on $TARGET_HOST. This is unexpected."
    exit 1
else
    echo "testfile.txt was NOT created in alice's home directory on $TARGET_HOST, as expected."
fi

echo "All checks passed. The task has been completed successfully!"
exit 0
