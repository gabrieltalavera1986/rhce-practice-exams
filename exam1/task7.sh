#!/bin/bash

# Hosts to check
hosts=("web01" "web02" "dev01")

# Initialize a flag to track if all settings are correct
all_settings_correct=true

for host in "${hosts[@]}"; do
    echo "Checking settings on $host..."

    # Check if chronyd service is running and enabled
    if ssh "$host" "systemctl is-active chronyd" && ssh "$host" "systemctl is-enabled chronyd"; then
        echo "chronyd service is running and enabled on $host."
    else
        echo "chronyd service is NOT running or enabled on $host."
        all_settings_correct=false
    fi

    # Check if the NTP server is configured in chrony
    if ssh "$host" "grep '2.rhel.pool.ntp.org' /etc/chrony.conf"; then
        echo "NTP server 2.rhel.pool.ntp.org is configured on $host."
    else
        echo "NTP server 2.rhel.pool.ntp.org is NOT configured on $host."
        all_settings_correct=false
    fi

    # Check if the options pool and iburst are set for the NTP server
    if ssh "$host" "grep 'pool 2.rhel.pool.ntp.org iburst' /etc/chrony.conf"; then
        echo "pool and iburst options are set for the NTP server on $host."
    else
        echo "pool and iburst options are NOT set for the NTP server on $host."
        all_settings_correct=false
    fi
done

# Print final result
if $all_settings_correct; then
    echo "All settings are correctly configured on all hosts!"
    echo "This task has been completed successfully!"
    exit 0
else
    echo "Some settings are not correctly configured on one or more hosts."
    exit 1
fi
