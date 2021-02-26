# $Header: /repo/local.cvs/per/bruce/bin/index-it.awk,v 1.4 2016/09/01 01:15:41 bruce Exp $

# Usage
#	awk -f index-it.awk [-v gCount=20] <FILE-IN.html >FILE.OUT.html

# Pattern to be replaced with anchors:
# 	"<p>"
#	"<p><a " will not be replaced
#	"<p><!--noid-->" will not be replaced

# Replacement:
#	"<p><a name="id-N" id="id-N" href="#id-N">id-N:</a> "

# To remove the index anchors, so it can be re-indexed, use:
#	index-it-rm.pl

# gCount can be set to the last index number, to continue numbering
# for a file that has additions.  Already indexed p tags will be
# skipped.  So that there are no duplicate ids
#
# For example:
#	tMax=$(index-it-max <FILE-IN.html)
#	awk -f index-it.awk -v gCount=$tMax <FILE-IN.html >FILE-OUT.html

# To use the id links:
# 	Click on the id-N and get the URL.
# 	Cut/paste the URL into a href.
#		- It can be kept absolute.
#		- Or if you are on the same web site, you can remove the
#		  https://host name part, up to the first / after the host name.
#		- Or if you are on the same web page, then all up to the #
# 		  can be removed from the URL.

# ===============================

BEGIN {
	if (gCount == 0) {
		gCount = 0;
	}
	tC = ++gCount;
} # Begin

/<p><a / {
        print $0;
        next;
}

/<p><!--noid-->/ {
        print $0;
        next;
}

/<p>/ {
        gsub("<p>","<p><a name=\"id-" tC "\" id=\"id-" tC "\" href=\"#id-" tC "\">id-" tC ":</a> ");
        ++tC;
}

{
	print $0;
}
