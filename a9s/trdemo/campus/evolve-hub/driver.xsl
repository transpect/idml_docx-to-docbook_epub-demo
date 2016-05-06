<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:hub="http://transpect.io/hub"
  xpath-default-namespace="http://docbook.org/ns/docbook"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs xlink hub"
  version="2.0">

  <xsl:import href="http://this.transpect.io/a9s/common/evolve-hub/driver.xsl"/>
  

  <!-- variable overrides -->

  <xsl:variable name="hub:hierarchy-role-regexes-x" as="xs:string+"
    select="( '^cUebZwischentitel$',
              '^cUeberschrift1$',
              '^cUeberschrift2$',
              '^cUeberschrift3$',
              '^cUeberschrift4$',
              '^cUeberschrift5$',
              '^cUeberschrift6$',
              '^cUeberschrift7$'
    )" />
    
  <xsl:variable name="hub:hierarchy-title-roles" as="xs:boolean" select="true()"/>  

  <xsl:variable name="hub:list-by-indent-exception-role-regex" select="'^(cUeberschrift|Verzeichnis|GRUNDSCHRIFT)\d$'"/>

  <xsl:variable name="hub:figure-title-role-regex-x"  as="xs:string"
    select="'^cAbbBeschriftung$'" />

  <xsl:variable name="hub:figure-caption-must-begin-with-figure-caption-start-regex"  as="xs:boolean"
    select="false()" />
  
  <xsl:variable name="hub:table-title-role-regex-x"  as="xs:string"
    select="'^cTabBeschriftung$'" />

  <xsl:variable name="hub:figure-note-role-regex"  as="xs:string" select="'^cAbbLegende$'" />
  

  <!-- template overrides/additions -->
  
  <xsl:template match="/hub/info/keywordset[@role eq 'hub']" mode="hub:postprocess-hierarchy">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:element name="keyword">
        <xsl:attribute name="role" select="'assets-dirname'"/>
      </xsl:element>
    </xsl:copy>
  </xsl:template>


</xsl:stylesheet>