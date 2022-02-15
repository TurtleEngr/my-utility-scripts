#!/bin/bash

if [ $# -eq 0 ]; then
    cat <<EOF
Usage
    random.sh pNum pRange
pNum - the number of random number to be genearated
pRange - the largest number (must be 2 to 8000)
EOF
    exit 1
fi

pCount=$1
pRange=$2

if [ $pRange -lt 2 ] || [ $pRange -gt 8000 ]; then
    echo "Error, bad range: $pRange"
    exit 1
fi

let tSize=32767/$pRange
while [ $pCount -gt 0 ]; do
    let --pCount
    echo $((RANDOM / tSize))
done
