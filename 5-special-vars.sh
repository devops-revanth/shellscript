#!/bin/bash

echo "All variables passed : $@"
echo "Number of variables: $#"
echo "Script Name : $0"
echo "Present working directory :  $PWD"
echo "Home directory of current user : $HOME"
echo "Which user is running this script : $USER"
echo "Process id of curret script : $$"
sleep 60 &
echo "Process id of previous background command : $!"
