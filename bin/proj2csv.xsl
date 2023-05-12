<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:date="http://exslt.org/dates-and-times"
xmlns:exsl="http://exslt.org/common"
extension-element-prefixes="date exsl"
>

<!--
$Header: /repo/per-bruce.cvs/bin/proj2csv.xsl,v 1.3 2023/03/25 22:21:42 bruce Exp $
-->

<xsl:output method="text" indent="no"/>

<xsl:param name="gNL">
    <xsl:value-of disable-output-escaping="yes" select="'&#10;'"/>
</xsl:param>

<xsl:param name="gQ">
    <xsl:value-of disable-output-escaping="yes" select="'&#34;'"/>
</xsl:param>

<xsl:key name="kAssignment" match="/Project/Assignments/Assignment" use="TaskUID"/>
<xsl:key name="kResource" match="/Project/Resources/Resource" use="UID"/>

<xsl:template match="/Project">
"Id","Level","Name","Start","Stop","Days","Dep","Notes"
<xsl:apply-templates select="Tasks/Task"/>
</xsl:template>

<xsl:template match="Task">
  <xsl:value-of select="concat(UID, ',')"/>
  <xsl:value-of select="concat($gQ, OutlineNumber, $gQ, ',')"/>

  <xsl:value-of select="concat($gQ, substring('            ',1,(OutlineLevel - 1)*4))"/>
  <xsl:value-of select="concat(Name, $gQ, ',')"/>

  <xsl:value-of select="concat($gQ, substring(Start, 1, 10), $gQ, ',')"/>
  <xsl:value-of select="concat($gQ, substring(Finish, 1, 10), $gQ, ',')"/>


  <xsl:if test="Milestone = 0">
    <!-- Duration PT24H0M0S -->
    <xsl:variable name='tDuration'>
      <xsl:value-of select="substring-before(substring-after(Duration, 'PT'), 'H')"/>
    </xsl:variable>
    <xsl:value-of select="concat($gQ, $tDuration div 8, $gQ, ',')"/>
  </xsl:if>

  <xsl:if test="Milestone = 1">
    <xsl:value-of select="'0,'"/>
  </xsl:if>

  <xsl:value-of select="$gQ"/>
  <xsl:if test="PredecessorLink">
    <xsl:apply-templates select="PredecessorLink"/>
  </xsl:if>
  <xsl:value-of select="concat($gQ, ',')"/>

  <!-- who -->
<!--
  <xsl:variable name="tA">
    <xsl:value-of select="key('kAssignment', '2')"/>
  </xsl:variable>

  <xsl:variable name="tN">
    <xsl:value-of select="key('kResource', 2)"/>
  </xsl:variable>

  <xsl:value-of select="concat('tA=', $tA/ResourceUID)"/>
  <xsl:value-of select="concat('tN=', $tN/Name)"/>

  <xsl:variable name="tR">
    <xsl:value-of select="$tA/ResourceUID"/>
  </xsl:variable>
  <xsl:variable name="tN">
    <xsl:value-of select="key('kResource', $tR)"/>
  </xsl:variable>
  <xsl:value-of select="concat($gQ, $tN/Name, $gQ, ',')"/>
-->

  <xsl:value-of select="concat($gQ, Notes, $gQ)"/>

  <xsl:value-of select="$gNL"/>
</xsl:template>

<xsl:template match="PredecessorLink">
  <xsl:value-of select="PredecessorUID"/>
  <xsl:if test="Type = '0'">
    <xsl:value-of select="'FF'"/>
  </xsl:if>
  <xsl:value-of select="'; '"/>
</xsl:template>

<!--
XML date/time format:
http://java.sun.com/j2se/1.3/docs/api/java/text/SimpleDateFormat.html
http://www.w3.org/TR/xmlschema-2/#isoformats

yyyy-mm-ddThh:mm:ss.sss+zzz - timezone offset, separators
yyyy/mm/ddThh:mm:ssZ - UTC, alt sep.
yyyymmddThhmmssZ - UTC, no sep.
yyyymmddThhmmss-zzz - timezone offset, no sep.

XML date/time duration format: PnYnMnDTnHnMnS
-->

</xsl:stylesheet>
