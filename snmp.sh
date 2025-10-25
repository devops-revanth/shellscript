#!/bin/bash

SERVER_LIST="list"
AUTHPASS_FILE="authpass.txt"
PRIVPASS_FILE="privpass.txt"
SSHPASS_FILE="sshpass.txt"
SSH_USER="rgourabathuni"

AUTHPASS=$(<"$AUTHPASS_FILE")
PRIVPASS=$(<"$PRIVPASS_FILE")
SSHPASS=$(<"$SSHPASS_FILE")

while read -r SERVER; do
    echo "------ Processing $SERVER ------"

    sshpass -p "$SSHPASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$SERVER" bash -s <<EOF
# Detect the IPv4 address on the remote host
ipaddr=\$(ip -br addr | grep en | awk '{print \$3}' | cut -d'/' -f1)

# -------------------------------
# Check if snmpd is installed
# -------------------------------
if ! rpm -q net-snmp &>/dev/null; then
    echo "SNMP not installed. Installing..."
    sudo yum -y install net-snmp net-snmp-utils
    sudo systemctl stop snmpd
    sudo net-snmp-create-v3-user -ro -A "$AUTHPASS" -X "$PRIVPASS" -a SHA -x AES lm_snmp_svc
    sudo systemctl restart snmpd
    sudo systemctl enable snmpd
fi

# -------------------------------
# Test SNMPv3 string
# -------------------------------
if ! snmpwalk -v3 -l authpriv -u lm_snmp_svc -a SHA -A "$AUTHPASS" -x AES -X "$PRIVPASS" \$ipaddr 1.3.6.1.4.1 &>/dev/null; then
    echo "SNMP string test failed. Recreating SNMPv3 user..."
    sudo systemctl stop snmpd
    sudo net-snmp-create-v3-user -ro -A "$AUTHPASS" -X "$PRIVPASS" -a SHA -x AES lm_snmp_svc
    sudo systemctl start snmpd
    sudo systemctl restart snmpd
    sudo systemctl enable snmpd
    sleep 5

    if snmpwalk -v3 -l authpriv -u lm_snmp_svc -a SHA -A "$AUTHPASS" -x AES -X "$PRIVPASS" \$ipaddr 1.3.6.1.4.1 &>/dev/null; then
        echo "SNMP configured successfully on $SERVER"
    else
        echo "SNMP test still failing on $SERVER"
    fi
else
    echo "All good, SNMP is installed, string is passing, inform Bernard"
fi
EOF

done < "$SERVER_LIST"

echo "------ All servers processed ------"



