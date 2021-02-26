<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:date="http://exslt.org/dates-and-times"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="date exsl">
  <!--
$Header: /repo/local.cvs/per/bruce/bin/proj2html.xsl,v 1.1 2015/07/25 22:23:00 bruce Exp $
-->
  <xsl:output method="html"
              indent="yes" />
  <xsl:param name="gNL">
    <xsl:value-of disable-output-escaping="yes"
                  select="' '" />
  </xsl:param>
  <xsl:param name="gQ">
    <xsl:value-of disable-output-escaping="yes"
                  select="'&quot;'" />
  </xsl:param>
  <xsl:key name="kAssignment"
           match="/Project/Assignments/Assignment"
           use="TaskUID" />
  <xsl:key name="kResource"
           match="/Project/Resources/Resource"
           use="UID" />
  <!-- ********************************* -->
  <xsl:template match="/Project">
    <html>
      <head>
        <title>
          <xsl:value-of select="Title" />
        </title>
      </head>
      <body>
        <h1>
          <xsl:value-of select="Title" />
        </h1>
        <xsl:value-of disable-output-escaping="yes"
                      select="'&lt;ul&gt;'" />
        <xsl:apply-templates select="Tasks/Task" />
        <xsl:value-of disable-output-escaping="yes"
                      select="'&lt;/ul&gt;'" />
      </body>
    </html>
  </xsl:template>
  <!-- ********************************* -->
  <xsl:template match="Task">
    <xsl:value-of disable-output-escaping="yes"
                  select="'&lt;li&gt;'" />
    <xsl:if test="OutlineLevel = 2">
      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;hr/&gt;'" />
    </xsl:if>
    <xsl:value-of disable-output-escaping="yes"
                  select="concat('&lt;h', OutlineLevel, '&gt;')" />
    <xsl:value-of  disable-output-escaping="yes"
                   select="concat(Name, '&lt;br/&gt;')" />
    <xsl:value-of select="concat('Id ', UID)" />
    <xsl:if test="PredecessorLink">
      <xsl:value-of select="' [DepIds: '" />
      <xsl:apply-templates select="PredecessorLink" />
      <xsl:value-of select="']'" />
    </xsl:if>
    <xsl:value-of disable-output-escaping="yes"
                  select="concat(' (Level ', OutlineNumber, ')')" />
    <xsl:value-of disable-output-escaping="yes"
                  select="concat('&lt;/h', OutlineLevel, '&gt;')" />
    <xsl:if test="Milestone = 0">
      <p>
        <xsl:value-of select="concat('Start: ', substring(Start, 1, 10))" />
        <xsl:value-of select="concat(' Stop: ', substring(Finish, 1, 10))" />
        <!-- Duration PT24H0M0S -->
        <xsl:variable name='tDuration'>
          <xsl:value-of select="substring-before(substring-after(Duration, 'PT'), 'H')" />
        </xsl:variable>
        <xsl:value-of select="concat(' Days: ', $tDuration div 8)" />
      </p>
    </xsl:if>
    <xsl:if test="Milestone = 1">
      <p>
        <xsl:value-of select="concat('Milestone: ', substring(Start, 1, 10))" />
      </p>
    </xsl:if>
    <xsl:if test="Notes">
      <p>
        <b>
          <xsl:value-of select="'Notes:'" />
        </b>
      </p>
      <p>
        <xsl:value-of disable-output-escaping="yes"
                      select="Notes" />
      </p>
    </xsl:if>
    <xsl:if test="(OutlineLevel - following-sibling::Task[1]/OutlineLevel) = -1">

      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;ul&gt;'" />
    </xsl:if>
    <xsl:if test="(OutlineLevel - following-sibling::Task[1]/OutlineLevel) = 0">

      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;/li&gt;'" />
    </xsl:if>
    <xsl:if test="(OutlineLevel - following-sibling::Task[1]/OutlineLevel) = 1">

      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;/li&gt;&lt;/ul&gt;&lt;/li&gt;'" />
    </xsl:if>
    <xsl:if test="(OutlineLevel - following-sibling::Task[1]/OutlineLevel) = 2">

      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;/li&gt;&lt;/ul&gt;&lt;/li&gt;'" />
      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;/li&gt;&lt;/ul&gt;&lt;/li&gt;'" />
    </xsl:if>
    <xsl:if test="(OutlineLevel - following-sibling::Task[1]/OutlineLevel) = 3">

      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;/li&gt;&lt;/ul&gt;&lt;/li&gt;'" />
      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;/li&gt;&lt;/ul&gt;&lt;/li&gt;'" />
      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;/li&gt;&lt;/ul&gt;&lt;/li&gt;'" />
    </xsl:if>
    <xsl:if test="(OutlineLevel - following-sibling::Task[1]/OutlineLevel) = 4">

      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;/li&gt;&lt;/ul&gt;&lt;/li&gt;'" />
      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;/li&gt;&lt;/ul&gt;&lt;/li&gt;'" />
      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;/li&gt;&lt;/ul&gt;&lt;/li&gt;'" />
      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;/li&gt;&lt;/ul&gt;&lt;/li&gt;'" />
    </xsl:if>
    <xsl:if test="(OutlineLevel - following-sibling::Task[1]/OutlineLevel) = 5">

      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;/li&gt;&lt;/ul&gt;&lt;/li&gt;'" />
      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;/li&gt;&lt;/ul&gt;&lt;/li&gt;'" />
      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;/li&gt;&lt;/ul&gt;&lt;/li&gt;'" />
      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;/li&gt;&lt;/ul&gt;&lt;/li&gt;'" />
      <xsl:value-of disable-output-escaping="yes"
                    select="'&lt;/li&gt;&lt;/ul&gt;&lt;/li&gt;'" />
    </xsl:if>
  </xsl:template>
  <!-- ********************************* -->
  <xsl:template match="PredecessorLink">
    <xsl:value-of select="PredecessorUID" />
    <xsl:if test="Type = '0'">
      <xsl:value-of select="'FF'" />
    </xsl:if>
    <xsl:value-of select="'; '" />
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
