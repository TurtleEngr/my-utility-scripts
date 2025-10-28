#!/bin/bash

if [[ $# -eq 0 ]]; then
    cat <<EOF
Usage:
    pic-rename-raw.sh FILE.jpg ...
    Rename one or more FILEs with jhead.
    Format: YYYY-MM-DD_HHMMSS

    The original file names can be found in orig/ dir.
EOF
    exit 1
fi

mkdir orig

for i in $*; do
    file $i | grep -qi 'jpeg image' >/dev/null 2>/dev/null
    if [[ $? -ne 0 ]]; then
        echo $i is not a jpg file.
        continue
    fi
    ln $i orig/
    jhead -ft -n%Y-%m-%d_%H%M%S_%f "$i"
done

#for i in *.jpg; do
#    jhead -v "$i" >$i.txt
#done
