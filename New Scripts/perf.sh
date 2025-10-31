#!/bin/bash
LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | awk '{ print $1 }' | cut -d. -f1)
THRESHOLD=5
if [ $LOAD -ge $THRESHOLD ]; then
  echo "$(date): High load detected: $LOAD" >> /var/log/load_alert.log
fi


#!/bin/bash
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head


#!/bin/bash
ps aux --sort=-%mem | head -n 10


#!/bin/bash
SWAP=$(free | awk '/Swap/ {print ($3/$2)*100}' | cut -d. -f1)
THRESHOLD=50
if [ $SWAP -ge $THRESHOLD ]; then
  echo "ALERT: Swap usage at $SWAP%" | mail -s "Swap Alert" admin@example.com
fi


#!/bin/bash
ZOMBIES=$(ps -eo stat,ppid,pid,cmd | grep -w Z)
if [ ! -z "$ZOMBIES" ]; then
  echo "Zombie processes detected:" >> /var/log/zombie.log
  echo "$ZOMBIES" >> /var/log/zombie.log
fi


#!/bin/bash
USED=$(lsof | wc -l)
LIMIT=$(ulimit -n)
PERCENT=$((100*USED/LIMIT))
if [ $PERCENT -gt 85 ]; then
  echo "High FD usage ($PERCENT%)" | mail -s "FD Alert" admin@example.com
fi


#!/bin/bash
iostat -xz 1 3 | awk '$1 ~ /Device/ || $1 ~ /sd/ {print $1,$4,$10}'


#!/bin/bash
sar -n DEV 1 1 | grep eth0


#!/bin/bash
find /tmp -type f -mtime +7 -delete
find /var/log -type f -mtime +30 -delete


#!/bin/bash
ss -tuna | wc -l


#!/bin/bash
ps -eLo pid,ppid,tid,pcpu,pmem,args --sort=-pcpu | head


#!/bin/bash
free -m | awk 'NR==2{printf "Used:%sMB Free:%sMB Buffers:%sMB Cache:%sMB\n", $3,$4,$6,$7 }'


#!/bin/bash
CPU=$(top -bn1 | awk '/Cpu/ {print $2}' | cut -d. -f1)
if [ $CPU -ge 90 ]; then
  systemctl restart nginx
  echo "$(date): Restarted nginx due to high CPU" >> /var/log/autofix.log
fi


#!/bin/bash
REPORT=/tmp/health_report.txt
echo "=== SYSTEM HEALTH REPORT $(date) ===" > $REPORT
uptime >> $REPORT
df -h >> $REPORT
free -m >> $REPORT
iostat -xz 1 2 >> $REPORT
mail -s "Health Report $(hostname)" admin@example.com < $REPORT


#!/bin/bash
echo "$(date),$(uptime | awk -F'load average:' '{ print $2 }' | awk '{ print $1 }'),$(free | awk '/Mem/ {print $3}')" >> /var/log/resource_trend.csv


#!/bin/bash
for host in $(cat servers.txt); do
  ssh -o ConnectTimeout=5 $host "hostname; uptime; df -h /" &
done
wait


#!/bin/bash
for host in $(cat servers.txt); do
  echo "Restarting nginx on $host"
  ssh $host "systemctl restart nginx" && sleep 2
done


#!/bin/bash
for host in $(cat servers.txt); do
  ssh $host "yum -y update" &
done
wait


#!/bin/bash
DEST="/central_logs/incident_$(date +%F)"
mkdir -p $DEST
for host in $(cat servers.txt); do
  scp $host:/var/log/messages $DEST/$host.log &
done
wait


#!/bin/bash
THRESHOLD=85
HOOK_URL="https://hooks.slack.com/services/XXX/YYY/ZZZ"
df -h | awk 'NR>1 {print $5 " " $6}' | while read line; do
  usep=$(echo $line | awk '{print $1}' | sed 's/%//')
  mount=$(echo $line | awk '{print $2}')
  if [ $usep -ge $THRESHOLD ]; then
    curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\":rotating_light: ALERT: $mount is ${usep}% full on $(hostname)\"}" \
    $HOOK_URL
  fi
done


#!/bin/bash
REPORT=/tmp/fleet_uptime.txt
echo "=== Uptime Report $(date) ===" > $REPORT
for host in $(cat servers.txt); do
  echo "---- $host ----" >> $REPORT
  ssh $host "uptime" >> $REPORT
done
mail -s "Fleet Uptime Report" admin@example.com < $REPORT


#!/bin/bash
TS=$(date +%F_%H-%M)
mkdir -p /incident_snapshots/$TS
uptime > /incident_snapshots/$TS/uptime.log
df -h > /incident_snapshots/$TS/disk.log
top -bn1 > /incident_snapshots/$TS/top.log
ss -tuna > /incident_snapshots/$TS/net.log


#!/bin/bash
for host in $(cat servers.txt); do
  CPU=$(ssh $host "top -bn1 | awk '/Cpu/ {print $2}' | cut -d. -f1")
  if [ $CPU -ge 90 ]; then
    echo "$host is at $CPU% CPU"
  fi
done


#!/bin/bash
tail -Fn0 /var/log/nginx/error.log | \
while read line; do
  echo "$line" | grep -i "connection refused" && \
  systemctl restart nginx
done


#!/bin/bash
for host in $(cat servers.txt); do
  curl -s http://$host:9100/metrics >/dev/null
  if [ $? -ne 0 ]; then
    echo "Exporter down on $host"
  fi
done


#!/bin/bash
SERVICE=$1
systemctl restart $SERVICE
echo "$(date): $SERVICE restarted due to Nagios alert" >> /var/log/recovery.log


#!/bin/bash
NODE=$1
ssh lb01 "sed -i \"/$NODE/d\" /etc/haproxy/backends.cfg && systemctl reload haproxy"


#!/bin/bash
for host in $(cat servers.txt); do
  ssh $host "nohup shutdown -r now" &
  sleep 10
done
wait


#!/bin/bash
MSG="Incident started at $(date) - high CPU load on EU cluster"
curl -X POST -H 'Content-type: application/json' \
--data "{\"text\":\"$MSG\"}" https://hooks.slack.com/services/XXX/YYY/ZZZ


#!/bin/bash
THRESHOLD=85
HOOK_URL="https://hooks.slack.com/services/XXX/YYY/ZZZ"
df -h | awk 'NR>1 {print $5 " " $6}' | while read line; do
  usep=$(echo $line | awk '{print $1}' | sed 's/%//')
  mount=$(echo $line | awk '{print $2}')
  if [ $usep -ge $THRESHOLD ]; then
    find $mount -type f -mtime +30 -delete
    curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\":white_check_mark: Auto-cleanup done on $(hostname), $mount usage was ${usep}%\"}" \
    $HOOK_URL
  fi
done
