#!/bin/bash

###################################################################################################################################
# Create a bash script that automates updating DNS zone files in a BIND-based DNS server. The script should:
#
#1. Take four input arguments:
#   - domain zone filename (e.g., wmt06025-a.symbotic)
#   - subdomain zone filename (e.g., mselect.wmt06020-c.symbotic)
#   - device FQDN to be added (e.g., testserver.wmt06025-a.symbotic)
#   - IP address to map to (e.g., 172.17.36.39)
#
#2. Search and identify the reverse zone file based on the IP address (e.g., 172.17.36.39 → 36.17.172.in-addr.arpa).
#
#3. For each of the three zone files (domain, subdomain, reverse):
#   - Backup the file to `/var/named/symbotic/backup/` (or fallback to `/var/named/symbotic/Backup/`)
#   - Freeze the zone using `rndc freeze`
#   - Update the serial number by increasing the existing value by +3
#   - Append the A record (or PTR record for reverse zone):
#     - A record: `device_fqdn. IN A ip_address`
#     - PTR record: `last_octet IN PTR device_fqdn.`
#   - Thaw the zone using `rndc thaw`
#   - Validate the zone using `named-checkzone`
#
#4. After updating all zones:
#   - Reload the zones with `rndc reload`
#   - Perform a DNS lookup using `dig` to confirm the A record was added
#
#All paths are under `/var/named/symbotic`. The script should use date-stamped backup filenames and exit with errors if any step fails.
#
#Ensure all operations are logged to the console and handle missing files or directories gracefully.

###################################################################################################################################
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <domain_zone_file> <subdomain_zone_file> <device_fqdn> <ip_address>"
    exit 1
fi

DOMAIN_ZONE_FILE="$1"
SUBDOMAIN_ZONE_FILE="$2"
DEVICE_FQDN="$3"
IP_ADDRESS="$4"
BACKUP_DIR="/var/named/symbotic/backup"

if [ ! -d "$BACKUP_DIR" ]; then
    BACKUP_DIR="/var/named/symbotic/Backup"
fi

if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory does not exist: $BACKUP_DIR"
    exit 1
fi

# Function to update zone file
update_zone_file() {
    local zone_file="$1"
    local record_type="$2"
    local record_value="$3"
    local serial
    local backup_file
    local current_date=$(date +%Y%m%d%H%M%S)
    local last_octet=$(echo "$IP_ADDRESS" | awk -F. '{print $4}')
    local reverse_zone_file="${last_octet}.${IP_ADDRESS//./.in-addr.arpa}"
    local reverse_record=""
    if [ "$record_type" == "A" ]; then
        reverse_record="${last_octet} IN PTR ${DEVICE_FQDN}."
    else
        reverse_record="${DEVICE_FQDN}. IN A ${IP_ADDRESS}"
    fi
    backup_file="${BACKUP_DIR}/$(basename "$zone_file")_${current_date}.bak"
    cp "$zone_file" "$backup_file"
    if [ $? -ne 0 ]; then
        echo "Failed to backup $zone_file to $backup_file"
        exit 1
    fi
    rndc freeze "$zone_file"
    if [ $? -ne 0 ]; then
        echo "Failed to freeze zone $zone_file"
        exit 1
    fi
    serial=$(grep -E '^\s*serial\s*;' "$zone_file" | awk '{print $1}')
    if [ -z "$serial" ]; then
        echo "Failed to find serial number in $zone_file"
        exit 1
    fi
    new_serial=$((serial + 3))
    sed -i "s/^\(\s*serial\s*\;\).*/\1
$new_serial ;/" "$zone_file"
    if [ $? -ne 0 ]; then
        echo "Failed to update serial number in $zone_file"
        exit 1
    fi
    echo "${DEVICE_FQDN}. IN A ${IP_ADDRESS}" >> "$zone_file"
    echo "$reverse_record" >> "/var/named/symbotic/$reverse_zone_file"
    if [ $? -ne 0 ]; then
        echo "Failed to append record to $zone_file or reverse zone file"
        exit 1
    fi
    rndc thaw "$zone_file"
    if [ $? -ne 0 ]; then
        echo "Failed to thaw zone $zone_file"
        exit 1
    fi
    named-checkzone "$(basename "$zone_file")" "$zone_file"
    if [ $? -ne 0 ]; then
        echo "Zone file $zone_file is invalid"
        exit 1
    fi
    echo "Updated zone file: $zone_file with record: ${DEVICE_FQDN}. IN A ${IP_ADDRESS}"
}

# Update domain zone file
update_zone_file "/var/named/symbotic/$DOMAIN_ZONE_FILE" "A"
# Update subdomain zone file
update_zone_file "/var/named/symbotic/$SUBDOMAIN_ZONE_FILE" "A
# Update reverse zone file
update_zone_file "/var/named/symbotic/$reverse_zone_file" "PTR"
# Reload all zones
rndc reload
if [ $? -ne 0 ]; then
    echo "Failed to reload zones"
    exit 1
fi

# Perform DNS lookup to confirm the A record was added
dig "$DEVICE_FQDN" @localhost
if [ $? -ne 0 ]; then
    echo "DNS lookup failed for $DEVICE_FQDN"
    exit 1
fi

echo "DNS update completed successfully for $DEVICE_FQDN with IP $IP_ADDRESS"
exit 0

###################################################################################################################################