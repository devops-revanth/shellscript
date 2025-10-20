#!/bin/bash

# Node list
NODES=("kubem01" "kubem02" "kubem03")

# VIP
VIP="172.17.220.50"

# Time range
LOG_SINCE="${1:-24 hours ago}"

# Temp log file
TMP_LOG=$(mktemp)

echo "Fetching KubeMaster failover history from all nodes since: $LOG_SINCE"
echo "-----------------------------------------------------------"

for NODE in "${NODES[@]}"; do
    echo "Connecting to $NODE..."

    ssh ansible@"$NODE" "sudo journalctl -u keepalived --since=\"$LOG_SINCE\" | grep 'VRRP_Instance' | grep 'Entering'" 2>/dev/null |
    while read -r line; do
        # Extract timestamp
        TS_RAW=$(echo "$line" | awk '{print $1, $2, $3}')
        # Convert to sortable date
        TS_SORTABLE=$(date -d "$TS_RAW" +"%Y-%m-%d %H:%M:%S" 2>/dev/null)
        # Output sortable line
        echo "$TS_SORTABLE|[$NODE] $line" >> "$TMP_LOG"
    done
done

echo
echo "=========== Combined Failover History (Chronological) ==========="
if [[ -s "$TMP_LOG" ]]; then
    sort "$TMP_LOG" | cut -d'|' -f2-
else
    echo "No failover events in the last $LOG_SINCE."
fi
echo "================================================================="

echo
echo "=========== Current MASTER Node Status ==========="

MASTER_FOUND=0
for NODE in "${NODES[@]}"; do
    if ssh ansible@"$NODE" "sudo PATH=\$PATH:/sbin:/usr/sbin ip addr show | grep -q $VIP"; then
        echo "$NODE is currently the MASTER (has VIP $VIP)"
        MASTER_FOUND=1
    else
        echo "$NODE is BACKUP (VIP not present)"
    fi
done

if [ "$MASTER_FOUND" -eq 0 ]; then
    echo "No node is currently holding the VIP ($VIP)! Possible failover issue."
fi

echo "==================================================="

rm "$TMP_LOG"
