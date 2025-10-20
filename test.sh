#!/bin/bash

PASSWORD='Lucky2025#$IRV'
USER='rgourabathuni'

while read -r host <&3; do
  [ -n "$host" ] || continue   # skip empty lines

# Add separator for readability
sleep 1
  echo "========================================="
  echo "Processing host: $host"
  echo "========================================="

#Testing connection with uptime  
  echo "Checking uptime on $host..." 
  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USER@"$host" "uptime" < /dev/null
  
  if [ $? -eq 0 ] ; 
  then
    echo "############################################"
    echo "Uptime check OK for $host"
    echo "############################################"
  else 
    echo "Uptime check failed for $host, skipping..."
  continue
  fi

# Step 1: Copy the Asset client installation file to each server

echo ""
echo "Copying the AE file to $host"
 echo "" 
  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USER@"$host" \
    "echo $PASSWORD | sudo -S mkdir -p /usr/local/scripts/ae" < /dev/null
  
  echo "Creating Directory if not exists on $host"


  sshpass -p "$PASSWORD" scp /tmp/SYM_ae_scan_linux.sh $USER@"$host":/tmp

  if [ $? -eq 0 ]; 
  then
       echo "File copied to $host"
       sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USER@"$host" \
      "echo $PASSWORD | sudo -S mv /tmp/SYM_ae_scan_linux.sh /usr/local/scripts/ae/ && \
       echo $PASSWORD | sudo -S chmod 755 /usr/local/scripts/ae/SYM_ae_scan_linux.sh" 
  else
      echo "File copy failed for $host"
  fi

# Step 2: Install Asset client

echo ""
echo "Starting the AE installation on $host"
echo ""
  echo "Installing AE agent on $host..."
  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USER@"$host" \
    "echo $PASSWORD | sudo -S bash /usr/local/scripts/ae/SYM_ae_scan_linux.sh" < /dev/null
  
  if [ $? -eq 0 ] ; 
  then
    echo "Asset Explorer installation success on $host"
  else
    echo "Asset Explorer installation failed for $host"
  fi


 
# Step 3: Add service crontab entry
echo ""
echo "Starting the CRON TAB entry stage on $host"
echo "" 

  echo "Adding crontab entry on $host..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USER@"$host" \
"CRON_CMD='0 0 1 * * /usr/local/scripts/ae/SYM_ae_scan_linux.sh'; \
(sudo crontab -l 2>/dev/null | grep -Fq \"\$CRON_CMD\") || \
(sudo crontab -l 2>/dev/null; echo \"\$CRON_CMD\") | sudo crontab -" < /dev/null
  
  if [ $? -eq 0 ]; then
    echo "Adding Crontab entry for AE success on $host"
  else
    echo "Asset Explorer crontab entry failed on $host"
  fi

# Add separator for readability
sleep 1

# Step 4: Verifying crontab entry
echo "" 
echo "Verifying crontab on $host..."
echo "" 

sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USER@"$host" \
    "sudo crontab -l | grep -q '/usr/local/scripts/ae/SYM_ae_scan_linux.sh'" < /dev/null
  
if [ $? -eq 0 ]; then
    echo " Cron job exists on $host"
else
    echo " Cron job missing on $host"
fi

echo "========================================="
echo "Completed processing for $host"
echo "========================================="
echo ""

done < list