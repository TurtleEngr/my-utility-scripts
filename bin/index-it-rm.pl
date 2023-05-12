#!/usr/bin/perl
# $Header: /repo/per-bruce.cvs/bin/index-it-rm.pl,v 1.3 2023/03/25 22:21:41 bruce Exp $

# Usage
#	index-it-rm.pl <FILE-IN.html >FILE.OUT.html

# This script removes the index anchors that are put in the file by index-it

# ===============================

# Unset the input record separator to make <> give you the whole file.
local $/ = undef;

# Read file from stdin
$tFile = <>;

# Remove all index entries made by index-it.sh
# Lots of \s are added so that this work before and after tidy.
# Note: the order of the attributes matter.
$tFile =~ s/
    \<a\s+
        name=\"id-\d+\"\s+
        id=\"id-\d+\"\s+
        href=\"\#id-\d+\"\s*
    \>\s*
        id-\d+\s*
        :?\s*
    \<\/a\>\s*
//gx;

print $tFile;
