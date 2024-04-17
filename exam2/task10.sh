#!/bin/bash

# Define the hosts
HOSTS=("web03" "web04" "staging01")

# SSH Options to disable strict host key checking if necessary
SSH_OPTIONS="-o StrictHostKeyChecking=no"

# Function to execute SSH command with sudo
ssh_exec() {
    ssh $SSH_OPTIONS "$1" "sudo $2"
}

# Define variables for checking
SSHD_CONFIG="/etc/ssh/sshd_config"
MOTD="/etc/motd"
SYSCTL_PARAM="kernel.randomize_va_space"

for HOST in "${HOSTS[@]}"; do
    echo "Checking configurations on $HOST..."

    # Check SSHD configuration
    echo "  Checking SSHD configuration..."
    ssh_exec $HOST "sudo grep -q '^PermitRootLogin no$' $SSHD_CONFIG && \
                    sudo grep -q '^PasswordAuthentication no$' $SSHD_CONFIG && \
                    sudo grep -q '^PermitEmptyPasswords no$' $SSHD_CONFIG && \
                    sudo grep -q '^UsePAM yes$' $SSHD_CONFIG" || {
        echo "  Error: SSHD settings do not reflect the desired configuration on $HOST."
        continue
    }

    # Check MOTD content
    echo "  Checking MOTD content..."
    ssh_exec $HOST "sudo grep -q 'Welcome to' $MOTD && \
                    sudo grep -q 'OS:' $MOTD && \
                    sudo grep -q 'Kernel Version:' $MOTD" || {
        echo "  Error: MOTD does not display the system information correctly on $HOST."
        continue
    }

    # Check SELinux enforcing
    echo "  Checking SELinux mode..."
    ssh_exec $HOST "sudo getenforce | grep -q 'Enforcing'" || {
        echo "  Error: SELinux is not in enforcing mode on $HOST."
        continue
    }

    # Check firewall is active and enabled
    echo "  Checking firewall status..."
    ssh_exec $HOST "sudo firewall-cmd --state && sudo systemctl is-enabled firewalld | grep -q 'enabled'" || {
        echo "  Error: Firewall is not active and enabled on $HOST."
        continue
    }

    # Check cockpit service is inactive
    echo "  Checking cockpit service status..."
    ssh_exec $HOST "sudo systemctl is-active cockpit | grep -q 'inactive'" || {
        echo "  Error: Cockpit service is not inactive on $HOST."
        continue
    }


    # Check sysctl parameter
    echo "  Checking sysctl parameter for kernel.randomize_va_space..."
    ssh_exec $HOST "sudo sysctl $SYSCTL_PARAM | grep -q 'kernel.randomize_va_space = 2'" || {
        echo "  Error: Sysctl parameter kernel.randomize_va_space is not set to 2 on $HOST."
        continue
    }

    echo "  All checks passed on $HOST."
done

echo "Validation complete."
exit 0
