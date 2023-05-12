#!/bin/bash
# $Header: /repo/per-bruce.cvs/bin/vid-get-ver.sh,v 1.2 2023/03/25 22:21:43 bruce Exp $

tName=$1
if [ ! -f $tName ]; then
    echo "Error: Missing $tName"
    exit 1
fi
grep $tName CVS/Entries
if [ $? -ne 0 ]; then
    echo "Error: $tName is not versioned"
    exit 1
fi

for tLog in $(cvs log $tName | grep 'revision ' | awk '{print $2}'); do
    cvs update -r $tLog $tName &>/dev/null
    tVer=$(grep kdenliveversion $tName | sed 's;[<>/]; ;g' | awk '{print $3}')
    echo $tLog $tVer
    sleep 1
done
cvs update -A $tName
