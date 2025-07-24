#!/bin/bash

USERID=$(id -u)

if [ $USERID -ne 0 ]
then
    echo "ERROR :: You need to have sudo access to run this script"
    exit 1

fi

dnf list installed mysql

if [ $? -ne 0 ]
then
    dny install mysql -y
    if [ $? -ne 0 ]
    then
        echo "Installing MYSQL ...... FAILURE "
        exit 1
    else
        echo "Installing MYSQL ...... SUCCESS "
    fi
else
    echo "MYSQL is already ...... INSTALLED "
fi
