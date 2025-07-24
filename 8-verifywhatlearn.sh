#!/bin/bash

USERID=$(id -u)

if [ $USERID -ne 0 ]
then
    echo "Hey Buddy , you need to run this script as root or sudo access user , go back and get your privileges"
    exit 1
else
    echo "Woww Buddy , you have privileges , you are good to run this script. Make sure dont do anything funny on this server"
fi

sleep 5 

echo "Enter you Username::"

read -s USERNAME

echo "Enters yourname is :: $USERNAME"

echo "Enter your password for the $USERNAME"

read -s PASSWORD
#echo $?
if [ $? -ne 0 ]
then
    echo "You havent entererd $PASSWORD"

else
    echo "You did a great job entering your Password for $USERNAME , remember it well"
fi


echo "##########################################################################################"

A=$1
B=$2

Timestamp=$(date)

echo "You are executing this script at $Timestamp"
echo "Make you pass only numbers as Arguments while running the script"

SUM=$((A+B))

echo "Now that you entered numbers, Sum of $A and $B is $SUM"

#echo $SUM

echo "##########################################################################################"
###############################################################################################

Movies=("RRR" "GameChanger" "Devara")

echo "First Movie is ${Movies[0]}"
echo "Second Movie is ${Movies[1]}"
echo "Third Movie is ${Movies[2]}"

echo "All movies are ${Movies[@]}"


echo "##########################################################################################"

#############################################################################################

echo "List of Arguments passed $@"
echo "Total number of Arguments passed $#"
echo "Present working directory $PWD"
echo "User who is running the current script $0 is $USER"
echo "Home Directory of Current running user $HOME"
echo "Process id of Current Script $$"
sleep 10 &
echo "Process id last executed background process is $!"

echo "##########################################################################################"

dnf list installed mysql

if [ $? -ne 0 ]
then
    echo "ok , mysql not stalled , you need to install in , dont worry we are installing that in this script"
    dnf install mysql -y
    if [ $? -ne 0 ]
    then
        echo " There is something going on here , mysql installation is .. Failure"
        exit 1
    else
        echo " Congratualations , Mysql installation is Successful , you are good proceed"
    fi
else
    echo "Great , mysql is installed and you dont need to do anything"
    
fi

echo "##########################################################################################"