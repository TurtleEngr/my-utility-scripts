#!/bin/bash
# $Header: /repo/local.cvs/per/bruce/bin/pic-review.sh,v 1.1 2018/04/27 16:59:32 bruce Exp $

# Review pic found in date stamped dirs.
# Files already reviewed are put in reviewed.txt
# CR - next, do nothing
# d - delete current (move to trash/)
# p - delete previous (move to trash/)
# q - quit

mkdir trash 2>/dev/null
for i in 20*/*.jpg 20*/*/png; do
    if grep -q $i reviewed.txt; then
	continue
    fi
    echo $i
    eog $i >/dev/null 2>&1 &
    e=$!
    echo $e
    read -n 1 -p "p-prev, d-del, q-quit ? "
    if [ "$REPLY" = "p" ]; then
	echo mv $tPrev trash
	mv $tPrev trash
    fi    
    if [ "$REPLY" = "d" ]; then
	echo mv $i trash
	mv $i trash
    fi
    kill $e >/dev/null 2>&1
    if [ "$REPLY" = "q" ]; then
	exit 0
    fi
    echo $i >>reviewed.txt
    tPrev=$i
done
