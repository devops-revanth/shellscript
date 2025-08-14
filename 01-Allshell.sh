#!/bin/bash

today=$(date +%A)

if [[ $today == 'Sunday' ]]
then
    echo "$today is Holiday , no need to go to school"
else
    echo "Today is not Sunday , need to go to school"
fi