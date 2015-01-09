<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns="http://docbook.org/ns/docbook"
  xpath-default-namespace="http://docbook.org/ns/docbook"
  version="2.0">
  
  <!--  *
        * normalize file references of images. The files are copied in the XProc step in "trdemo-patch-and-copy-filerefs.xpl".
        * -->
  
  <xsl:param name="assets-dirname" select="'assets'" as="xs:string"/>
  
  <xsl:template match="imageobject/imagedata/@fileref">
    <xsl:variable name="srcdir" as="xs:string"
      select="tokenize(/*/*:info/*:keywordset[@role eq 'hub']/*:keyword[@role eq 'source-dir-uri'], '/')[. ne ''][last()]"/>
    <xsl:variable name="filename" select="replace(., '^.+/(.+)$', 'assets/$1')" as="xs:string"/>
    <xsl:attribute name="fileref" select="$filename"/>
  </xsl:template>
  
  <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>