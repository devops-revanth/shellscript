#!/bin/bash
source ./utils.sh

while true; do
    clear
    echo -e "${B}${C}============================="
    echo "       User Management"
    echo -e "=============================${N}"
    echo -e "${G}1.${N} Add User"
    echo -e "${G}2.${N} Delete User"
    echo -e "${G}3.${N} List Users"
    echo -e "${G}4.${N} Return to Main Menu"
    echo -e "${G}5.${N} Exit"
    echo -e "${B}=============================${N}"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            while true; do
                echo -e "${C}=== Add User ===${N}"
                echo -e "${G}1.${N} Single User"
                echo -e "${G}2.${N} Multiple Users"
                echo -e "${G}3.${N} Return to User Menu"
                read -p "Choose an option [1-3]: " user_choice

                case $user_choice in
                    1)
                        read -p "Enter username to add: " user
                        sudo useradd "$user" && echo -e "${G}User $user created!${N}" || echo -e "${R}Failed!${N}"
                        ;;
                    2)
                        read -p "Enter path to file containing usernames: " file
                        if [[ -f "$file" ]]; then
                            while IFS= read -r user; do
                                [[ -z "$user" ]] && continue  # skip empty lines
                                sudo useradd "$user" && echo -e "${G}User $user created!${N}" || echo -e "${R}Failed to create $user${N}"
                            done < "$file"
                        else
                            echo -e "${R}File not found!${N}"
                        fi
                        ;;
                    3) break ;;
                    *) echo -e "${R}Invalid choice!${N}" ;;
                esac
                pause
            done
            ;;
        2)
            read -p "Enter username to delete: " user
            sudo userdel -r "$user" && echo -e "${G}User $user deleted!${N}" || echo -e "${R}Failed!${N}"
            ;;
        3)
            cut -d: -f1 /etc/passwd | less
            ;;
        4) break ;;
        5) echo -e "${Y}Exiting...${N}"; exit 0 ;;
        *) echo -e "${R}Invalid choice!${N}" ;;
    esac
    pause
done
