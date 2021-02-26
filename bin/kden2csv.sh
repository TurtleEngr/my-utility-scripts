#!/bin/bash
# $Header: /repo/local.cvs/per/bruce/bin/kden2csv.sh,v 1.1 2017/03/08 08:02:34 bruce Exp $

# -------------------
if [ $# -ne 1 ]; then
	cat <<EOF
Usage:
	kden2csv.sh FILE.kdenlive
Input:
	FILE.kdenlive
Output:
	FILE.csv
EOF
	exit 1
fi

pFileIn=$1
if [ ! -w "$pFileIn" ]; then
	echo "Error: could not find, or write to file: $pFileIn"
	exit 1
fi

tFileOut="${pFileIn%.kdenlive}.csv"
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
perl -ne 's/<mlt .*/<mlt>/; print $_;' $pFileIn >t.tmp
mv t.tmp $pFileIn

xsltproc $gBin/kden2csv.xsl $pFileIn >$tFileOut
