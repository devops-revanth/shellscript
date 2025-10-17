#!/bin/bash
source ./utils.sh

while true; do
    clear
    echo -e "${C}=============================${N}"
    echo -e "${C}       Disk Management${N}"
    echo -e "${C}=============================${N}"
    echo -e "${G}1.${N} Show Disk Usage"
    echo -e "${G}2.${N} Show Mounted Filesystems"
    echo -e "${G}3.${N} Expand LVM Volume"
    echo -e "${G}4.${N} Return to Main Menu"
    echo -e "${C}=============================${N}"
    read -p "Enter your choice: " choice

    case $choice in
        1) df -h; pause ;;
        2) mount | less ;;
        3)
            read -p "Enter Logical Volume path (e.g., /dev/vg0/lv0): " LOGICAL_VOLUME
            read -p "Enter size to expand (e.g., 10G): " SIZE_TO_EXPAND

            # Check LV exists
            if ! lvdisplay "$LOGICAL_VOLUME" &>/dev/null; then
                echo -e "${R}Logical volume $LOGICAL_VOLUME does not exist.${N}"
                pause
                continue
            fi

            VOLUME_GROUP=$(lvdisplay "$LOGICAL_VOLUME" | grep 'VG Name' | awk '{print $3}')

            # Check VG free space
            FREE_SPACE=$(vgdisplay "$VOLUME_GROUP" | grep 'Free  PE / Size' | awk '{print $5}' | sed 's/G//')
            if (( $(echo "$FREE_SPACE < ${SIZE_TO_EXPAND%G}" | bc -l) )); then
                echo -e "${R}Not enough free space in VG $VOLUME_GROUP (Free: ${FREE_SPACE}G).${N}"
                pause
                continue
            fi

            # Expand LV
            lvextend -L +$SIZE_TO_EXPAND "$LOGICAL_VOLUME"
            if [ $? -ne 0 ]; then
                echo -e "${R}Failed to expand LV $LOGICAL_VOLUME.${N}"
                echo -e "${Y}No Space available in $VOLUME_GROUP Kindly check the space in your $VOLUME_GROUP ${N}"
                pause
                continue
            fi

            # Expand filesystem
            FILESYSTEM_TYPE=$(df -Th | grep "$LOGICAL_VOLUME" | awk '{print $2}')
            case $FILESYSTEM_TYPE in
                ext4)
                    resize2fs "$LOGICAL_VOLUME"
                    ;;
                xfs)
                    MOUNT_POINT=$(df "$LOGICAL_VOLUME" | tail -1 | awk '{print $6}')
                    xfs_growfs "$MOUNT_POINT"
                    ;;
                *)
                    echo -e "${R}Unsupported filesystem type: $FILESYSTEM_TYPE${N}"
                    pause
                    continue
                    ;;
            esac

            echo -e "${G}Logical volume $LOGICAL_VOLUME expanded successfully!${N}"
            pause
            ;;
        4) break ;;
        *) echo -e "${R}Invalid choice!${N}"; pause ;;
    esac
done
