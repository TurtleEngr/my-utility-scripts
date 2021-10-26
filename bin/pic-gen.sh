#!/bin/bash
# $Header: /repo/local.cvs/per/bruce/bin/pic-gen.sh,v 1.2 2021/10/26 19:26:11 bruce Exp $

if [ $# -ne 3 ]; then
    cat <<EOF
Usage:
	export cInc=10		# Optional. 1 is default.
	pic-shuffle.sh SuffleFile GenN SetSize
Example:
	pic-gen.sh pic-shuffle-raw1.txt 1 40
This will create:
	pic-shuffle-raw1-gen1.txt    - link raw files to gen1/setN dirs
Execute ./pic-shuffle-raw1-gen1.txt to generate:
	gen1/
		set1/
		set2/
		...
See also:
	pic-shuffle.sh
EOF
    exit 1
fi

# Get options
pShuffleFile=$1
pGen=$2
pSize=$3

# Set config vars
cInc=${cInc:-1}

tGenFile=${pShuffleFile%.*}-gen${pGen}.txt
tSetDir="gen$pGen/set"

# Validate
if [ ! -f $pShuffleFile ]; then
    echo "Error: Missing $pShuffleFile"
    exit 1
fi

s=1
p=1
t=0
rm $tGenFile
echo mkdir -p ${tSetDir}${s} >>$tGenFile

cat $pShuffleFile | while read tPic; do
    let st=p%$pSize
    if [ $st -eq 0 ]; then
        let ++s
        echo mkdir -p ${tSetDir}${s} >>$tGenFile
        t=0
    fi
    let t+=cInc
    tOrder=$(printf "%04d" $t)
    echo ln -f $tPic ${tSetDir}${s}/${tOrder}-${tPic#*/}
    echo ln -f $tPic ${tSetDir}${s}/${tOrder}-${tPic#*/} >>$tGenFile
    let ++p
done

chmod a+rx $tGenFile
echo "If OK, execute $tGenFile to generate linked files in gen$pGen"
