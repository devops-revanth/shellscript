#!/bin/bash

echo "All variables passed: $@"
echo "Number of variables passed : $#"
echo "Script Name : $0"
echo "Currect directory : $PWD"
echo "Home directory of current user : $HOME"
echo "The user running the script : $USER"
echo "Process id : $$"

sleep 60 &
echo "Process id of last background command : $!"