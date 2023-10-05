#!/bin/bash

# Host to check
host="dev01"

# Initialize a flag to track if all settings are correct
all_settings_correct=true

# Check if the cron job is set up to run every 2 minutes
cron_job_pattern=$(ssh "$host" "sudo crontab -l | grep '*/2 \* \* \* \*'")

if [[ ! -z "$cron_job_pattern" && "$cron_job_pattern" == "*/2 * * * *"* ]]; then
    echo "Cron job is set to run every 2 minutes on $host."
else
    echo "Cron job is NOT set to run every 2 minutes on $host."
    all_settings_correct=false
fi




# Check if the cron job appends the current date and time to /tmp/logme.txt
last_entry=$(ssh "$host" "tail -n 1 /tmp/logme.txt")
if [[ "$last_entry" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
    echo "Cron job correctly appends the date to /tmp/logme.txt on $host."
else
    echo "Cron job does NOT correctly append the date to /tmp/logme.txt on $host."
    all_settings_correct=false
fi

# Print final result
if $all_settings_correct; then
    echo "All settings for the cron job are correctly configured on $host!"
    echo "This task has been completed successfully!"
    exit 0
else
    echo "Some settings for the cron job are not correctly configured on $host."
    exit 1
fi
