<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns="http://docbook.org/ns/docbook" 
  xmlns:css="http://www.w3.org/1996/css"
  exclude-result-prefixes="xs cx css"
  xpath-default-namespace="http://docbook.org/ns/docbook"
  version="2.0">
  
  <xsl:template match="processing-instruction()[name() eq 'xml-model']"/>  
  <!-- remove whitespace before root element-->
  <xsl:template match="/text()"/> 
  
  
  <xsl:template match="/hub">
    <!-- xml-models for Docbook 5.0 -->
    <xsl:processing-instruction name="xml-model">href="http://docbook.org/xml/5.0/rng/docbook.rng" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
    <xsl:processing-instruction name="xml-model">href="http://www.le-tex.de/resource/schema/hub/1.1/hub.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
    <!-- rename hub to book element, drop atts except @xml:base -->
    <book version="5.0">
      <xsl:apply-templates select="@xml:base"/>
      <!-- make first section title to book title if only one top-level section exists -->
      <xsl:if test="section[1 and last()]">
        <xsl:apply-templates select="title"/>
      </xsl:if>
      <xsl:apply-templates/>
    </book>
  </xsl:template>
  
  <!-- remove attributes and elements in CSS namespace -->
  <xsl:template match="css:*"/>
  
  <xsl:template match="@css:*"/>  
  
  <!-- remove XPath srcpaths -->
  <xsl:template match="@srcpath"/>
  
  <!-- remove hub prevfix -->
  <xsl:template match="@role[. eq 'hub:identifier']">
    <xsl:attribute name="role" select="'identifier'"/>
  </xsl:template>
  
  <!-- in attributes only NM tokens are permitted, thus convert them to decimal codepoints -->
  <xsl:template match="@mark">
    <xsl:attribute name="mark" select="concat('dec-', string-to-codepoints(.))"/>
  </xsl:template> 
  
  <!-- if only one top-level sections exist, drop it -->
  <xsl:template match="/hub/section[1 and last()]">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="/hub/section[1 and last()]/title"/>

  <!-- convert first sections to chapter, only chapters are allowed as top-level elements in books -->
  <xsl:template match="/hub/section[1 and last()]/section">
    <chapter>
      <xsl:apply-templates select="@*, node()"/>
    </chapter>
  </xsl:template>
  <xsl:template match="/hub/section[not(1 and last())]">
    <chapter>
      <xsl:apply-templates select="@*, node()"/>
    </chapter>
  </xsl:template>
  
  <!-- drop breaks -->
  <xsl:template match="br">
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>
  
  <!-- identity template -->
  <xsl:template match="@*|*">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node() except processing-instruction()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>