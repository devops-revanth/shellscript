#!/bin/bash

############################################################
## Author : Revanth Kumar G
## Description : Creating this script to practice basics
############################################################



echo "All variables passed to the script individually : $@"
echo "All variables passed to the script as one string : $*"
echo "Script name : $0"
echo "PID of the script : $$"
echo "PID of last command in background : $!"
echo "exit status : $?"


Movies=("RRR" "KGF" "Bahubali" "Pushpa")

echo " The First Movie in the list is : ${Movies[0]}"
echo " The Second Movie in the list is : ${Movies[1]}"
echo "The Third Movie in the list is : ${Movies[2]}"
echo "The Fourth Movie in the list is : ${Movies[3]}"

AllMovies=${Movies[@]}

echo "All movies in the list are : $AllMovies"

A=("test" "test1" "test2")
for i in "${A[@]}" ; do
    echo $i
done