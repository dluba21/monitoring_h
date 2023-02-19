#!/bin/bash
reg='^[+-]?[0-9]+([.][0-9]+)?$'
if [ $# -eq 1 ]
then
	if [[ $1 =~ $reg ]]
	then
		echo "incorrect: has digit"
	else
		echo $1
	fi
else
echo "incorrect: not one arg"
fi
