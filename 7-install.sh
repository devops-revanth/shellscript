#!/bin/bash

USERID=$(id -u)

if [ $USERID -ne 0 ]
then
    echo "ERROR :: You need to have sudo access to run this script"
    exit 1

fi

dnf list installed mysql