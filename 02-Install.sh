#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


echo "User who is running this script is : $USER"

USERID=$(id -u)
if [ $USERID -ne 0]
then
    echo "You need to run this script as sudo or root user"
    exit 1
else
    echo "You are goot to Proceed to run this script"
fi


dnf install mysql -y
