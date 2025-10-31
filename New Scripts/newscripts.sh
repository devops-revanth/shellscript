#!/bin/bash
THRESHOLD=85
df -h | awk 'NR>1 {print $5 " " $6}' | while read output; do
  usep=$(echo $output | awk '{print $1}' | sed 's/%//')
  partition=$(echo $output | awk '{print $2}')
  if [ $usep -ge $THRESHOLD ]; then
    echo "ALERT: $partition at ${usep}% on $(hostname)" | mail -s "Disk Alert" admin@example.com
  fi
done



#!/bin/bash
SERVICES=("nginx" "sshd" "mysql")

for s in "${SERVICES[@]}"; do
  if ! systemctl is-active --quiet $s; then
    systemctl restart $s
    echo "$(date): Restarted $s" >> /var/log/service_restart.log
  fi
done


#!/bin/bash
LOG_DIR="/var/log"
find $LOG_DIR -type f -mtime +30 -delete


#!/bin/bash
for host in $(cat /opt/server_list.txt); do
  echo "---- $host ----"
  ssh $host "hostname; uptime"
done


#!/bin/bash
CPU=$(top -bn1 | awk '/Cpu/ {print $2}' | cut -d. -f1)
if [ $CPU -ge 90 ]; then
  echo "$(date): High CPU ($CPU%)" >> /var/log/cpu_alert.log
fi


#!/bin/bash
PROCESS="myapp"
if ! pgrep -x "$PROCESS" > /dev/null; then
  echo "ALERT: $PROCESS not running" | mail -s "Process Alert" admin@example.com
fi


#!/bin/bash
SRC="/var/www"
DEST="/backup/www_$(date +%F).tar.gz"
tar -czf $DEST $SRC
find /backup -type f -mtime +7 -delete


#!/bin/bash
for host in $(cat servers.txt); do
  if ssh -o ConnectTimeout=5 $host "exit" 2>/dev/null; then
    echo "$host is reachable"
  else
    echo "$host is DOWN"
  fi
done


#!/bin/bash
tail -n0 -F /var/log/secure | while read line; do
  echo "$line" | grep "Accepted password for root" && \
  echo "Root login detected on $(hostname)" | mail -s "Security Alert" security@example.com
done


#!/bin/bash
echo "### SYSTEM REPORT - $(date) ###" > /tmp/sys_report.txt
echo "Hostname: $(hostname)" >> /tmp/sys_report.txt
df -h >> /tmp/sys_report.txt
free -m >> /tmp/sys_report.txt
uptime >> /tmp/sys_report.txt
mail -s "System Report $(hostname)" admin@example.com < /tmp/sys_report.txt


#!/bin/bash
CURRENT=$(uname -r)
LATEST=$(rpm -q kernel | tail -n 1 | awk -F'kernel-' '{print $2}')
if [ "$CURRENT" != "$LATEST" ]; then
  echo "Reboot required on $(hostname)" | mail -s "Reboot Reminder" admin@example.com
fi


#!/bin/bash
HOST="app01"
PORTS=(22 80 443)
for p in "${PORTS[@]}"; do
  nc -zv $HOST $p 2>/dev/null && echo "$p open" || echo "$p closed"
done


#!/bin/bash
ps -eo stat,ppid,pid,cmd | grep -w Z


#!/bin/bash
MD5FILE="/var/tmp/md5list.txt"
find /etc -type f -exec md5sum {} \; > $MD5FILE
# Later compare with:
# md5sum -c $MD5FILE


#!/bin/bash
USED=$(free | awk '/Mem/{printf("%.0f"), $3/$2 * 100}')
if [ $USED -ge 85 ]; then
  echo "ALERT: Memory usage at $USED%" | mail -s "Memory Alert" admin@example.com
fi



