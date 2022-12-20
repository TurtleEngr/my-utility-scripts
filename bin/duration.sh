#!/bin/bash

# --------------------
if [ $# -eq 0 ]; then
    cat <<EOF
Usage:
    duration.sh File.mp3 [File.mp4...] >duration.csv

Output duration of video or audio files.
       HH:MM:SS.FF,File
The total time is also output.
EOF
fi

# --------------------
fCalcSec()
{
    # Input: HH:MM:SS.FF
    # Output: S
    local pFmt=$1
    local tH tM tS tF

    tH=${pFmt%%:*}

    tM=${pFmt#*:}
    tM=${tM%:*}

    tS=${pFmt##*:}
    tS=${tS%.*}

    tF=".${pFmt##*.}"

    #echo $pFmt
    #echo $tH $tM $tS $tF

    echo "2 k $tH 60 60 * * $tM 60 * + $tS + $tF + p" | dc
}

# --------------------
fFmtTime()
{
    # Input: S
    # Output: DDd:HH:MM:SS
    local pSec=$1

    echo $pSec | awk '
function fTime(pSec) {
    tDay = int(pSec/60/60/24)
    tHour = int(pSec/60/60) - tDay*24
    tMin = int(pSec/60) - tHour*60 - tDay*24*60
    tSec = pSec - tMin*60 - tHour*60*60 - tDay*24*60*60
    tStr = sprintf("%02dd:%02d:%02d:%02d", tDay, tHour, tMin, tSec)
    return tStr
} # fTime
{ print fTime($0) }
    '
}

# --------------------
tTotalSec="0"
for tFile in $*; do
    if [ ! -f $i ]; then
        continue
    fi
    tDur=$(ffmpeg -i $tFile 2>&1 | grep Duration | awk '{print $2}')
    if [ -z "$tDur" ]; then
        continue
    fi
    tDurSec=$(fCalcSec ${tDur%,})
    #echo $tDurSec
    tTotalSec="$tTotalSec $tDurSec +"
    echo "$tDur$tFile"
done
echo
tTotal=$(echo "$tTotalSec p" | dc)
echo "$tTotal,TotalSec"
tTotalFmt=$(fFmtTime ${tTotal%.*})
echo "$tTotalFmt,Total"
