#!/bin/bash
# $Id: svn-diff-branch.sh,v 1.3 2015/07/19 03:30:07 bruce Exp $

# ------------------------------
# Config var
cOutFile="$(date '+%F')_diff-report.html"
cTmpFile=/tmp/diff-report.tmp

# ------------------------------
# Get and validate options
if [ $# -ne 2 ]; then
	cat <<EOF
Usage:
	$0 path1 path2

Example:
	cd root1/software
	svn update -r HEAD trunk
	svn update -r 13471 2009-12-09
	svn-diff-branch.sh trunk 2009-12-09
EOF
	exit 1;
fi

pB1=$1
pB2=$2

for i in $pB1 $pB2; do
	if [ ! -d $i ]; then
		echo "Error: $i svn dir not found.";
		exit 1;
	fi
done

# ------------------------------
# Generate report

cat <<EOF >$cOutFile
<html>
<head>
<title>
Branch Difference Report
</title>
</head>
<body>
<h1>
Branch Difference Report
</h1>

<pre>
Date: $(date)
Current Dir: $PWD
Version $pB1: $(svnversion $pB1)
Version $pB2: $(svnversion $pB2)
</pre>

<p>Note: the "db" dir. and files with '~' have been excluded from this
report.

<hr>
<h2>svn status $pB1</h2>
<p>Files with '?' are not in svn.  Maybe that is OK.</p>
<pre>
$(svn status $pB1 | sort -fi)
</pre>

<hr>
<h2>svn status $pB2</h2>
<p>Files with '?' are not in svn.  Maybe that is OK.</p>
<pre>
$(svn status $pB2 | sort -fi)
</pre>

<hr>
<h2>diff between $pB1 and $pB2</h2>
<p>These differences also include keyword differences, for example: URL and
Date. Be sure to pay attention to the "Only" files that are found.</p>
<pre>
EOF

svn status $pB1 | grep '^\?' | awk '{print $2}' | sort -fi >/tmp/svn-diff.tmp
svn status $pB2 | grep '^\?' | awk '{print $2}' | sort -fi >>/tmp/svn-diff.tmp
echo '.svn' >>/tmp/svn-diff.tmp
echo 'db' >>/tmp/svn-diff.tmp
echo 'cache.var' >>/tmp/svn-diff.tmp

# Diff, and clean the output, so that it can be used directly, in a 'cp' cmd
diff -rqw --exclude-from=/tmp/svn-diff.tmp $pB1 $pB2 | \
	egrep -v '~' | \
	sed '
		s/Files /diff /
		s/ and /   /
		s/ differ//
		s/: /\//
	' | \
	sort -fi \
	>$cTmpFile
cat $cTmpFile >>$cOutFile

cat <<EOF >>$cOutFile
</pre>

<hr>
<h2>Removed files that only had "keyword" differences</h2>
<p>Files with only keyword differences, have been excluded from this list.</p>
<pre>
EOF

grep 'diff ' $cTmpFile | while read c1 f1 f2; do
	tKeyWord=$(diff $f1 $f2 |  egrep -v '\$Author: bruce $Date: 2015/07/19 03:30:07 $HeadURL:|\$Id: svn-diff-branch.sh,v 1.3 2015/07/19 03:30:07 bruce Exp $LastChangedBy:|\$LastChangedDate:|\$LastChangedRevision:|\$Rev:|\$Revision|\$URL:|^---$|^[0-9,c]+$' | head -n 1)
	if [ -n "$tKeyWord" ]; then
		echo $c1 $f1 $f2
	fi
done >>$cOutFile

cat <<EOF >>$cOutFile
</pre>

<hr>
<pre>
Generated by: svn-diff-branch.sh
$(date)
</pre>
</body>
</html>
EOF

exit 0
