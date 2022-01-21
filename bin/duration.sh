#!/bin/bash

if [ $# -eq 0 ]; then
   cat <<EOF
Usage:
    duration.sh File.mp3 File.mp4... >duration.csv

Output duration of video or audio files.

HH:MM:SS.FF,File
EOF
fi

for tFile in $*; do
    if [ ! -f $i ]; then
        continue
    fi
    tDur=$(ffmpeg -i $tFile 2>&1 | grep Duration | awk '{print $2}')
    echo "$tDur$tFile"
done
