#!/bin/bash

USER=rgourabathuni
PASS=$(<pass.txt)

for host in $(cat list)
do
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 $USER@$host "uname -n ; sudo grep -i PermitRootLogin /etc/ssh/sshd_config | grep -Ei 'no|yes'" ; echo "============================="  ; 
done