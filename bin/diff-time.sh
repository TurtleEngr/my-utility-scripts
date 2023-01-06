#!/bin/bash

if [ $# = 0 ]; then
    cat <<EOF
Usage
        diff-time.sh Begin End
Example:
        diff-time.sh 4:44 9:15
Output:
        4:31
EOF
    exit 1
fi

bMin=${1%:*}
bSec=${1#*:}
eMin=${2%:*}
eSec=${2#*:}

if [ $eSec -lt $bSec ]; then
    let eSec+=60
    let eMin-=1
fi

let dSec=eSec-bSec
let dMin=eMin-bMin
echo "${dMin}:${dSec}"
