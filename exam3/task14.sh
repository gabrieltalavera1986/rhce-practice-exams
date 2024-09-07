#!/bin/bash

# Initialize task status
task_status=0

# Function to update task status
update_status() {
    if [ $1 -ne 0 ]; then
        task_status=1
    fi
}

echo "Task 14 Verification: Configure LVM with XFS Filesystem"
echo "======================================================"

# Function to run commands on webserver03 and check output
check_remote() {
    local command="$1"
    local expected="$2"
    local message="$3"
    
    output=$(ssh webserver03 "$command")
    if echo "$output" | tr -d '\n' | grep -q "$expected"; then
        echo "[PASS] $message"
    else
        echo "[FAIL] $message"
        echo "Expected: $expected"
        echo "Got: $output"
        update_status 1
    fi
}

# Check if /dev/sdc and /dev/sdd are used as physical volumes
check_remote "sudo pvs" "/dev/sdc" "Physical volume /dev/sdc is part of LVM"
check_remote "sudo pvs" "/dev/sdd" "Physical volume /dev/sdd is part of LVM"

# Check if volume group vg_rhce3 exists and uses both PVs
check_remote "sudo vgs vg_rhce3" "vg_rhce3" "Volume group vg_rhce3 exists"
check_remote "sudo vgs vg_rhce3 -o pv_name --noheadings | tr -d ' '" "/dev/sdc/dev/sdd" "vg_rhce3 uses both /dev/sdc and /dev/sdd"

# Check if lv_rhce3 is formatted with XFS
check_remote "sudo blkid /dev/vg_rhce3/lv_rhce3" "TYPE=\"xfs\"" "lv_rhce3 is formatted with XFS"

# Check if /mnt/rhce3_data exists and is a mount point
check_remote "[ -d /mnt/rhce3_data ] && echo 'Directory exists'" "Directory exists" "/mnt/rhce3_data directory exists"
check_remote "mountpoint /mnt/rhce3_data" "is a mountpoint" "/mnt/rhce3_data is a mount point"

# Check if lv_rhce3 is mounted at /mnt/rhce3_data
check_remote "mount | grep '/dev/mapper/vg_rhce3-lv_rhce3 on /mnt/rhce3_data'" "/mnt/rhce3_data" "lv_rhce3 is mounted at /mnt/rhce3_data"

# Check if mount is in /etc/fstab for persistence (less strict check)
check_remote "grep 'rhce' /etc/fstab | grep '/mnt/rhce3_data'" "/mnt/rhce3_data" "Mount entry for rhce exists in /etc/fstab"

echo "======================================================"
echo "Verification complete."

# Print final task status
if [ $task_status -eq 0 ]; then
    echo "Task completed"
else
    echo "Task failed"
fi

exit $task_status
