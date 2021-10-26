#!/bin/bash
# $Header: /repo/local.cvs/per/bruce/bin/show-vlc-record.sh,v 1.2 2021/10/26 19:26:12 bruce Exp $

# Start vlc, If recording it will be put in $HOME dir.
# This will show the last recorded file. If the number changes, a new line
# will be output.

tLastSize=0

tLineB=""
tSizeB=0
tNameB=""
tSecB=0

tSize=0
tLastSize=0

while true; do
    tLineE=$(ls -ltr $HOME/vlc-record* | tail -n 1 | awk '{print $5, $9}')
    tSizeE=${tLineE% *}
    tNameE=${tLineE#* }
    tSecE=$(date '+%s')

    if [ "$tNameE" != "$tNameB" ]; then
        echo "New: $tNameE"
        tNameB=$tNameE
        tSizeB=$tSizeE
        tStart=$tSizeE
        tLastSize=0
        tSecB=$(date '+%s')
    fi

    let tSize=tSizeE-tSizeB
    if [ $tSize -gt $tLastSize ]; then
        tLastSize=$tSize
        let tTotal=tSecE-tSecB
        echo $tTotal $tNameE
    fi

    sleep 5
done
