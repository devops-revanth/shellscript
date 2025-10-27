#!/bin/bash

USERID=$(id -u)

if [ $USERID -ne 0 ] then
    echo " Error : You must have sudo privileges to run this script."
    exit 1
fi

dnf list installed | grep -i mysql-server

if [ $? -ne 0 ]
then
    echo "Mysql server is not installed on the system"
    dnf install -y mysql-server
    if [ $? -ne 0 ]
    then
    echo "Mysql installation is failure"
    exit 1
    else
    echo "Mysql installation is success"
    fi
else
    echo "Mysql is already installed"
fi


dnf list installed git

if [ $? -ne 0 ]
then
    echo "git is not installed , we will proceed with installation now"
    dnf install git -y
    if [ $? -ne 0 ]
    then
    echo "Git installation is failure"
    exit 1
    else
    echo "Git installation is successful"
    fi
else
    echo "git is already installed"
fi