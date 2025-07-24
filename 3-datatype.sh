#!/bin/bash

A=$1
B=$2

Timestamp=$(date)

echo "Script execute at : $Timestamp"

#SUM=$((A + B))
#SUM=$A + $B

SUM=$((A+B))

echo "Sum of $A and $B is $SUM"