#!/bin/bash
# =============================================
#   Linux Admin Menu - Command Center
#   Author: Revanth (Example)
# =============================================

SERVER_LIST="servers.txt"
LOG_FILE="/var/log/admin_menu.log"

# --------------------------
# 🧠 System Health Functions
# --------------------------
check_uptime() {
    echo "=== Uptime ==="
    uptime
}

check_disk() {
    echo "=== Disk Usage ==="
    df -h
}

check_memory() {
    echo "=== Memory Usage ==="
    free -m
}

check_load() {
    echo "=== Load Average ==="
    uptime | awk -F'load average:' '{print $2}'
}

# --------------------------
# 👤 User Management
# --------------------------
add_user() {
    read -p "Enter username to add: " u
    if id "$u" &>/dev/null; then
        echo "User $u already exists!"
    else
        useradd -m "$u"
        echo "$u:Welcome@123" | chpasswd
        passwd -e "$u"
        echo "$(date): User $u added" >> $LOG_FILE
        echo "✅ User $u added."
    fi
}

delete_user() {
    read -p "Enter username to delete: " u
    if id "$u" &>/dev/null; then
        userdel -r "$u"
        echo "$(date): User $u deleted" >> $LOG_FILE
        echo "❌ User $u deleted."
    else
        echo "User $u does not exist."
    fi
}

list_users() {
    echo "=== Local Users ==="
    cut -d: -f1 /etc/passwd | tail -n +10
}

# --------------------------
# 🧼 Maintenance
# --------------------------
cleanup_tmp() {
    find /tmp -type f -mtime +7 -delete
    echo "$(date): Cleaned /tmp" >> $LOG_FILE
    echo "🧹 /tmp cleaned."
}

rotate_logs() {
    find /var/log -type f -mtime +30 -delete
    echo "$(date): Rotated old logs" >> $LOG_FILE
    echo "🧾 Old logs deleted."
}

restart_service() {
    read -p "Enter service name to restart: " svc
    systemctl restart "$svc"
    if [ $? -eq 0 ]; then
        echo "✅ $svc restarted."
        echo "$(date): Restarted $svc" >> $LOG_FILE
    else
        echo "❌ Failed to restart $svc."
    fi
}

# --------------------------
# 🚨 Incident Response
# --------------------------
snapshot_system() {
    SNAP_DIR="/incident_snapshots/$(date +%F_%H-%M)"
    mkdir -p "$SNAP_DIR"
    uptime > "$SNAP_DIR/uptime.log"
    df -h > "$SNAP_DIR/disk.log"
    top -bn1 > "$SNAP_DIR/top.log"
    ss -tuna > "$SNAP_DIR/net.log"
    echo "$(date): Snapshot captured at $SNAP_DIR" >> $LOG_FILE
    echo "📸 Snapshot saved in $SNAP_DIR"
}

tail_logs() {
    tail -n 25 /var/log/messages
}

multi_server_restart() {
    read -p "Enter service name: " svc
    for h in $(cat $SERVER_LIST); do
        echo "Restarting $svc on $h..."
        ssh -o ConnectTimeout=5 $h "systemctl restart $svc" &
    done
    wait
    echo "🚀 Restarted $svc across fleet."
}

# --------------------------
# 🌐 Fleet Health Check
# --------------------------
fleet_health() {
    for h in $(cat $SERVER_LIST); do
        echo "---- $h ----"
        ssh -o ConnectTimeout=5 $h "uptime; df -h / | tail -n 1; free -m | grep Mem"
    done
}

# --------------------------
# 🧭 Menu
# --------------------------
while true; do
    clear
    echo "============================================="
    echo "        🧭 LINUX ADMIN COMMAND CENTER         "
    echo "============================================="
    echo "1. 🧠 System Health Check"
    echo "2. 👤 User Management"
    echo "3. 🧼 Maintenance Tasks"
    echo "4. 🚨 Incident Response"
    echo "5. 🌐 Fleet Operations"
    echo "6. Exit"
    echo "---------------------------------------------"
    read -p "Select option [1-6]: " main

    case $main in
        1)
            clear
            echo "=== SYSTEM HEALTH ==="
            echo "1. Check Uptime"
            echo "2. Check Disk Usage"
            echo "3. Check Memory Usage"
            echo "4. Check Load Average"
            echo "5. Back"
            read -p "Choice: " h
            case $h in
                1) check_uptime ;;
                2) check_disk ;;
                3) check_memory ;;
                4) check_load ;;
                5) continue ;;
                *) echo "Invalid";;
            esac
            read -p "Press Enter..."
        ;;
        2)
            clear
            echo "=== USER MANAGEMENT ==="
            echo "1. Add User"
            echo "2. Delete User"
            echo "3. List Users"
            echo "4. Back"
            read -p "Choice: " u
            case $u in
                1) add_user ;;
                2) delete_user ;;
                3) list_users ;;
                4) continue ;;
                *) echo "Invalid";;
            esac
            read -p "Press Enter..."
        ;;
        3)
            clear
            echo "=== MAINTENANCE ==="
            echo "1. Clean /tmp"
            echo "2. Rotate Old Logs"
            echo "3. Restart Service"
            echo "4. Back"
            read -p "Choice: " m
            case $m in
                1) cleanup_tmp ;;
                2) rotate_logs ;;
                3) restart_service ;;
                4) continue ;;
                *) echo "Invalid";;
            esac
            read -p "Press Enter..."
        ;;
        4)
            clear
            echo "=== INCIDENT RESPONSE ==="
            echo "1. Take System Snapshot"
            echo "2. Tail Logs"
            echo "3. Restart Service on Fleet"
            echo "4. Back"
            read -p "Choice: " ir
            case $ir in
                1) snapshot_system ;;
                2) tail_logs ;;
                3) multi_server_restart ;;
                4) continue ;;
                *) echo "Invalid";;
            esac
            read -p "Press Enter..."
        ;;
        5)
            clear
            echo "=== FLEET OPERATIONS ==="
            echo "1. Fleet Health Check"
            echo "2. Back"
            read -p "Choice: " f
            case $f in
                1) fleet_health ;;
                2) continue ;;
                *) echo "Invalid";;
            esac
            read -p "Press Enter..."
        ;;
        6)
            echo "👋 Exiting Admin Menu. Bye!"
            exit 0
        ;;
        *)
            echo "❌ Invalid option!"
            read -p "Press Enter..."
        ;;
    esac
done
