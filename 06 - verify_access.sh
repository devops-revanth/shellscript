#!/bin/bash

USER=rgourabathuni
PASS=$(<pass.txt)

for host in $(cat list)
do
  echo "Checking $host..."
  sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 $USER@$host "echo '✅ SSH access OK on $host'" 2>/dev/null

  if [ $? -eq 0 ]; then
    echo "$host - SSH Login Successful"
  else
    echo "$host - ❌ SSH Login Failed"
  fi
  echo "--------------------------------------"
done
