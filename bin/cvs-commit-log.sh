#!/bin/bash
# $Header: /repo/per-bruce.cvs/bin/cvs-commit-log.sh,v 1.4 2023/03/25 22:21:41 bruce Exp $

for i in $(find doc src -type f | egrep -v 'CVS|raw|proxy|thumbs|titles'); do
    cvs log $i
done | egrep 'Working file:|date: ' |
    awk '
        /Working / {
                Name = $3
                next
        }
        {
                print $2,$3,$4,Name
        }
' | sort >doc/time.tmp
