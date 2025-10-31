#!/bin/bash
THRESHOLD=85
for host in $(cat servers.txt); do
  usage=$(ssh $host "df /data | awk 'NR==2 {print \$5}' | sed 's/%//'")
  if [ $usage -ge $THRESHOLD ]; then
    echo "ALERT: $host /data usage $usage%"
  fi
done



#!/bin/bash
SERVICES=("nginx" "mysql" "redis")

for S in "${SERVICES[@]}"; do
  if ! systemctl is-active --quiet $S; then
    systemctl restart $S
    echo "$(date): $S restarted" >> /var/log/service_monitor.log
  fi
done




#!/bin/bash
DIRS=("/var/log" "/tmp")
THRESHOLD=80

for d in "${DIRS[@]}"; do
  USAGE=$(df $d | awk 'NR==2 {print $5}' | sed 's/%//')
  if [ $USAGE -ge $THRESHOLD ]; then
    find $d -type f -mtime +30 -delete
    echo "$(date): Cleaned $d" >> /var/log/cleanup.log
  fi
done


#!/bin/bash
SERVERS=("10.0.0.1" "10.0.0.2" "10.0.0.3")
CMD="uptime"

for s in "${SERVERS[@]}"; do
  ssh $s "$CMD" &
done
wait
echo "All servers checked"
