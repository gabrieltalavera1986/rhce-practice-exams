#!/bin/bash

# Define SSH host
HOST="web03"

# SSH Options to disable strict host key checking if necessary
SSH_OPTIONS="-o StrictHostKeyChecking=no"

# Function to execute SSH command
ssh_exec() {
    ssh $SSH_OPTIONS "$HOST" "$1"
}

echo "Checking configurations on $HOST..."

# Check if the volume group exists
echo "  Checking volume group myrhcevg..."
if ! ssh_exec "sudo vgdisplay myrhcevg"; then
    echo "  Error: Volume group 'myrhcevg' does not exist."
    exit 1
fi

# Check if the logical volume exists
echo "  Checking logical volume myrhcelv01..."
if ! ssh_exec "sudo lvdisplay /dev/myrhcevg/myrhcelv01"; then
    echo "  Error: Logical volume 'myrhcelv01' does not exist."
    exit 1
fi

# Check filesystem type on the logical volume
echo "  Checking filesystem type on myrhcelv01..."
if ! ssh_exec "sudo blkid -o value -s TYPE /dev/myrhcevg/myrhcelv01 | grep -xq 'xfs'"; then
    echo "  Error: Filesystem on 'myrhcelv01' is not XFS."
    exit 1
fi

# Check mount point
echo "  Checking mount point /mnt/rhce2volume..."
if ! ssh_exec "mount | grep /mnt/rhce2volume | grep -q 'myrhcelv01'"; then
    echo "  Error: Logical volume 'myrhcelv01' is not mounted on /mnt/rhce2volume."
    exit 1
fi

# Check fstab for persistence
echo "  Checking fstab for persistent mounting..."
if ! ssh_exec "grep -q '/dev/myrhcevg/myrhcelv01' /etc/fstab"; then
    echo "  Error: Mount is not persistent. Entry not found in /etc/fstab."
    exit 1
fi

echo "All checks passed. LVM configuration is correct and persistent on $HOST."
exit 0
