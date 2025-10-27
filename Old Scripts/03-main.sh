#!/bin/bash

# Load common functions and colors
# Admin Automation Script - Menu Driven
# Author: Revanth
# Description: One tool for package installation, user creation (single/multiple), and LVM disk expansion.

source ./utils.sh

while true; do
    clear
    echo -e "${B}${C}============================="
    echo "   Linux Admin Main Menu"
    echo -e "=============================${N}"
    echo -e "${G}1.${N} User Management"
    echo -e "${G}2.${N} Package Management"
    echo -e "${G}3.${N} Disk Management"
    echo -e "${G}4.${N} Exit"
    echo -e "${B}=============================${N}"
    read -p "Enter your choice: " choice

    case $choice in
        1) bash ./user_management.sh ;;
        2) bash ./package_management.sh ;;
        3) bash ./disk_management.sh ;;
        4) echo -e "${Y}Exiting...${N}"; exit 0 ;;
        *) echo -e "${R}Invalid choice!${N}"; sleep 1 ;;
    esac
done
