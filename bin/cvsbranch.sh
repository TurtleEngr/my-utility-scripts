#!/bin/bash

tHelp=0
if [ $# -lt 2 ]; then
	tHelp=1
else
	if [ ".$1" = ".-h" ]; then
		tHelp=1
	fi
fi

if [ $tHelp -ne 0 ]; then
	cat <<EOF
Usage
	cvsbranch.sh [-h] TAG FILE [FILE...]

Description

	Execute the following:

	cvs tag TAG-BASE FILE
	cvs tag -b TAG-BRANCH FILE
	cvs tag -r TAG-BRANCH FILE
EOF
	exit
fi

pTag=$1
shift
pFile="$*"

pTag=${pTag%-BASE}
pTag=${pTag%-BRANCH}
pTag=${pTag#$LOGNAME-}
pTag=$LOGNAME-$pTag

#case $pTag in
#	$LOGNAME-*)	:;;
#	DEV-*)	:;;
#	PROJ-*)	:;;
#	REL-*)	:;;
#	*)	echo "Error: Invalid tag name"
#		exit
#	;;
#esac

cvs tag $pTag-BASE $pFile
cvs tag -b $pTag-BRANCH $pFile
cvs update -r $pTag-BRANCH $pFile

echo cvs tag $pTag-BASE $pFile
echo cvs tag -b $pTag-BRANCH $pFile
echo cvs update -r $pTag-BRANCH $pFile
