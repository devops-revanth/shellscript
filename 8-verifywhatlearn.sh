#!/bin/bash

USERID=$(id -u)

if [ $USERID -ne 0 ]
then
    echo "Hey Buddy , you need to run this script as root or sudo access user , go back and get your privileges"
    exit 1
else
    echo "Woww Buddy , you have privileges , you are good to run this script. Make sure dont do anything funny on this server"
fi

echo "Enter you Username::"

read -s USERNAME

echo "Enters yourname is :: $USERNAME"

eho "Enter your password for the $USERNAME"

read -s PASSWORD
echo $?
if [ $? -ne 0 ]
then
    echo "You havent entererd $PASSWORD"

else
    echo "You did a great job entering your $PASSWORD , remember it well"
fi


#################################################################################################

A=$1
B=$2

Timestamp=$(date)

echo "You are executing this script at $Timestamp"
echo "Make you pass only numbers as Arguments while running the script"

SUM=$((A+B))

echo "Now that you entered numbers, Sum of $A and $B is $SUM"

echo $SUM

###############################################################################################

Movies=("RRR" "GameChanger" "Devara")

echo "First Movie is ${Movies[0]}"
echo "Second Movie is ${Movies[1]}"
echo "Third Movie is ${Movies[2]}"

echo "All movies are ${Movies[@]}"


#############################################################################################

echo "List of Arguments passed $@"
echo "Total number of Arguments passed $#"
echo "Present working directory $PWD"
echo "User who is running the current script $0 is $USER"
echo "Home Directory of Current running user $HOME"
echo "Process id of Current Script $$"
sleep 10 &
echo "Process id last executed background process is $!"
