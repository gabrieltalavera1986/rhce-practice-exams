#!/bin/bash

# Initialize a flag to track if all settings are correct
all_settings_correct=true

# Check if software_vars.yml exists and contains the correct software packages
if [[ -f software_vars.yml && $(awk '/software_packages:/ {flag=1; next} flag && /- vim/ {flag=2; next} flag==2 && /- nmap/ {print}' software_vars.yml) ]]; then
    echo "software_vars.yml is correctly set."
else
    echo "software_vars.yml is NOT correctly set."
    all_settings_correct=false
fi

# Check if dnf modules in software_install.yml are using variables
if [[ -f software_install.yml && 
      $(awk '/dnf:/ {flag=1; next} flag && /name: "{{ software_packages }}"/ {print}' software_install.yml) && 
      $(awk '/dnf:/ {flag=1; next} flag && /name: "{{ software_group }}"/ {print}' software_install.yml) ]]; then
    echo "dnf modules in software_install.yml are using variables."
else
    echo "dnf modules in software_install.yml are NOT correctly using variables."
    all_settings_correct=false
fi

# Check if the software packages are installed on web01 and web02
for host in web01 web02; do
    # Check for vim-enhanced instead of vim
    for package in vim-enhanced nmap; do
        if ssh "$host" "rpm -q $package" > /dev/null; then
            echo "$package is installed on $host."
        else
            echo "$package is NOT installed on $host."
            all_settings_correct=false
        fi
    done
done

# Check if the software group @Virtualization Host is installed on dev01
if ssh dev01 "dnf group list installed | grep 'Virtualization Host'" > /dev/null; then
    echo "@Virtualization Host software group is installed on dev01."
else
    echo "@Virtualization Host software group is NOT installed on dev01."
    all_settings_correct=false
fi

# Print final result
if $all_settings_correct; then
    echo "All settings are correctly configured!"
    echo "This task has been completed successfully!"
    exit 0
else
    echo "Some settings are not correctly configured."
    exit 1
fi
