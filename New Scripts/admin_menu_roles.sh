#!/bin/bash
# =====================================================
# 🧭 Pro Admin Menu - Role Based Access Version
# Author: Revanth (Example)
# =====================================================

# ---------- CONFIG ----------
SERVER_LIST="servers.txt"
LOG_FILE="/var/log/admin_menu.log"
SLACK_HOOK="https://hooks.slack.com/services/XXX/YYY/ZZZ"   # Optional

# ---------- COLORS ----------
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

# ---------- ROOT CHECK ----------
if [ "$EUID" -ne 0 ]; then
    echo "${RED}❌ Please run as root or with sudo.${RESET}"
    exit 1
fi

# ---------- LOG & ALERT ----------
log_action() {
    local msg="$1"
    echo "$(date '+%F %T') - $USER - $msg" >> $LOG_FILE
}

send_slack() {
    local text="$1"
    curl -s -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"$text\"}" $SLACK_HOOK >/dev/null 2>&1
}

# ---------- ROLE ASSIGNMENT ----------
read -p "Enter your role [junior/senior]: " ROLE
ROLE=$(echo $ROLE | tr '[:upper:]' '[:lower:]')

if [[ "$ROLE" != "junior" && "$ROLE" != "senior" ]]; then
    echo "${RED}❌ Invalid role. Please enter 'junior' or 'senior'.${RESET}"
    exit 1
fi

# ---------- FUNCTIONS: HEALTH ----------
check_uptime() { echo "${BLUE}=== Uptime ===${RESET}"; uptime; log_action "Checked uptime"; }
check_disk()   { echo "${BLUE}=== Disk Usage ===${RESET}"; df -h; log_action "Checked disk"; }
check_memory() { echo "${BLUE}=== Memory Usage ===${RESET}"; free -m; log_action "Checked memory"; }
check_load()   { echo "${BLUE}=== Load Average ===${RESET}"; uptime | awk -F'load average:' '{print $2}'; log_action "Checked load"; }

# ---------- FUNCTIONS: USER MGMT ----------
add_user() {
    read -p "Username to add: " u
    if id "$u" &>/dev/null; then
        echo "${YELLOW}⚠️ $u already exists.${RESET}"
    else
        useradd -m "$u"
        echo "$u:Welcome@123" | chpasswd
        passwd -e "$u"
        log_action "Added user $u"
        send_slack ":bust_in_silhouette: User *$u* added by $USER"
        echo "${GREEN}✅ User $u added.${RESET}"
    fi
}

delete_user() {
    read -p "Username to delete: " u
    if id "$u" &>/dev/null; then
        userdel -r "$u"
        log_action "Deleted user $u"
        send_slack ":no_entry_sign: User *$u* deleted by $USER"
        echo "${GREEN}❌ User $u deleted.${RESET}"
    else
        echo "${YELLOW}⚠️ User $u does not exist.${RESET}"
    fi
}

list_users() {
    echo "${BLUE}=== Local Users ===${RESET}"
    cut -d: -f1 /etc/passwd | tail -n +10
}

# ---------- FUNCTIONS: MAINTENANCE ----------
cleanup_tmp() {
    find /tmp -type f -mtime +7 -delete
    log_action "Cleaned /tmp"
    send_slack ":broom: /tmp cleaned by $USER"
    echo "${GREEN}🧹 /tmp cleaned.${RESET}"
}

rotate_logs() {
    find /var/log -type f -mtime +30 -delete
    log_action "Rotated old logs"
    send_slack ":page_facing_up: Logs rotated by $USER"
    echo "${GREEN}🧾 Old logs deleted.${RESET}"
}

restart_service() {
    read -p "Enter service name: " svc
    systemctl restart "$svc"
    if [ $? -eq 0 ]; then
        log_action "Restarted $svc"
        send_slack ":gear: $svc restarted by $USER"
        echo "${GREEN}✅ $svc restarted.${RESET}"
    else
        echo "${RED}❌ Failed to restart $svc.${RESET}"
    fi
}

# ---------- FUNCTIONS: INCIDENT ----------
snapshot_system() {
    SNAP_DIR="/incident_snapshots/$(date +%F_%H-%M)"
    mkdir -p "$SNAP_DIR"
    uptime > "$SNAP_DIR/uptime.log"
    df -h > "$SNAP_DIR/disk.log"
    top -bn1 > "$SNAP_DIR/top.log"
    ss -tuna > "$SNAP_DIR/net.log"
    log_action "Snapshot taken at $SNAP_DIR"
    send_slack ":camera_flash: Snapshot captured by $USER"
    echo "${GREEN}📸 Snapshot saved in $SNAP_DIR${RESET}"
}

tail_logs() {
    echo "${BLUE}=== Latest Logs ===${RESET}"
    tail -n 25 /var/log/messages
    log_action "Viewed tail logs"
}

multi_server_restart() {
    read -p "Enter service name: " svc
    for h in $(cat $SERVER_LIST); do
        ssh -o ConnectTimeout=5 $h "systemctl restart $svc" &
    done
    wait
    log_action "Restarted $svc across fleet"
    send_slack ":rocket: $svc restarted across fleet by $USER"
    echo "${GREEN}🚀 $svc restarted across fleet.${RESET}"
}

# ---------- FUNCTIONS: FLEET ----------
fleet_health() {
    echo "${BLUE}=== Fleet Health ===${RESET}"
    for h in $(cat $SERVER_LIST); do
        echo "---- $h ----"
        ssh -o ConnectTimeout=5 $h "uptime; df -h / | tail -n 1; free -m | grep Mem"
    done
    log_action "Ran fleet health check"
}

# ---------- MENU ----------
main_menu() {
    clear
    echo "${YELLOW}=============================================${RESET}"
    echo "        🧭 ${GREEN}LINUX ADMIN COMMAND CENTER - ROLE ${RESET}"
    echo "${YELLOW}=============================================${RESET}"
    echo "1. 🧠 System Health"
    echo "2. 👤 User Management"
    echo "3. 🧼 Maintenance Tasks"
    if [[ "$ROLE" == "senior" ]]; then
        echo "4. 🚨 Incident Response"
        echo "5. 🌐 Fleet Operations"
        echo "6. ❌ Exit"
    else
        echo "4. ❌ Exit"
    fi
    echo "---------------------------------------------"
    read -p "Select option: " main
}

while true; do
    main_menu
    case $main in
        1)
            clear
            echo "${BLUE}=== SYSTEM HEALTH ===${RESET}"
            echo "1. Uptime"
            echo "2. Disk Usage"
            echo "3. Memory Usage"
            echo "4. Load Average"
            echo "5. Back"
            read -p "Choice: " h
            case $h in
                1) check_uptime ;;
                2) check_disk ;;
                3) check_memory ;;
                4) check_load ;;
            esac
            read -p "Press Enter..."
        ;;
        2)
            clear
            echo "${BLUE}=== USER MANAGEMENT ===${RESET}"
            echo "1. Add User"
            echo "2. Delete User"
            echo "3. List Users"
            echo "4. Back"
            read -p "Choice: " u
            case $u in
                1) [[ "$ROLE" == "senior" ]] && add_user || echo "${RED}Access denied.${RESET}" ;;
                2) [[ "$ROLE" == "senior" ]] && delete_user || echo "${RED}Access denied.${RESET}" ;;
                3) list_users ;;
            esac
            read -p "Press Enter..."
        ;;
        3)
            clear
            echo "${BLUE}=== MAINTENANCE ===${RESET}"
            echo "1. Clean /tmp"
            echo "2. Rotate Logs"
            echo "3. Restart Service"
            echo "4. Back"
            read -p "Choice: " m
            case $m in
                1) cleanup_tmp ;;
                2) [[ "$ROLE" == "senior" ]] && rotate_logs || echo "${RED}Access denied.${RESET}" ;;
                3) [[ "$ROLE" == "senior" ]] && restart_service || echo "${RED}Access denied.${RESET}" ;;
            esac
            read -p "Press Enter..."
        ;;
        4)
            if [[ "$ROLE" == "senior" ]]; then
                clear
                echo "${BLUE}=== INCIDENT RESPONSE ===${RESET}"
                echo "1. Take Snapshot"
                echo "2. Tail Logs"
                echo "3. Restart Service on Fleet"
                echo "4. Back"
                read -p "Choice: " ir
                case $ir in
                    1) snapshot_system ;;
                    2) tail_logs ;;
                    3) multi_server_restart ;;
                esac
                read -p "Press Enter..."
            else
                echo "${GREEN}👋 Exiting Admin Menu.${RESET}"
                log_action "Junior admin exited"
                exit 0
            fi
        ;;
        5)
            [[ "$ROLE" == "senior" ]] && fleet_health || echo "${RED}Access denied.${RESET}"
            read -p "Press Enter..."
        ;;
        6)
            echo "${GREEN}👋 Exiting Admin Menu.${RESET}"
            log_action "$ROLE exited menu"
            exit 0
        ;;
        *)
            echo "${RED}❌ Invalid option.${RESET}"
            read -p "Press Enter..."
        ;;
    esac
done
