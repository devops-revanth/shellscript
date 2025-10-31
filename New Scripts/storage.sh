#!/bin/bash
MOUNTS=("/data" "/backup")
for m in "${MOUNTS[@]}"; do
  mountpoint -q $m
  if [ $? -ne 0 ]; then
    echo "ALERT: $m is not mounted on $(hostname)" | mail -s "Mount Alert" admin@example.com
  fi
done


#!/bin/bash
LOGFILE="/var/log/disk_usage.log"
df -h >> $LOGFILE


#!/bin/bash
du -ah / | sort -rh | head -n 20


#!/bin/bash
dd if=/dev/zero of=/data/testfile bs=1G count=1 oflag=dsync
rm -f /data/testfile


#!/bin/bash
for s in $(cat servers.txt); do
  ssh $s "showmount -e nfsserver"
done


#!/bin/bash
yum -y update
echo "$(date): Patch applied on $(hostname)" >> /var/log/patch.log


#!/bin/bash
BEFORE=$(uname -r)
yum -y update kernel
AFTER=$(uname -r)
echo "Before: $BEFORE | After: $AFTER"


#!/bin/bash
LOGDIR="/var/log/myapp"
find $LOGDIR -type f -name "*.log" -mtime +7 -exec gzip {} \;


#!/bin/bash
SRC="/var/log"
DEST="backup01:/data/logarchive/"
find $SRC -type f -mtime +30 -print0 | xargs -0 -I{} scp {} $DEST


#!/bin/bash
tail -Fn0 /var/log/myapp/app.log | \
while read line; do
  echo "$line" | grep -i "error" && \
  echo "Error detected on $(hostname)" | mail -s "App Error" devops@example.com
done


#!/bin/bash
LOG="/var/log/myapp/app.log"
SIZE=$(du -m $LOG | awk '{print $1}')
if [ $SIZE -ge 1000 ]; then
  echo "Log file $LOG is ${SIZE}MB" | mail -s "Log Alert" admin@example.com
fi


#!/bin/bash
journalctl -p 3 -xb


#!/bin/bash
THRESHOLD=85
HOOK_URL="https://hooks.slack.com/services/XXXX/XXXX/XXXX"
df -h | awk 'NR>1 {print $5 " " $6}' | while read output; do
  usep=$(echo $output | awk '{print $1}' | sed 's/%//')
  partition=$(echo $output | awk '{print $2}')
  if [ $usep -ge $THRESHOLD ]; then
    curl -X POST -H 'Content-type: application/json' \
      --data "{\"text\":\"ALERT: $partition is ${usep}% full on $(hostname)\"}" \
      $HOOK_URL
  fi
done


#!/bin/bash
for host in $(cat servers.txt); do
  scp $host:/var/log/messages /central_logs/$host-$(date +%F).log
done


#!/bin/bash
echo "==== DAILY HEALTH REPORT $(date) ====" > /tmp/health_report.txt
systemctl status nginx >> /tmp/health_report.txt
df -h >> /tmp/health_report.txt
grep "error" /var/log/myapp/app.log | tail -n 20 >> /tmp/health_report.txt
mail -s "Health Report $(hostname)" admin@example.com < /tmp/health_report.txt
