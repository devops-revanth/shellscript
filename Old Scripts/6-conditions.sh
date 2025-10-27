#!/bin/bash

A=$1

if [ $A -gt 100 ]
then
    echo "Entered number is greater than 100"
else
    echo "Entered number is less than or equal to 100"
fi