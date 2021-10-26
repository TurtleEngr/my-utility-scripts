#!/bin/bash
# $Header: /repo/local.cvs/per/bruce/bin/proj2csv.sh,v 1.3 2021/10/26 19:26:11 bruce Exp $

# -------------------
if [ $# -ne 1 ]; then
    cat <<EOF
Usage:
	proj2csv.sh OPEN_PROJ_FILE.xml
Input:
	OPEN_PROJ_FILE.xml - Microsoft Project xml file
Output:
	OPEN_PROJ_FILE.csv
EOF
    exit 1
fi

pFileIn=$1
if [ ! -w "$pFileIn" ]; then
    echo "Error: could not find, or write to file: $pFileIn"
    exit 1
fi

tFileOut="${pFileIn%.xml}.csv"
touch $tFileOut
if [ ! -w $tFileOut ]; then
    echo "Error: could not write to file: $tFileOut"
    exit 1
fi

# -------------------
# Define the location of the script
export gCurDir=$PWD
if [ $0 = ${0%/*} ]; then
    gBin=$(whence $gName)
    gBin=${gBin%/*}
else
    gBin=${0%/*}
fi
cd $gBin
export gBin=$PWD
cd $gCurDir

# -------------------
# Fix up the file so it works with xsltproc
perl -ne 's/<Project .*/<Project>/; print $_;' $pFileIn >t.tmp
mv t.tmp $pFileIn

xsltproc $gBin/proj2csv.xsl $pFileIn >$tFileOut
