#!/bin/bash

if [ $# -eq 0 ]; then
   cat <<EOF
Usage:
    duration.sh File.mp3 File.mp4...

Output duration of video or audio files.
EOF
fi

for i in $*; do
    if [ ! -f $i ]; then
        continue
    fi
    echo -n $i
    ffmpeg -i $i 2>&1 | grep Duration
done |
sed 's/00://; s/\.[0-9]*,//' |
awk '{print $1 "\t" $2,$3}'
