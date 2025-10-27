#!/bin/bash

VALIDATE {

    if [ $1 -ne 0 ]
    then
    echo "$2  failure"
    exit 1
    else
    echo "$2  Success"
    fi
}

USERID=$(id -u)

if [ $USERID -ne 0 ]
then
    echo "ERROR : you need to have sudo privileges to run the script"
    exit 1
fi

dnf list installed mysql

if [ $? -ne 0 ]
then
    echo "Mysql is not installed"
    VALIDATE $? "Mysql is installing"
else
    echo "Mysql is already installed"
fi