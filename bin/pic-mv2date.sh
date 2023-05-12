#!/bin/bash
# $Header: /repo/per-bruce.cvs/bin/pic-mv2date.sh,v 1.4 2023/03/25 22:21:42 bruce Exp $

# Move (ln) all pic file dir (matching 20*) to a date stamped dir
# Format of files YYYYMMDD_HHMMSS.jpg or YYYY-MM-DD_HHMMSS_NAME.MP4
# (For videos, use vid-rename.sh first)
# If all OK, all files in tofile/ can be removed.

for i in $(find * -prune -type f -name '20*'); do
    d=${i%%_*}
    echo $d | grep -q '-'
    if [ $? -eq 0 ]; then
        mkdir $d 2>/dev/null
        echo ln -i $i $d
        ln -i $i $d
    else
        y=${d%????}
        m=${d#????}
        m=${m%??}
        d=${d#??????}
        mkdir $y-$m-$d 2>/dev/null
        echo ln -i $i $y-$m-$d
        ln -i $i $y-$m-$d
    fi
done
