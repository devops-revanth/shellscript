#!/bin/bash
while read user; do
  useradd -m $user
  echo "$user:Welcome@123" | chpasswd
  passwd -e $user
done < users.txt


#!/bin/bash
INACTIVE_USERS=$(lastlog -b 90 | awk 'NR>1 {print $1}')
for u in $INACTIVE_USERS; do
  userdel -r $u
done


#!/bin/bash
for u in admin devops tempuser; do
  usermod -L $u
done


#!/bin/bash
chage -M 60 -m 7 -W 7 username


#!/bin/bash
grep -Po '^sudo.+:\K.*$' /etc/group | tr ',' '\n'


#!/bin/bash
grep "Failed password" /var/log/secure | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | head


#!/bin/bash
who
w


#!/bin/bash
pkill -KILL -u username


#!/bin/bash
BACKUP_FILE="/backup/etc_$(date +%F).tar.gz"
tar -czf $BACKUP_FILE /etc


#!/bin/bash
tar -xzf /backup/etc_2025-10-26.tar.gz -C /


#!/bin/bash
tar -czf /backup/home_$(date +%F).tar.gz /home


#!/bin/bash
md5sum /etc/passwd > /var/tmp/passwd.md5

# In cron: compare later
md5sum -c /var/tmp/passwd.md5


#!/bin/bash
find /home -name "authorized_keys" -exec grep -H "" {} \;


#!/bin/bash
echo "=== USERS ==="
cut -d: -f1 /etc/passwd
echo "=== GROUPS ==="
cut -d: -f1 /etc/group


#!/bin/bash
THRESHOLD=5
grep "Failed password" /var/log/secure | awk '{print $(NF-3)}' | sort | uniq -c | \
awk -v t=$THRESHOLD '$1>t {print $2}' | while read ip; do
  iptables -A INPUT -s $ip -j DROP
done
