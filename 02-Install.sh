#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


echo -e "User who is running this script is : $G $USER $N"

USERID=$(id -u)

if [ $USERID -ne 0 ];
then
    echo -e "${R}ERROR $N You need to run this script as sudo or root user"
    exit 1
else
    echo "You are goot to Proceed to run this script"
fi


dnf list installed mysql

if [ $? -ne 0 ];
then
    dnf install mysql -y
    if [ $? -ne 0 ];
    then
        echo -e "Mysql installation is ${R}Failure${N}"
    else
        echo -e "Mysql installation is ${G}Success${N}"
    fi
else
    echo -e "Mysql is already installed ${Y}Skipping${N}"
fi
