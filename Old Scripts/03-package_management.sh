#!/bin/bash
source ./utils.sh

while true; do
    clear
    echo -e "${B}${C}============================="
    echo "     Package Management"
    echo -e "=============================${N}"
    echo -e "${G}1.${N} Install Package"
    echo -e "${G}2.${N} Remove Package"
    echo -e "${G}3.${N} List Installed Packages"
    echo -e "${G}4.${N} Return to Main Menu"
    echo -e "${B}=============================${N}"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            read -p "Enter package to install: " pkg
            sudo yum install -y "$pkg"
            ;;
        2)
            read -p "Enter package to remove: " pkg
            sudo yum remove -y "$pkg"
            ;;
        3) rpm -qa | less ;;
        4) break ;;
        *) echo -e "${R}Invalid choice!${N}" ;;
    esac
    pause
done
