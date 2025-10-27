#!/bin/bash


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USERID=$(id -u)

CHECKROOT() {

    if [ $USERID -ne 0 ]
    then
        echo -e "${R}ERROR: ${N} You need to run this script with Sudo privileges"
        exit 1
    fi 
}

CHECKROOT

VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .... ${R} Failure ${N}"
        exit 1
    else
        echo -e "$2 .... ${G} Success ${N}"
}


dnf list installed mysql-server

if [ $? -ne 0 ]
then
    echo -e "${Y}Mysql is not installed , ${N}Installing now"
    dnf install mysql-server -y &>/dev/null
    VALIDATE $? "Mysql installation is"

    systemctl start mysqld &>/dev/null
    VALIDATE $? "Mysqld service starting is"

    systemctl enable mysqld &>/dev/null
    VALIDATE $? "Mysqld service enabled is"
else
    echo -e "${G}Mysql already installed"
fi