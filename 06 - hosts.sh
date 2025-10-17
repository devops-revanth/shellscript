#!/bin/bash

USER=rgourabathuni
PASS=$(<pass.txt)

for host in $(cat list)
do
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 $USER@$host "uname -n ; cat /etc/hosts | grep -w $host" ; 
done