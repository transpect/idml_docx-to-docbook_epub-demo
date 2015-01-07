<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  exclude-result-prefixes="xs"
  version="2.0">
  <!--  *
        * This stylesheet takes an epub-config file and patches some parameters from the paths document.
        * -->
  
  <!--  *
        * Declare the necessary parameters used in the paths file.
        * -->
  <xsl:param name="s9y1-role" as="xs:string?"/>
  <xsl:param name="s9y2-role" as="xs:string?"/>
  <xsl:param name="s9y3-role" as="xs:string?"/>
  <xsl:param name="s9y4-role" as="xs:string?"/>
  <xsl:param name="s9y5-role" as="xs:string?"/>
  <xsl:param name="s9y1" as="xs:string?"/>
  <xsl:param name="s9y2" as="xs:string?"/>
  <xsl:param name="s9y3" as="xs:string?"/>
  <xsl:param name="s9y4" as="xs:string?"/>
  <xsl:param name="s9y5" as="xs:string?"/>
  <!--  *
        * Construct a sequence of each parameter set. Later we can use index-of to get bring them together.
        * -->
  <xsl:variable name="roles" as="xs:string*" select="($s9y1-role, $s9y2-role, $s9y3-role, $s9y4-role, $s9y5-role)"/>
  <xsl:variable name="values" as="xs:string*" select="($s9y1, $s9y2, $s9y3, $s9y4, $s9y5)"/>
  <!--  *
        * Patch the values derived from the filename parts in the epub-config skeleton.
        * -->
  
  <xsl:template match="metadata">
    <xsl:copy>
      <xsl:apply-templates/>
      <dc:date><xsl:value-of select="current-date()"/></dc:date>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="dc:identifier/text()">
    <xsl:value-of select="$values[position() = index-of($roles, 'work')]"/>
  </xsl:template>
   
  <xsl:template match="dc:publisher/text()">
    <xsl:value-of select="$values[position() = index-of($roles, 'publisher')]"/>
  </xsl:template>
  
  <!--  *
        * Identity template
        * -->  
  <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>