#!/bin/bash
# $Header: /repo/local.cvs/per/bruce/bin/make-link.sh,v 1.5 2020/10/28 02:14:26 bruce Exp $

if [ $# -ne 0 ]; then
	cat <<EOF
Usage:
	make-link.sh <InFile.dat >OutFile.html

--------------------
Syntax for InFile:

# comments start with a #,
	comments and blank lines are ignored

Start
	start a link record

D [YYYY-MM-DD]
	Default: Today
	
L [Link]
	Full URL.  Required
	
T [Title]
	URL title, all on one line. Required
	
S [N]
	Number of stars. Default: 1

Type [TYPE]
	Follow by one of:
		video, ted, article, site, tool, book, podcast, product
	Default: site
	video, if youtube in link
	ted, if ted in link or in title
	book, if amazon.com in link
	article, if nytimes.com in link

Tag [Name, Name, ...]

Cite [Name]

DD
	Start a DD section. Must be last, if used.
	Can, and should include html.
	
	# Create links with AL, AT
	AL https://www.youtube.com/watch?v=Snn1k_qEx20
	AT Grand tour of the International Space Station with Drew and Luca
End
	End a record. Required

DONE
	Stop processing the rest of the file.

--------------------
# Note: you should put the records into reverse date order (newest first).

# A link definition example
Start
D 2020-07-02
L https://www.youtube.com/watch?v=QvTmdIhYnes
T ONE OF THE MOST DETAILED ISS TOUR!!! - May 21, 2016
Tag science, space
Cite nasa
S 2
DD
<p>Another tour:
AL https://www.youtube.com/watch?v=Snn1k_qEx20
AT Grand tour of the International Space Station with Drew and Luca
</p>
End

--------------------
When done, look for ERROR in OutFile.html.

tidyxhtml OutFile.html

	alias tidyxhtml='tidy -m -q -i -w 78 -asxhtml --break-before-br yes --indent-attributes yes --indent-spaces 2 --tidy-mark no --vertical-space no'

firefox OutFile.html

If it looks OK, then cut paste the <dt> sections to the top of the <dl> list.

EOF
	exit 1
fi

# ==================================

# --------------------
cDate="$(date +%F)"
cTime="$(date +%H-%M-%S)"

# --------------------
cat <<\EOF >/tmp/make-link.awk

/^#/ { next }

NF == 0 { next }

/DONE/ { exit }

/^[Ss]tart$/ {
	tDate = pDate
	tTime = pTime
	tLink = "ERROR"
	tTitle = "ERROR"
	tStar = 1
	tType = "site"
	tTag = ""
	tCite = ""
	tDDTitle = ""
	tDDLink = ""
	print("<dt>")
	tInLink = 0
	next
}

/^[Dd]ate / || /^D / {
	$1 = ""
	sub(/^ /,"",$0)
	tDate = $0
	next
}

/^[Ll]ink / || /^L / {
	$1 = ""
	sub(/^ /,"",$0)
	tLink = $0
	if (match(tLink,/youtube.com/)) {
		tType = "video"
	}
	if (match(tLink,/youtu.be/)) {
		tType = "video"
	}
	if (match(tLink,/ted/)) {
		tType = "video"
	}
	if (match(tLink,/amazon.com/)) {
		tType = "book"
	}
	next
}

/^[Tt]itle / || /^T / {
	$1 = ""
	sub(/^ /,"",$0)
	tTitle = $0
	if (match(tTitle,/[Tt][Ee][Dd]/)) {
		tType = "ted"
	}
	next
}

/^[Ss]tar / || /^S / {
	$1 = ""
	sub(/^ /,"",$0)
	tStar = $0
	next
}

/^[Tt]ype/ || /^TY / {
	$1 = ""
	sub(/^ /,"",$0)
	tType = $0
	next
}

/^[Tt]ag / {
	$1 = ""
	sub(/^ /,"",$0)
	tTag = $0
	next
}

/^[Cc]ite / {
	$1 = ""
	sub(/^ /,"",$0)
	tCite = $0
	next
}

/^ALink / || /^AL / {
	$1 = ""
	sub(/^ /,"",$0)
	tDDLink = $0
	tDDTitle = ""
	next
}

/^ATitle / || /^AT / {
	$1 = ""
	sub(/^ /,"",$0)
	tDDTitle = $0
	print("<a href=\"" tDDLink "\" target=\"_blank\">" tDDTitle "</a>")
	tDDLink = ""
	tDDTitle = ""
	next
}

/^DD/ {
	tInLink = 1
	tDateId = tDate "_" tTime "_" ++N
	print("<a name=\"" tDateId "\"")
	print("id=\"" tDateId "\"")
	print("href=\"#" tDateId "\">")
	print(tDate)
	print("</a> - <a href=\"" tLink "\" target=\"_blank\">")
	print(tTitle)
	print("</a> - " tType)
	for (i=1; i<=tStar; ++i) {
		print("<img src=\"image/star2.jpg\" alt=\"star\"/>")
	}
	print("</dt>")
	print("<dd>")
	if (tTag != "") {
		print("<p><b>Tag:</b>", tTag, "</p>")
	}
	if (tCite != "") {
		print("<p><b>CiteTag:</b>", tCite, "</p>")
	}
	next
}

/^[Ee]nd$/ {
	print("</dd>")
	print("")

	if (! tInLink) {
		print("ERROR: DD not found, above line:", FNR)
	}
	tInLink = 0
	next
}

tInLink {
	print($0)
	next
}

{
	print("ERROR: on line: " FNR, $0)
}
EOF

# --------------------
# Header
cat <<EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>gen-link output</title>
  <style type="text/css">
  <!--
  /*<![CDATA[*/
  body {
        margin-left: 2%;
        margin-right: 5%;
        font-family: Times, serif;
  }
  pre {
        font-size: 90%;
        line-height: 100%;
        font-family: Courier, serif;
  }
  dt {
        font-weight: bold
  }
  dd {
        margin-left: 10%;
  }
  /*]]>*/
  // -->
  </style>
</head>
<body>
<dl>
EOF

# --------------------
awk -v pDate=$cDate -v pTime=$cTime  -f /tmp/make-link.awk

# --------------------
# Footer
cat <<EOF
</dl>
</body>
</html>
EOF
