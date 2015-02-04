<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:hub="http://www.le-tex.de/namespace/hub"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs cx css hub"
  xpath-default-namespace="http://docbook.org/ns/docbook"
  version="2.0">
  
  <xsl:import href="http://transpect.le-tex.de/hub2dbk/xsl/hub2dbk.xsl"/>
  
  <xsl:template match="/hub">
    <xsl:processing-instruction name="xml-model">href="http://docbook.org/xml/5.0/rng/docbook.rng" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
    <book version="5.0">
      <xsl:choose>
        <xsl:when test="section[1]/title">
          <xsl:apply-templates select="section[1]/title"/>
        </xsl:when>
        <xsl:otherwise>
          <title></title>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates/>
    </book>
  </xsl:template>
  
  <xsl:template match="hub/info"/>
  
  <xsl:template match="hub/section">
    <chapter>
      <xsl:apply-templates select="@*, node()"/>
    </chapter>
  </xsl:template>
  
</xsl:stylesheet>