#!/bin/bash

# File to check
file_name="inventory"

# Check if the file exists
if [[ ! -f $file_name ]]; then
    echo "File $file_name does not exist."
    exit 1
fi

# Define the groups and hosts to check
declare -A groups_hosts
groups_hosts=( 
    ["web"]="web01 web02"
    ["development"]="dev01"
    ["dc1:children"]="web development"
)

# Flag to track if all groups and hosts are found
all_found=true

# Check for each group and its hosts
for group in "${!groups_hosts[@]}"; do
    if grep -q "^\[$group\]" "$file_name"; then
        echo "Group $group found."
        
        IFS=' ' read -ra hosts <<< "${groups_hosts[$group]}"
        for host in "${hosts[@]}"; do
            if grep -q "^$host" "$file_name"; then
                echo "Host $host found under group $group."
            else
                echo "Host $host NOT found under group $group."
                all_found=false
            fi
        done
    else
        echo "Group $group NOT found."
        all_found=false
    fi
done

# Print final result
if $all_found; then
    echo "All specified groups and hosts are present in the inventory file."
    echo "This task has been completed successfully!"
    exit 0
else
    echo "Some groups or hosts are missing from the inventory file."
    exit 1
fi
