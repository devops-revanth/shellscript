#!/bin/bash
TARGET="8.8.8.8"
PING_TIME=$(ping -c 4 $TARGET | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
if (( $(echo "$PING_TIME > 100" | bc -l) )); then
  echo "High latency detected: ${PING_TIME}ms" | mail -s "Latency Alert" netops@example.com
fi


#!/bin/bash
IFACE="eth0"
sar -n DEV 1 1 | grep $IFACE


#!/bin/bash
HOST="web01"
for p in {1..1024}; do
  (echo > /dev/tcp/$HOST/$p) >/dev/null 2>&1 && echo "Port $p open"
done



#!/bin/bash
for host in $(cat servers.txt); do
  echo "Checking $host"
  ssh $host "yum check-update | wc -l"
done


#!/bin/bash
DOMAIN="example.com"
EXPIRY=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
DAYS_LEFT=$(( ( $(date -d "$EXPIRY" +%s) - $(date +%s) )/(60*60*24) ))
if [ $DAYS_LEFT -le 15 ]; then
  echo "SSL Cert expiring in $DAYS_LEFT days for $DOMAIN" | mail -s "SSL Alert" admin@example.com
fi


#!/bin/bash
DOMAIN="example.com"
for host in $(cat servers.txt); do
  ssh $host "nslookup $DOMAIN" | grep "Address"
done


#!/bin/bash
sudo netstat -tunapl | awk '{print $5}' | sort | uniq -c | sort -nr | head


#!/bin/bash
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head


#!/bin/bash
for host in $(cat servers.txt); do
  ssh-copy-id -i ~/.ssh/id_rsa.pub $host
done


#!/bin/bash
grep "Accepted" /var/log/secure | awk '{print $1,$2,$3,$9,$11}' | sort | uniq -c | sort -nr | head


#!/bin/bash
grep "sudo:" /var/log/secure | awk '{print $1,$2,$3,$9}' | sort | uniq -c | sort -nr | head


#!/bin/bash
dd if=/dev/zero of=/tmp/testfile bs=1G count=1 oflag=dsync
rm -f /tmp/testfile


#!/bin/bash
dmesg | grep -i panic
journalctl -k | grep -i panic


#!/bin/bash
grep -i "error\|fail" /var/log/cron


#!/bin/bash
for h in $(cat servers.txt); do
  ssh $h "uptime" &
done
wait


