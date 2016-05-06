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
  
<xsl:template match="/" priority="100">
  <xsl:message terminate="yes"></xsl:message>
</xsl:template>
  
  <!--  *
        * headline hierarchy by style name
        * -->

  <xsl:variable name="hub:hierarchy-role-regexes-x" select="( 
    '^ttl_alt1$',
    '^ttl$',
    '^U1$',
    '^U2$',
    '^U3$',
    '^U4$',
    '^U5$',
    '^U6$',
    '^U7$'
    )" as="xs:string+"/>
    
  <xsl:variable name="hub:hierarchy-title-roles" select="true()" as="xs:boolean"/>  
  
  <!--  *
        * figure and table titles by style name
        * -->

  <xsl:variable name="hub:figure-title-role-regex-x" select="'^grfbschr$'" as="xs:string"/>
  
  <xsl:variable name="hub:table-title-role-regex-x" select="'^hnwU1$'" as="xs:string"/>

  <xsl:variable name="hub:figure-caption-must-begin-with-figure-caption-start-regex" select="false()" as="xs:boolean"/>

  <xsl:variable name="hub:figure-note-role-regex"  as="xs:string" select="'^cAbbLegende$'" />
  
  <!--  *
        * don't generate lists if these style names exist
        *  -->
  
  <xsl:variable name="hub:list-by-indent-exception-role-regex" select="'^Verzeichnis\d$'"/>
  

</xsl:stylesheet>