#!/bin/bash
# Convert journal files to org mode. Put * before lines with datestamps.
# Usage
#    journal2org <p.tmp >p.org
#
# -*- mode: org -*-

cat <<\EOF >/tmp/tmp.awk
/^* / || /^  * / || /^** / || /^*** / {
	# Skip lines beginning with *
	tDiv=0
	print $0
	next
}
/^20[0-9][0-9]-[0-9][0-9]-[0-9][0-9] */ && ! / UTC / {
	tDiv=0
	print "* " $0
	next
}
/^# 20[0-9][0-9]-[0-9][0-9]-[0-9][0-9] */ && ! / UTC / {
	# 2016-04-17 19:15:38 PDT Sun
	# 2016-04-18 02:15:38 UTC Mon
	tDiv=0
	sub("# ","* ")
	print $0
	next
}
/[0-9][0-9]:[0-9][0-9]:[0-9][0-9] ??? [12][0-9][0-9][0-9]/ {
	# Mon Sep 21 00:04:56 PDT 2015
	tDiv=0
	print "* " $0
	next
}
tDiv && NF {
	tDiv=0
	print "* " $0
	next
}
/^----------/ || /^ ----------/ || /# ----------/ {
	tDiv=1
}
/^==========/ || /^ ==========/ || /# ==========/ {
	tDiv=1
}
{
	print $0
}
EOF

awk -f /tmp/tmp.awk
rm /tmp/tmp.awk
