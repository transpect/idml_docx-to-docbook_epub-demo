<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:idml2xml="http://www.le-tex.de/namespace/idml2xml" 
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:css="http://www.w3.org/1996/css" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:hub2htm="http://www.le-tex.de/namespace/hub2htm" 
  xmlns:docx2hub="http://www.le-tex.de/namespace/docx2hub"
  xmlns:letex="http://www.le-tex.de/namespace" 
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://docbook.org/ns/docbook">

  <!--  * This stylesheet is used to transform hub format in XHTML 1.0
        * 
        * Input is expected to be Hub 1.1:
        * http://www.le-tex.de/resource/schema/hub/1.1/hub.rng
        * 
        * Invoke either with inital template or consecutive with inital modes   
        *
        * -->
  
  <xsl:import href="http://transpect.le-tex.de/hub2html/xsl/hub2html.xsl"/>
  
  <xsl:param name="html-title" select="/*:book/*:title"/>
  <xsl:param name="use-css-rules" select="'yes'"/>
  <xsl:param name="generate-toc" select="'yes'"/>
  <xsl:param name="generate-index" select="'yes'"/>
  <xsl:param name="overwrite-image-paths" select="'no'"/>
  <xsl:param name="target" select="'EPUB3'"/>
  
  <xsl:template match="/book/title" mode="hub2htm-default"/>
  
  <xsl:template match="/chapter/title">
    <h1>
      <xsl:apply-templates select="@*, node()" mode="hub2htm-default"/>
    </h1>
  </xsl:template>
  
</xsl:stylesheet>