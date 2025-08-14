#!/bin/bash

# today=$(date +%A)

# if [[ $today == 'Sunday' ]]
# then
#     echo "$today is Holiday , no need to go to school"
# else
#     echo "Today is not Sunday , need to go to school"
# fi


number=$1
if [ $number -gt 100 ]
then
    echo "$number is greater than 100"
else
    echo "$number is less than or equal to 100"

fi