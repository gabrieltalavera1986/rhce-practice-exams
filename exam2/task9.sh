#!/bin/bash

# Define the expected content of the inventory graph
read -r -d '' expected_content <<'EOF'
@all:
  |--@ungrouped:
  |  |--host1.example.com
  |  |--host2.example.com
  |  |--host3.example.com
EOF

# Read the actual content from the file
actual_content=$(cat /tmp/inventory-graph.txt)

# Function to compare actual content with expected content
compare_content() {
    if [ "$1" == "$2" ]; then
        echo "All checks passed. The content of /tmp/inventory-graph.txt is correct."
    else
        echo "The content of /tmp/inventory-graph.txt does not match the expected content."
        echo "Expected content:"
        echo "$2"
        echo "Actual content:"
        echo "$1"
        exit 1
    fi
}

# Perform the comparison
compare_content "$actual_content" "$expected_content"

exit 0
