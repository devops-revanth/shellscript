#!/bin/bash


for i in $(cat hostlist); do
  ssh $i "uname -r; lsmod | grep ixgbe; sysctl net.ipv4.tcp_fin_timeout"
done

for i in $(cat hosts); do
  ssh $i "hostname; df -h | awk '{if(\$5+0>80) print \$0}'"
done

for i in $(cat servers); do
  ssh $i "hostname; ip -s link | grep -A1 eth0 | grep -i drop"
done


THRESHOLD=80
for fs in $(df -h | awk 'NR>1 {print $5" "$6}'); do
  usage=$(echo $fs | awk '{print $1}' | sed 's/%//')
  mount=$(echo $fs | awk '{print $2}')
  if [ $usage -ge $THRESHOLD ]; then
    echo "Alert: $mount usage is $usage%"
  fi
done


SERVICE="nginx"
if ! systemctl is-active --quiet $SERVICE; then
  systemctl restart $SERVICE
  echo "$(date): $SERVICE restarted" >> /var/log/service_monitor.log
fi


#!/bin/bash
THRESHOLD=85
DIRS=("/var/log" "/tmp")
for d in "${DIRS[@]}"; do
  usage=$(df $d | awk 'NR==2 {print $5}' | sed 's/%//')
  if [ $usage -ge $THRESHOLD ]; then
    find $d -type f -mtime +30 -delete
    echo "$(date): Cleaned $d due to high usage" >> /var/log/cleanup.log
  fi
done
