#!/bin/bash

Timestamp=$(date +%F)

echo "The script you are running at $Timestamp"
######################################################################################

echo "Enter you username:"

read -s username

echo "Username entered is : $username

echo "Enter you password now for you user $username"

read -s password

if [ $? -eq 0 ]

then
    echo "You have successfully entered your password for user $username"
else
    echo "There was an error entering your password for user $username"
fi

######################################################################################

A=$1
B=$2

SUM=$((A+B))

echo "The Sum of $A add $B is : $SUM"

#######################################################################################


Movies=("RRR" "KGF" "Bahubali" "Pushpa")

echo " The First Movie in the list is : ${Movies[0]}"
echo " The Second Movie in the list is : ${Movies[1]}"
echo "The Third Movie in the list is : ${Movies[2]}"
echo "The Fourth Movie in the list is : ${Movies[3]}"

AllMovies=${Movies[@]}

echo "All movies in the list are : $AllMovies"

#######################################################################################

echo "The arguments passed to the script are : $@"
echo "Total Number of arguments passed to the script are : $#"
echo "The first argument passed to the script is : $1"
echo "The second argument passed to the script is : $2"
echo "Script Name is : $0"
echo "Process ID of the current script : $$"
echo "Exit status of the last command executed : $?"
echo "User running the current script is : $USER"
echo "Current Shell is : $SHELL"
echo "Current Working Directory is : $PWD"
echo "Home Directory of the current user is : $HOME"
echo "Current Date and Time is : $(date)"
echo "Current User ID is : $UID"
echo "Current Hostname is : $(hostname)"
echo "Current Shell Level is : $SHLVL"
echo "Current Terminal is : $TTY"
echo "Current System Architecture is : $(uname -m)"
echo "Current Operating System is : $(uname -s)"
echo "Current Kernel Version is : $(uname -r)"
echo "Current System Uptime is : $(uptime -p)"
echo "Current Load Average is : $(uptime | awk -F'load average:' '{ print $2 }')"
echo "Current Memory Usage is : $(free -h | grep Mem | awk '{print $3 "/" $2}')"
echo "Current Disk Usage is : $(df -h | grep '^/dev/' | awk '{print $3 "/" $2}')"
echo "Current Network Interfaces are : $(ip -o link show | awk -F': ' '{print $2}')"
echo "Current IP Addresses are : $(hostname -I | awk '{print $1}')"
sleep 3 &
echo "Process id for last command executed is : $!"

#######################################################################################


