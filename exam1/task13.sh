#!/bin/bash

HOSTS="web01 web02 dev01"
SDB_FOUND=false

for HOST in $HOSTS; do
    echo "Checking $HOST..."

    # Check if system memory is less than 8GB
    TOTAL_MEMORY=$(ssh "$HOST" "awk '/MemTotal/ {print \$2/1024}' /proc/meminfo" | awk '{print int($1+0.5)}')
    if [[ $TOTAL_MEMORY -ge 8192 ]]; then
        echo "Memory on $HOST is greater than or equal to 8GB. Swap configuration not expected."
        continue
    fi

    # Check if sdb device exists
    if ssh "$HOST" "lsblk | grep -q sdb"; then
        SDB_FOUND=true

        # Check if a swap partition exists on sdb
        if ! ssh "$HOST" "lsblk -f | grep -q 'sdb1.*swap'"; then
            echo "Swap partition does not exist on sdb on $HOST."
            continue
        fi

        # Check if the swap partition is active
        if ! ssh "$HOST" "swapon --show=NAME | grep -q /dev/sdb1"; then
            echo "Swap partition on sdb is not active on $HOST."
            continue
        fi

        # Check if the swap partition is set to mount automatically upon reboot
        if ! ssh "$HOST" "grep -E 'sdb.*swap' /etc/fstab"; then
            echo "Swap partition on sdb is not set to mount automatically upon reboot on $HOST."
            continue
        fi

        echo "All checks for $HOST passed."
    else
        echo "sdb device does not exist on $HOST."
    fi
done

if ! $SDB_FOUND; then
    echo "sdb device was not found on any host."
    exit 1
fi

echo "All settings are correctly configured!"
exit 0
