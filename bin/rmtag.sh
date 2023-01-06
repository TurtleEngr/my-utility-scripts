#!/bin/bash

if [ $# -ne 3 -a $# -ne 1 ]; then
    cat <<EOF
Usage:
        rmtag.sh TAG INFILE OUTFILE
        rmtag.sh TAG <INFILE >OUTFILE
EOF
fi

tmp=/tmp/rmtag.$$

pRmTag=$1

if [ $# -eq 3 ]; then
    pInFile=$2
    pOutFile=$3
else
    pInFile=$tmp.in
    pOutFile=$tmp.out
    cat >$pInFile
fi

cat <<EOF >$tmp.rmtag.xsl
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
<!--
Usage:
        xsltproc -o OUTFILE /tmp/rm-tag.xsl INFILE
-->

<xsl:param name="rmtag" select="hide"/>

<xsl:output method="xml" indent="yes"/>

<xsl:template match="$pRmTag"/>

<!-- Copy anything else matched -->
<xsl:template match="/ | node() | @* | comment() | processing-instruction()">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
EOF

xsltproc -o $pOutFile $tmp.rmtag.xsl $pInFile

if [ $# -eq 1 ]; then
    cat $pOutFile
fi

rm $tmp.*
