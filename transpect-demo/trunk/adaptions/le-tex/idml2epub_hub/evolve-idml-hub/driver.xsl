<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:hub="http://www.le-tex.de/namespace/hub"
  xmlns:docx2hub="http://www.le-tex.de/namespace/docx2hub"
  xpath-default-namespace="http://docbook.org/ns/docbook"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs xlink hub"
  version="2.0">

  <!--<xsl:import href="http://transpect.le-tex.de/adaptions/common/evolve-hub/driver.xsl"/>-->
  <!--<xsl:import href="https://subversion.le-tex.de/common/transpect-demo/trunk/adaptions/common/evolve-hub/"/>-->
  
  <xsl:template match="phrase[@condition='storytitle']"/>
    
  
  <xsl:template match="sidebar">
    <!--        <xsl:value-of select="."/>-->
    <xsl:text>,</xsl:text>
    
  </xsl:template>



</xsl:stylesheet>
