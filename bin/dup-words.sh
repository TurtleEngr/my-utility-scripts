#!/bin/bash

echo Duplicate words found in $*:

perl -ne '
	s/\s+/\n/g;
	s/\n\n+//g;
	print lc;
' <$* | uniq -d | uniq -u
