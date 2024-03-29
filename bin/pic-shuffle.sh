#!/bin/bash
# $Header: /repo/per-bruce.cvs/bin/pic-shuffle.sh,v 1.4 2023/03/25 22:21:42 bruce Exp $

if [ $# -ne 2 ]; then
    cat <<EOF
Usage:
        pic-shuffle.sh SuffleFile SrcDir
Example:
        pic-shuffle.sh pic-shuffle-raw1.txt raw1
This will create:
        pic-shuffle-raw1.txt - if not exists, shuffle files in raw1/
See also:
        pic-gen.sh
EOF
    exit 1
fi

# Get options
pShuffleFile=$1
pSrcDir=$2

# Validate
if [ ! -d $pSrcDir ]; then
    echo "Error: expected to see "$pSrcDir" dir. Are you in src/own/images/ ?"
    exit 1
fi

# Reshuffle if file is missing
if [ -f $pShuffleFile ]; then
    echo "$pShuffleFile exists. Doing nothing."
else
    ls $pSrcDir/*.jpg | shuf | shuf | shuf >$pShuffleFile
fi
