<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:hub="http://www.le-tex.de/namespace/hub"
  xpath-default-namespace="http://docbook.org/ns/docbook"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs xlink hub"
  version="2.0">

  <xsl:import href="http://customers.le-tex.de/generic/book-conversion/adaptions/common/evolve-hub/driver.xsl"/>
  
<xsl:template match="/" priority="100">
  <xsl:message terminate="yes"></xsl:message>
</xsl:template>
  <!-- variable overrides -->

  <xsl:variable name="hub:hierarchy-role-regexes-x" as="xs:string+"
    select="( '^ttl_alt1$',
    '^ttl$',
    '^U1$',
              '^U2$',
              '^U3$',
              '^U4$',
              '^U5$',
              '^U6$',
              '^U7$'
    )" />
    
  <xsl:variable name="hub:hierarchy-title-roles" as="xs:boolean" select="true()"/>  

  <xsl:variable name="hub:figure-title-role-regex-x"  as="xs:string"
    select="'^grfbschr$'" />
  
  <xsl:variable name="hub:table-title-role-regex-x"  as="xs:string"
    select="'^hnwU1$'" />

  <xsl:variable name="hub:figure-caption-must-begin-with-figure-caption-start-regex"  as="xs:boolean"
    select="false()" />

  <xsl:variable name="hub:figure-note-role-regex"  as="xs:string" select="'^cAbbLegende$'" />
  

  <!-- template overrides/additions -->

  <!-- remove unecessary markup and output rng/schematron messages only once for this foreign markup -->
  <!--<xsl:template match="phrase[@role eq 'hub:foreign']/*" mode="hub:preprocess-hierarchy">
    <xsl:copy/>
  </xsl:template>-->

</xsl:stylesheet>