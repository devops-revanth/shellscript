#!/bin/bash

# Movies=("RRR" "GameChanger" "Devara")
# 
# echo "First movie is : ${Movies[0]}"
# echo "Second movie is : ${Movies[1]}"
# echo "Third movies is : ${Movies[2]}"
# 
# echo "First movie is : $Movies[1]"
# 
# echo "Now lets see all movies are below"
# 
# echo "All movies list is : ${Movies[@]}"


Course=("Linux" "Shell" "Ansible")

echo "Course First topic is : ${Course[0]}"
echo "Course Second topic is : ${Course[1]}"
echo "Course Third topic is : ${Course[2]}"

Course+=("Git")

echo "Course added , fourth topic is : ${Course[3]}"

echo "All topics are : ${Course[@]}"