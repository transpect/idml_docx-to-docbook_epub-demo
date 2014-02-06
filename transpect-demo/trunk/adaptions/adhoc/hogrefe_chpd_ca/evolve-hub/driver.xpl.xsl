<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:template name="main">
    <xsl:apply-templates select="document('http://customers.le-tex.de/generic/book-conversion/adaptions/common/evolve-hub/driver.xpl')"/>
  </xsl:template>

  <xsl:template match="@* | *">
    <xsl:copy copy-namespaces="yes">
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*:xslt-mode[matches(@mode, '(split|figure|complex|preprocess-hierarchy|right-tab)')]"/>
    
</xsl:stylesheet>