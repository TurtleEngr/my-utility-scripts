#!/bin/bash
# $Header: /repo/per-bruce.cvs/bin/vid-rename.sh,v 1.5 2023/03/25 22:21:43 bruce Exp $

# Rename video files to names that include the date and time.
# Links are created with the new names, the orignal files are not touched.

# 'ls' -l --time-style=long-iso
# -rwxr-xr-x 1 bruce bruce 23355392 2012-02-21 19:27 mov001.mod
# 1          2 3     4     5        6          7     8

'ls' -l --time-style=long-iso | while read tP tL tU tG tS tD tT tN; do
    if [ -z "$tD" ]; then
        continue
    fi
    if [ "$tN" = "README.txt" ]; then
        continue
    fi
    tT=$(echo $tT | sed 's/[:]/-/g')
    echo ln -i $tN ${tD}_${tT}_$tN
    ln -i $tN ${tD}_${tT}_$tN
done
