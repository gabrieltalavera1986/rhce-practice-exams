#!/bin/bash

# Hosts to check
hosts=("web01" "web02" "dev01")

all_accomplished=true

# Check if groups exist
for host in "${hosts[@]}"; do
    echo "Checking groups on $host..."
    for group in "admins" "users"; do
        if ssh "$host" "getent group $group" >/dev/null 2>&1; then
            echo "Group $group exists on $host."
        else
            echo "Group $group does NOT exist on $host."
            all_accomplished=false
        fi
    done

    # Check if users exist and are members of the correct groups
    echo "Checking users on $host..."
    declare -A users_groups=( ["tony"]="admins" ["carmela"]="admins" ["paulie"]="users" ["chris"]="users" )
    for user in "${!users_groups[@]}"; do
        if ssh "$host" "id $user" >/dev/null 2>&1; then
            echo "User $user exists on $host."
            if ssh "$host" "id $user" | grep -q "${users_groups[$user]}"; then
                echo "User $user is a member of ${users_groups[$user]} group on $host."
            else
                echo "User $user is NOT a member of ${users_groups[$user]} group on $host."
                all_accomplished=false
            fi
        else
            echo "User $user does NOT exist on $host."
            all_accomplished=false
        fi
    done

    # Check if tony has sudo privileges without a password in sudoers file or sudoers.d directory
    echo "Checking sudo privileges for tony on $host..."
    if ssh "$host" "sudo grep -r '^tony.*NOPASSWD:.*ALL' /etc/sudoers /etc/sudoers.d" >/dev/null 2>&1; then
        echo "User tony has sudo privileges without a password on $host."
    else
        echo "User tony does NOT have sudo privileges without a password on $host."
        all_accomplished=false
    fi
done

# Print final result
if $all_accomplished; then
    echo "This task has been completed successfully!"
    exit 0
else
    echo "This task has NOT been completed successfully."
    exit 1
fi
