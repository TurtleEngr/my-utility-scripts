#!/bin/bash
# $Header: /repo/local.cvs/per/bruce/bin/timelog.sh,v 1.4 2021/10/26 19:26:12 bruce Exp $

# --------------------
if [ $# -ne 1 -o "x$1" = "x-h" ]; then
    cat <<EOF
Usage
	timelog.sh logtime.csv
Description
	Generate a summary report from logtime.csv file.
Input:
	YYYY-MM-DD,HH:MM:SS,TZ,Sec,Host,PWD,text
Output:
	YYYY-MM-DD,HH:MM:SS,Nd:Nh:Nm,text (diff to previous)
	YYYY-MM-DD,Nh:Nm,Day Total
See also:
	logtime
EOF
    exit 1
fi

# --------------------
pFile=$1

if [ ! -f $pFile ]; then
    echo "Error: could not find $pFile"
    exit 1
fi

# --------------------
cat $pFile | awk -F, '
NF == 0 { next }
/^#/ {
	print $0
	next
}
NR == 1 {
	tPrevDay = $1
	tPrevTime = $2
	tPrevSec = $4
	tTotal = 0
	printf "%s,%s,Begin,%d\n", tPrevDay,tPrevTime,tPrevSec
	next
}
{
	if ($1 != tPrevDay) {
		# Output total for the previous day
		tDay = int(tTotal/60/60/24)
		tHour = int(tTotal/60/60) - tDay*24
		tMin = int(tTotal/60) - tDay*24*60 - tHour*60
		printf "%s,%02dd:%02dh:%02dm,%s\n", tPrevDay, tDay, tHour, tMin, "Total"
		printf "%s,%s,End,%d\n", tPrevDay,tPrevTime,tPrevSec
		print " "
		printf "%s,%s,Begin,%d\n", $1, $2,$4
		tPrevDay = $1
		tPrevTime = $2
		tPrevSec = $4
		tTotal = 0
		next
	}

	tDiff = $4 - tPrevSec
	tDay = int(tDiff/60/60/24)
	tHour = int(tDiff/60/60) - tDay*24
	tMin = int(tDiff/60) - tDay*24*60 - tHour*60
#	tSec = int(tDiff) - tDay*24*60*60 - tHour*60*60 - tMin*60

#	print $1, tDay "d:" tHour "h:" tMin "m", $7
	printf "%s,%02dd:%02dh:%02dm,%s\n", $1, tDay, tHour, tMin, $7

	tPrevDay = $1
	tPrevTime = $2
	tPrevSec = $4
	tTotal += tDiff
}
'
