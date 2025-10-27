#!/bin/bash

# Array containing the list of servers
SERVER_LIST=("linuxlist")

mapfile -t SERVERS < "$SERVER_LIST"

# Path to the script you want to SCP
LOCAL_SCRIPT_PATH="/usr/local/scripts/ae/SYM_ae_scan_linux.sh"
REMOTE_SCRIPT_DIR="/usr/local/scripts/ae"
REMOTE_SCRIPT_PATH="$REMOTE_SCRIPT_DIR/SYM_ae_scan_linux.sh"

SSH_KEY="/home/ansible/.ssh/id_ed25519"

# SSH Options to avoid prompts and use key-based authentication
SSH_OPTIONS="-o BatchMode=yes -o StrictHostKeyChecking=no -i $SSH_KEY"

echo "Starting the installation process..."

# Loop through each server and perform the tasks
for server in "${SERVERS[@]}"; do
    echo "Connecting to $server to set up the script and cron job..."

    # Step 1: Create the directory on the remote server
    ssh $SSH_OPTIONS ansible@"$server" "sudo rm -rf $REMOTE_SCRIPT_DIR"
    ssh $SSH_OPTIONS ansible@"$server" "sudo mkdir -p $REMOTE_SCRIPT_DIR"
    result=$?
    if [ $result -ne 0 ]; then
        echo "Failed to create directory on $server. Skipping this server."
        continue
    fi

    # Step 2: Change ownership on the remote server
    ssh $SSH_OPTIONS ansible@"$server" "sudo chown ansible:ansible $REMOTE_SCRIPT_DIR"
    result=$?
    if [ $result -ne 0 ]; then
        echo "Failed to create directory on $server. Skipping this server."
        continue
    fi

    # Step 3: SCP the script to the remote server
    scp $SSH_OPTIONS "$LOCAL_SCRIPT_PATH" ansible@"$server":"$REMOTE_SCRIPT_PATH"
    result=$?
    if [ $result -ne 0 ]; then
        echo "Failed to copy the script to $server. Skipping this server."
        continue
    fi

    # Step 4: Change ownership on the remote server
    ssh $SSH_OPTIONS ansible@"$server" "sudo chown -R root:root $REMOTE_SCRIPT_DIR"
    result=$?
    if [ $result -ne 0 ]; then
        echo "Failed to create directory on $server. Skipping this server."
        continue
    fi

    # Step 5: Change permission on the remote server
    ssh $SSH_OPTIONS ansible@"$server" "sudo chmod 755 $REMOTE_SCRIPT_PATH"
    result=$?
    if [ $result -ne 0 ]; then
        echo "Failed to create directory on $server. Skipping this server."
        continue
    fi

    # Step 6: Add a cron job to run the script at 1:00 AM on the 1st of every month
    ssh $SSH_OPTIONS ansible@"$server" "echo '0 0 1 * * /usr/local/scripts/ae/SYM_ae_scan_linux.sh' | sudo tee -a /var/spool/cron/root"
    result=$?

    if [ $result -eq 0 ]; then
        echo "Installation successful on $server."
    else
        echo "Failed to set up cron job on $server. Error code: $result"
    fi
done

echo "Installation process completed for all servers."
