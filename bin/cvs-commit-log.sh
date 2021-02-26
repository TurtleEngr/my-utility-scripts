#!/bin/bash
# $Header: /repo/local.cvs/per/bruce/bin/cvs-commit-log.sh,v 1.1 2017/03/08 08:02:34 bruce Exp $

for i in $(find doc src -type f | egrep -v 'CVS|raw|proxy|thumbs|titles'); do
        cvs log $i
done | egrep 'Working file:|date: ' | \
awk '
	/Working / {
		Name = $3
		next
	}
	{
		print $2,$3,$4,Name
	}
' | sort >doc/time.tmp
