#!/bin/bash

# Define hosts
HOSTS=("web03" "web04")

# SSH Options
SSH_OPTIONS="-o StrictHostKeyChecking=no"

# Function to execute SSH command
ssh_exec() {
    ssh $SSH_OPTIONS "$1" "$2"
}

# Function to check HTTP response
check_http_response() {
    local host=$1
    echo "Checking HTTP response from $host..."
    local response=$(curl -s $host)
    echo "$response"
    echo "$response" | grep -q "Hostname: $host" && echo "Hostname check passed."
    echo "$response" | grep -q "IP Address:" && echo "IP Address check passed."
    echo "$response" | grep -q "httpd Installation Date:" && echo "Installation date check passed."
}

for HOST in "${HOSTS[@]}"; do
    echo "Checking configurations on $HOST..."

    # Check if httpd is installed and running
    echo "  Checking if httpd is installed and running..."
    if ! ssh_exec "$HOST" "sudo systemctl is-active httpd" | grep -q "active"; then
        echo "  Error: httpd is not active on $HOST."
    else
        echo "  Success: httpd is active on $HOST."
    fi

    # Check if the custom fact file exists and has correct date format
    echo "  Checking custom fact for httpd installation date..."
    if ssh_exec "$HOST" "test -f /etc/ansible/facts.d/httpd_install_date.fact && grep -qE 'install_date=\"[0-9]{4}-[0-9]{2}-[0-9]{2}\"' /etc/ansible/facts.d/httpd_install_date.fact"; then
        echo "  Success: Custom fact file exists with correct date format on $HOST."
    else
        echo "  Error: Custom fact file is missing or has incorrect date format on $HOST."
    fi

    # Use curl to check the web server's response
    check_http_response "$HOST"
done

echo "Validation complete."
