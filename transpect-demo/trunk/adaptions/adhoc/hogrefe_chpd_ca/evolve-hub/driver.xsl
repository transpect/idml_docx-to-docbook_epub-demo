<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:hub="http://www.le-tex.de/namespace/hub"
  xmlns:docx2hub="http://www.le-tex.de/namespace/docx2hub"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xpath-default-namespace="http://docbook.org/ns/docbook"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs xlink hub"
  version="2.0">

  <xsl:import href="http://customers.le-tex.de/generic/book-conversion/adaptions/common/evolve-hub/driver.xsl"/>
<!--  <xsl:import href="http://transpect.le-tex.de/evolve-hub/evolve-hub.xsl"/> -->
  
  <!-- Roles for hierarchizing (in hierarchy-by-role.xsl): -->
  <!-- MODE: hub:hierarchy -->
  <xsl:variable name="hub:hierarchy-role-regexes-x" as="xs:string+"
    select="'^head$',
            '^head1$',
            '^head2$',
            '^head3$'
            " />

  <xsl:template match="section[@role = 'head']" mode="hub:postprocess-hierarchy">
    <chapter>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </chapter>
  </xsl:template>

  <xsl:template match="section[normalize-space(title) = 'Further Reading']" mode="hub:postprocess-hierarchy">
    <bibliography>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </bibliography>
  </xsl:template>

  <xsl:template match="section[normalize-space(title) = 'Further Reading']/section" mode="hub:postprocess-hierarchy">
    <bibliodiv>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </bibliodiv>
  </xsl:template>

  <xsl:template match="section[normalize-space(title) = 'Further Reading']//para" mode="hub:postprocess-hierarchy">
    <bibliomixed>
      <bibliomisc>
        <xsl:apply-templates select="@*, node()" mode="#current"/>
      </bibliomisc>
    </bibliomixed>
  </xsl:template>

  <xsl:template match="section[normalize-space(title) = 'Further Reading']/section[normalize-space(title) = 'References']/para/@role"
    mode="hub:postprocess-hierarchy" priority="2">
    <xsl:attribute name="{name()}" select="'numberedRef'"/>
  </xsl:template>
  
  <xsl:template match="section[normalize-space(title) = 'Further Reading']//para/@role"
    mode="hub:postprocess-hierarchy">
    <xsl:attribute name="{name()}" select="'additionalRef'"/>
  </xsl:template>
  
  <xsl:template match="@docx2hub:*" mode="hub:clean-hub">
    <xsl:message select="'Discarded attribute style: ' , ."/>
  </xsl:template>
  
  <xsl:template match="@css:*[not(parent::css:rule)]
                             [key('hub:style-by-role', ../@role)/@*[name(.) = name(current()) and (. eq current())]]"
                mode="hub:clean-hub"/>
  
</xsl:stylesheet>