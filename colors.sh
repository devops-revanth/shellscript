#!/bin/bash

R="\e[31m"
Y="\e[33m"
G="\e[32m"
N="\e[0m"

Timestamp=$(date +%F)

USERID=$(id -u)

if [ $USERID -ne 0 ]
then
    echo -e "${R}ERROR : $N You need to run the script with sudo privileges"
    exit 1
fi

VALIDATE() {
    if [ $1 -ne 0 ]
    then
    echo -e "$2 .... $R Failure $N"
    else
    echo -e "$2 .... $G Success $N"
    fi
}

dnf list installed mysql &> /dev/null

if [ $? -ne 0 ]
then
    echo -e "${Y}Mysql is not installed , $N Installing now"
    dnf install mysql -y &> /dev/null
    VALIDATE $? "Mysql installation is"
else
    echo -e "${G}Mysql is already installed $N"
fi