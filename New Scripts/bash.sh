

#Variables & Environment


SERVER="web01"
LOG_PATH="/var/log/sysmon.log"


Conditional Statements


if [ $(df / | awk 'NR==2 {print $5}' | sed 's/%//') -gt 80 ]; then
  echo "Disk full!"
fi


Loops


for server in $(cat servers.txt); do
  ssh $server "df -h"
done


Functions


check_disk() {
  local server=$1
  ssh $server "df -h"
}
check_disk web01



Functions
check_disk() {
  local server=$1
  USAGE=$(ssh $server "df /data | awk 'NR==2 {print \$5}' | sed 's/%//'")
  if [ $USAGE -ge 80 ]; then
    echo "$server: Disk full ($USAGE%)"
  fi
}

for s in $(cat servers.txt); do
  check_disk $s
done



Cron Jobs





# Run every 5 minutes
*/5 * * * * /usr/local/bin/check_disk.sh



Error Handling


set -e   # Exit on first error
set -u   # Treat unset variables as error

Logging


exec >> /var/log/my_script.log 2>&1
echo "$(date) Script started"

Notifications


echo "Disk full on $SERVER" | mail -s "ALERT" admin@example.com

Input Validation


if [[ ! -f "$1" ]]; then
  echo "Usage: $0 <filename>"
  exit 1
fi

Dynamic Arrays / Parameter Expansion


FILES=(/var/log/*.log)
for f in "${FILES[@]}"; do
  gzip "$f"
done

