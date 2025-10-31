#!/bin/bash

while true; do
    clear
    echo "===== SYSTEM ADMIN MENU ====="
    echo "1. Check Uptime"
    echo "2. Disk Usage"
    echo "3. Memory Usage"
    echo "4. Logged-in Users"
    echo "5. Running Services"
    echo "6. Exit"
    echo "============================="
    read -p "Enter your choice [1-6]: " choice

    case $choice in
        1) uptime ;;
        2) df -h ;;
        3) free -m ;;
        4) who ;;
        5) systemctl list-units --type=service --state=running ;;
        6) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option!";;
    esac
    echo "Press Enter to continue..."
    read
done






#!/bin/bash

while true; do
    clear
    echo "==== SERVER MAINTENANCE MENU ===="
    echo "1. Clean /tmp"
    echo "2. Rotate logs older than 30 days"
    echo "3. Restart Nginx"
    echo "4. Restart MySQL"
    echo "5. Exit"
    echo "================================="
    read -p "Choose an option [1-5]: " opt

    case $opt in
        1) find /tmp -type f -mtime +7 -delete; echo "Temp cleaned." ;;
        2) find /var/log -type f -mtime +30 -delete; echo "Logs rotated." ;;
        3) systemctl restart nginx; systemctl status nginx | head -5 ;;
        4) systemctl restart mysql; systemctl status mysql | head -5 ;;
        5) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option!" ;;
    esac
    echo "Press Enter to continue..."
    read
done




#!/bin/bash

SERVER_LIST="servers.txt"

check_uptime() {
  for s in $(cat $SERVER_LIST); do
    echo "----- $s -----"
    ssh -o ConnectTimeout=5 $s uptime
  done
}

check_disk() {
  for s in $(cat $SERVER_LIST); do
    echo "----- $s -----"
    ssh $s df -h /
  done
}

restart_service() {
  read -p "Enter service name: " svc
  for s in $(cat $SERVER_LIST); do
    ssh $s "systemctl restart $svc"
  done
}

while true; do
    clear
    echo "====== MULTI-SERVER MENU ======"
    echo "1. Check Uptime"
    echo "2. Check Disk Usage"
    echo "3. Restart a Service"
    echo "4. Exit"
    echo "==============================="
    read -p "Choice [1-4]: " ch

    case $ch in
        1) check_uptime ;;
        2) check_disk ;;
        3) restart_service ;;
        4) exit 0 ;;
        *) echo "Invalid!" ;;
    esac
    echo "Press Enter to continue..."
    read
done





#!/bin/bash

add_user() {
    read -p "Enter username: " u
    useradd -m $u
    echo "$u:Welcome@123" | chpasswd
    passwd -e $u
    echo "User $u added."
}

delete_user() {
    read -p "Enter username to delete: " u
    userdel -r $u
    echo "User $u deleted."
}

list_users() {
    cut -d: -f1 /etc/passwd | tail -n +10
}

while true; do
    clear
    echo "===== USER MANAGEMENT MENU ====="
    echo "1. Add User"
    echo "2. Delete User"
    echo "3. List Users"
    echo "4. Exit"
    echo "================================="
    read -p "Select option [1-4]: " c

    case $c in
        1) add_user ;;
        2) delete_user ;;
        3) list_users ;;
        4) exit 0 ;;
        *) echo "Invalid!" ;;
    esac
    echo "Press Enter to continue..."
    read
done




#!/bin/bash

snapshot_system() {
    mkdir -p /incident_snapshots/$(date +%F_%H-%M)
    d=/incident_snapshots/$(date +%F_%H-%M)
    uptime > $d/uptime.log
    df -h > $d/disk.log
    top -bn1 > $d/top.log
    ss -tuna > $d/net.log
    echo "Snapshot taken in $d"
}

check_logs() {
    tail -n 20 /var/log/messages
}

restart_critical() {
    for svc in nginx mysql; do
        systemctl restart $svc
        echo "$svc restarted."
    done
}

while true; do
    clear
    echo "===== INCIDENT RESPONSE MENU ====="
    echo "1. Take System Snapshot"
    echo "2. View Latest Logs"
    echo "3. Restart Critical Services"
    echo "4. Exit"
    echo "=================================="
    read -p "Choice [1-4]: " c

    case $c in
        1) snapshot_system ;;
        2) check_logs ;;
        3) restart_critical ;;
        4) exit 0 ;;
        *) echo "Invalid choice!" ;;
    esac
    echo "Press Enter to continue..."
    read
done




