#!/bin/bash

PASSWORD='Lucky2025#$IRV'
USER='rgourabathuni'

while read -r host; do
  [ -n "$host" ] || continue   # Skip empty lines

  echo "========================================="
  echo "Processing host: $host"
  echo "========================================="

  # Step 0: Check connection
  echo "Checking uptime on $host..."
  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USER@$host" \
    "echo $PASSWORD | sudo -S uptime" < /dev/null

  if [ $? -eq 0 ]; then
    echo "############################################"
    echo "Uptime check OK for $host"
    echo "############################################"
  else
    echo "Uptime check failed for $host, skipping..."
    continue
  fi

  # Step 1: Copy AE file
  echo ""
  echo "Copying the AE file to $host"
  echo ""

  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USER@$host" \
    "echo $PASSWORD | sudo -S mkdir -p /usr/local/scripts/ae" < /dev/null

  sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no /tmp/SYM_ae_scan_linux.sh "$USER@$host":/tmp/

  if [ $? -eq 0 ]; then
    echo "File copied successfully to $host"
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USER@$host" \
      "echo $PASSWORD | sudo -S mv /tmp/SYM_ae_scan_linux.sh /usr/local/scripts/ae/ && \
       echo $PASSWORD | sudo -S chmod 755 /usr/local/scripts/ae/SYM_ae_scan_linux.sh"
  else
    echo "File copy failed for $host"
    continue
  fi

  # Step 2: Install AE agent
  echo ""
  echo "Starting AE installation on $host"
  echo ""

  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USER@$host" \
    "echo $PASSWORD | sudo -S bash /usr/local/scripts/ae/SYM_ae_scan_linux.sh" < /dev/null

  if [ $? -eq 0 ]; then
    echo "Asset Explorer installation success on $host"
  else
    echo "Asset Explorer installation failed for $host"
  fi

  # Step 3: Add CRON job
  echo ""
  echo "Adding crontab entry on $host..."
  echo ""

  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USER@$host" \
    "CRON_CMD='0 0 1 * * /usr/local/scripts/ae/SYM_ae_scan_linux.sh'; \
     (sudo crontab -l 2>/dev/null | grep -Fq \"\$CRON_CMD\") || \
     (sudo crontab -l 2>/dev/null; echo \"\$CRON_CMD\") | sudo crontab -" < /dev/null

  if [ $? -eq 0 ]; then
    echo "Crontab entry added successfully on $host"
  else
    echo "Failed to add crontab entry on $host"
  fi

  # Step 4: Verify CRON job
  echo ""
  echo "Verifying crontab on $host..."
  echo ""

  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USER@$host" \
    "sudo crontab -l | grep -q '/usr/local/scripts/ae/SYM_ae_scan_linux.sh'" < /dev/null

  if [ $? -eq 0 ]; then
    echo "Cron job exists on $host"
  else
    echo "Cron job missing on $host"
  fi

  echo "========================================="
  echo "Completed processing for $host"
  echo "========================================="
  echo ""
  sleep 2

done < list
