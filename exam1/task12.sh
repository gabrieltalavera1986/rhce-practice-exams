#!/bin/bash

SCRIPT_PATH="adhocfile.sh"
HOSTS="web01 web02 dev01"

# Check if adhocfile.sh exists and is executable
if [[ -x "$SCRIPT_PATH" ]]; then
    echo "$SCRIPT_PATH exists and is executable."
else
    echo "$SCRIPT_PATH does NOT exist or is NOT executable."
    exit 1
fi

# Check the content of adhocfile.sh
if grep -q 'ansible all -m file -a "path=/tmp/sample.txt state=touch owner=carmela mode=0644"' "$SCRIPT_PATH" && \
   grep -q "ansible all -m lineinfile -a \"path=/tmp/sample.txt line='Hello ansible world'\"" "$SCRIPT_PATH"; then
    echo "Ad hoc commands are correctly set in $SCRIPT_PATH."
else
    echo "Ad hoc commands are NOT correctly set in $SCRIPT_PATH."
    exit 1
fi

# SSH into the target hosts and verify the settings
for HOST in $HOSTS; do
    # Check if /tmp/sample.txt exists with the specified permissions and ownership
    FILE_EXISTS=$(ssh "$HOST" "[ -f /tmp/sample.txt ] && echo 'yes' || echo 'no'")
    FILE_OWNER=$(ssh "$HOST" "stat -c '%U' /tmp/sample.txt 2>/dev/null || echo ''")
    FILE_PERMISSIONS=$(ssh "$HOST" "stat -c '%a' /tmp/sample.txt 2>/dev/null || echo ''")

    if [[ "$FILE_EXISTS" == "yes" && "$FILE_OWNER" == "carmela" && "$FILE_PERMISSIONS" == "644" ]]; then
        echo "/tmp/sample.txt exists with correct permissions and ownership on $HOST."
    else
        echo "/tmp/sample.txt does NOT have the correct settings on $HOST."
        exit 1
    fi

    # Check if /tmp/sample.txt contains the line "Hello ansible world"
    if ssh "$HOST" "grep -q 'Hello ansible world' /tmp/sample.txt"; then
        echo "/tmp/sample.txt contains the correct line on $HOST."
    else
        echo "/tmp/sample.txt does NOT contain the correct line on $HOST."
        exit 1
    fi
done

echo "All checks passed. The task has been completed successfully!"
exit 0
