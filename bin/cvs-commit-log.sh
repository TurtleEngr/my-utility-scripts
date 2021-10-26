#!/bin/bash
# $Header: /repo/local.cvs/per/bruce/bin/cvs-commit-log.sh,v 1.2 2021/10/26 19:26:09 bruce Exp $

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
