#!/bin/bash
# $Header: /repo/per-bruce.cvs/bin/pic-resize.sh,v 1.4 2023/03/25 22:21:42 bruce Exp $

if [ $# -ne 3 ]; then
    cat <<EOF
Usage:
        pic-rsize Ratio SrcDir DestDir
EOF
    exit 1
fi

pRatio=$1
pSrc=$2
pDest=$3

if [ ! -d $pSrc ]; then
    echo "Error: missing $pSrc"
    exit 1
fi
if [ ! -d $pDest ]; then
    mkdir $pDest
fi

cd $pSrc
for i in *.jpg; do
    echo
    echo Processing: $pSrc/$i
    tRat=$(jhead $i | grep Resolution | awk '{print int($3/$5)}')
    if [ $tRat -ne 0 ]; then
        ln -vf $i ../$pDest
        continue
    fi
    jhead $i | grep Resolution | awk '{print $0, $3/$5}'
    # x=$3; y=$5
    # x/y=1.35
    # x=1.35 * y
    tSize=$(jhead $i | grep Resolution | awk -v tR=$pRatio '{tX=int(tR * $5); print tX "x" $5}')
    tCmd="convert $i -resize $tSize -background black -gravity center -extent $tSize ../$pDest/$i"
    echo $tCmd
    $tCmd
done
