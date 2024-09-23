#!/usr/bin/env bash
set -u

# ========================================
# Functions

# --------------------------------
fUsage() {
    cat <<EOF
org2html.sh - comvert FILE.org to FILE.html
Usage
    org2html.sh FILE.org FILE.html
EOF
    exit 1
} # fUsage

# ========================================
# Main

cName=org2html.sh

# -------------------
# Get Args Section
if [ $# -ne 2 ]; then
    fUsage
fi
pFileIn=$1
pFileOut=$2
if [[ ! -r $pFileIn ]]; then
    echo "Error: cannot read file: $pFileIn"
    exit 1
fi

# -------------------
# Setup Tmp files
export Tmp=${Tmp:-"/tmp/$USER/$cName"}
if [[ ! -d $Tmp ]]; then
    mkdir -p $Tmp
fi
# Only remove old files. Keep newest files.
find $Tmp -mtime +2 -type f -exec rm {} \;

export cPID=$$
export cTmpF=$Tmp/file-$cPID
cTmp1=${cTmpF}-part1.tmp
cTmp2=${cTmpF}-part2.tmp
cTmp3=${cTmpF}-part3.tmp
cTmp4=${cTmpF}-part4.tmp
cTmpErr=${cTmpF}-part3.err
cPreFix=${cTmpF}-prefix.sed
cPostFix=${cTmpF}-postfix.sed

cTidyHtml="tidy -q -i -w 78 -asxhtml --break-before-br yes --indent-attributes yes --indent-spaces 2 --tidy-mark no --vertical-space no"

cat <<\EOF >$cPreFix
s/^ *- /\n\n/g
s;^\*\*\*\* \(.*\);<h4>\1</h4>;
EOF

cat <<\EOF >$cPostFix
s/\&lt;/\</g
s/\&gt;/>/g
s/<p>\(<blockquote[^>]*>\)/\1<p>/
s;</blockquote></p>;</p></blockquote>;
s/\&quot;/"/g
s;<p></p>;;g
s;<p><div ;<div ;g
s;</div></p>;</div>;g
s;<p><h4>;<h4>;g
s;</h4></p>;</h4>;g
s|<p>&lt;h4&gt;|<h4>|g
s|&lt;/h4&gt;</p>|</h4>|g
s;{\(.\);<cite>{\1;g
s;\(.\)};\1}</cite>;g
s;<h2;<hr><h2;g
EOF

# --------------------
# Functional section

sed -f $cPreFix  <$pFileIn >$cTmp1
pandoc -f org -t html <$cTmp1 >$cTmp2
sed -f /$cPostFix <$cTmp2 >$cTmp3
$cTidyHtml <$cTmp3 >$pFileOut 2>$cTmpErr
sed -i 's|/\*<!\[CDATA\[\*/|| ; s|/\*]]>\*/||' $pFileOut
cat $cTmpErr
echo
echo "If lots of errors, see: $cTmp3 and $cTmpErr"
