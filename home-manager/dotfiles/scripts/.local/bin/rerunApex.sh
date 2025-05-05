#!/bin/bash
if [ -z "$1" ]; then
    echo "No org was given for this script"
    exit 1
fi

if [ -z "$2" ]; then
    echo "No file path for an apex script was given"
    exit 1
fi

if [ -z "$3" ]; then
    echo "No count script was given"
    exit 1
fi
echo "getting starting count"
count=$(sf data query -o $1 -f $3 -w 50 --json | jq '.result.records[0].expr0')
echo $count

re='^[0-9]+$'
if ! [[ $count =~ $re ]] ; then
   echo "Count is not defined" ; exit 1
fi
round=1
while [[ $count -gt 0 ]];  
do
    errorMsg=$(sf apex run -o $1 -f $2 --json | jq -r '.result.exceptionMessage')
    if [ "$errorMsg" = "" ]; then 
        echo "Ran round $round#"
        ((round+=1))
    else 
        echo $errorMsg
        exit 1
    fi
    echo "recounting"
    count=$(sf data query -o $1 -f $3 --json | jq '.result.records[0].expr0')
    echo $count
done
