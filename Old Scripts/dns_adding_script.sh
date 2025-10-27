#!/bin/bash

##################################################
# Description : I used to do dns changes in our environment , some times need to adding new entries and sometimes modifying entries 
# for now we will concentrate on adding new entries , we have multile sites and each is having different DC
# Each is ending with file .symbotic but before it will have different name for each site here i am giving 2 examples wmtusorhrm01.symbotic and wmt06025-a.symbotic
# User need to give domain name so we can modify that file for adding new entries
# Below are the steps I run manually to add new entries
# 1. cd /var/named/symbotic
# 2. cp wmt06025-a.symbotic backup/wmt06025-a.symbotic.$date  # backup folder will be either backup or Backup
# 3. before doing any changes will freeze the dns service -> rndc freeze wmt06025-a.symbotic
# 4. vi wmt06025-a.symbotic
# 5. will increase serial number by 3 before adding new entries
# 6. add new entries in the file
# 7. save and exit
# 8. will thaw the dns service -> rndc thaw wmt06025-a.symbotic
# 9. will check the syntax of the file -> named-checkzone wmt06025-a.symbotic /var/named/symbotic/wmt06025-a.symbotic
# 10. Now will add the new entire to the subdomain file dependns on the user requirement here i am going to add entry to mselect.wmt06020-c.symbotic
# 11. Before adding new entry to subdomain file we need to freeze the service -> rndc freeze mselect.wmt06020-c.symbotic
# 12. cp mselect.wmt06020-c.symbotic backup/mselect.wmt06020-c.symbotic.$date
# 13. vi mselect.wmt06020-c.symbotic
# 14. will increase serial number by 3 before adding new entries
# 15. add new entries in the file
# 16. save and exit
# 17. will thaw the dns service -> rndc thaw mselect.wmt06020-c.symbotic
# 18. will check the syntax of the file -> named-checkzone mselect.wmt06020-c.symbotic /var/named/symbotic/mselect.wmt06020-c.symbotic
# 19. Now we will reload the dns service
# 20. rndc reload mselect.wmt06020-c.symbotic
# 21. rndc reload wmt06025-a.symbotic
# Now will add reverse entries to the reverse file based on the user input of ipaddress we will have file like if ipaddress is 172.17.36.39 we will have file like 36.17.172.in-addr.arpa , ipaddress is 172.17.37.39
 we will have file like 37.17.172.in-addr.arpa
 # copy the file to backup folder
# 22. cp 36.17.172.in-addr.arpa backup/36.17.172.in-addr.arpa.$date
# 23. will freeze the dns service -> rndc freeze 36.17.172.in-addr.arpa
# 23. vi 36.17.172.in-addr.arpa
# 24. will increase serial number by 3
# 25. add new entries in the file
# 26. save and exit
# 27. will thaw the dns service -> rndc thaw 36.17.172.in-addr.arpa
# 28. will check the syntax of the file -> named-checkzone 36.17.172.in-addr.arpa /var/named/symbotic/36.17.172.in-addr.arpa
# 29. Now we will reload the dns service
# 30. rndc reload 36.17.172.in-addr.arpa
# 31. rndc reload mselect.wmt06020-c.symbotic
# 32. rndc reload wmt06025-a.symbotic
# 33. Now we will check entries status using dig command
# 34. dig @<dc_ip> <domain_name>
# 35. dig @<dc_ip> <subdomain_name>

# I want script to be line when he run the script it will ask for user input for the entries of entries of device with full name and ip address
# and it will do all the steps mentioned above automatically
##################################################

# Function to display usage
usage() {
    echo "Usage: $0 <domain_name> <subdomain_name> <ip_address>"
    echo "Example: $0 wmt06025-a.symbotic mselect.wmt06020-c.symbotic
#
    echo "This script will add new DNS entries and perform necessary operations."
    exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    usage
fi

DOMAIN_NAME=$1
SUBDOMAIN_NAME=$2
IP_ADDRESS=$3
DATE=$(date +%Y%m%d%H%M%S)
BACKUP_DIR="/var/named/symbotic/backup"
BACKUP_DIR_ALT="/var/named/symbotic/Backup"
# Check if backup directory exists, if not create it
if [ ! -d "$BACKUP_DIR" ] && [ ! -d "$BACKUP_DIR_ALT" ]; then
    echo "Backup directory does not exist. Please create it at $BACKUP_DIR or $BACKUP_DIR_ALT."
    exit 1
fi

# Determine the backup directory
if [ -d "$BACKUP_DIR" ]; then
    BACKUP_DIR="$BACKUP_DIR"
else
    BACKUP_DIR="$BACKUP_DIR_ALT"
fi

# Function to perform DNS operations
perform_dns_operations() {
    local file_name=$1
    local subdomain_file=$2
    local ip_file=$(echo $IP_ADDRESS | awk -F. '{print $3"."$2"."$1".in-addr.arpa"}')
    local ip_file_path="/var/named/symbotic/$ip_file"
    local ip_backup_file="$BACKUP_DIR/$ip_file.$DATE"
    local file_path="/var/named/symbotic/$file_name"
    local backup_file="$BACKUP_DIR/$file_name.$DATE"
    local subdomain_path="/var/named/symbotic/$subdomain_file"
    local subdomain_backup="$BACKUP_DIR/$subdomain_file.$DATE"
    local dc_ip="<dc_ip>"  # Replace with actual DC IP
    local serial_number
    local new_serial
    local entry
    local entry_ip
    local entry_ip_reversed
    local entry_reversed
    local entry_reversed_file
    local entry_reversed_backup
    local entry_reversed_path
    local entry_reversed_backup_path
    local entry_reversed_serial
    local entry_reversed_new_serial
    local entry_reversed_ip
    local entry_reversed_ip_parts
    local entry_reversed_ip_file
    local entry_reversed_ip_file_path
    local entry_reversed_ip_backup
    local entry_reversed_ip_backup_path
    local entry_reversed_ip_parts
    local entry_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_backup_path
    local entry_reversed_ip_parts_reversed_serial
    local entry_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup_path
        local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup_path.
        local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_backup_path
        local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
        local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
        local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file  
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_backup_path
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_new_serial
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed_ip_file
    local entry_reversed_ip_parts_reversed_ip_parts_reversed_ip_parts_reversed  


    