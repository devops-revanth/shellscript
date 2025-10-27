#!/bin/bash

#Description: This script expands a logical volume and its filesystem on a Linux system 
#User will input the Logic volume name and the size to expand as command line arguments
#Need to verify the volume group has enough free space before expanding and expand the filesystem after verifying the logical volume expansion
#Usage: ./lvm_expansion.sh <logical_volume_name> <size_to_expand>
#Example: ./lvm_expansion.sh /dev/vg0/lv0 10G

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <logical_volume_name> <size_to_expand>"
    echo "Provide only filesystem name which is available in df -h output"
    echo "Example: $0 /dev/vg0/lv0 10G or /dev/mapper/vg0-lv0 10G"
    exit 1
fi

LOGICAL_VOLUME=$1
SIZE_TO_EXPAND=$2
VOLUME_GROUP=$(lvdisplay $LOGICAL_VOLUME | grep 'VG Name' | awk '{print $3}')


# Check if the logical volume exists
if ! lvdisplay $LOGICAL_VOLUME &> /dev/null; then
    echo "Logical volume $LOGICAL_VOLUME does not exist."
    exit 1
fi

# Check if the volume group has enough free space
FREE_SPACE=$(vgdisplay $VOLUME_GROUP | grep 'Free  PE / Size' | awk '{print $5}' | sed 's/G//')
if (( $(echo "$FREE_SPACE < ${SIZE_TO_EXPAND%G}" | bc -l) )); then
    echo "Not enough free space in volume group $VOLUME_GROUP."
    exit 1
fi

# Expand the logical volume
lvextend -L +$SIZE_TO_EXPAND $LOGICAL_VOLUME
if [ $? -ne 0 ]; then
    echo "Failed to expand logical volume $LOGICAL_VOLUME."
    exit 1
fi

# Verify the logical volume expansion
NEW_SIZE=$(lvdisplay $LOGICAL_VOLUME | grep 'LV Size' | awk '{print $3}')
echo "Logical volume $LOGICAL_VOLUME expanded successfully to $NEW_SIZE."
# Expand the filesystem
if df -Th | grep -q "$LOGICAL_VOLUME"; then
    FILESYSTEM_TYPE=$(df -Th | grep "$LOGICAL_VOLUME" | awk '{print $2}')
    case $FILESYSTEM_TYPE in
        ext4)
            resize2fs $LOGICAL_VOLUME
            ;;
        xfs)
            xfs_growfs $(df $LOGICAL_VOLUME | tail -1 | awk '{print $1}')
            ;;
        *)
            echo "Unsupported filesystem type: $FILESYSTEM_TYPE"
            exit 1
            ;;
    esac
    if [ $? -ne 0 ]; then
        echo "Failed to expand filesystem on $LOGICAL_VOLUME."
        exit 1
    fi
    echo "Filesystem on $LOGICAL_VOLUME expanded successfully."
else
    echo "$LOGICAL_VOLUME is not mounted. Please mount it to use the expanded space."
fi

exit 0