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

  <xsl:import href="http://transpect.le-tex.de/evolve-hub/evolve-hub.xsl"/>
  
  <!-- remove model declaration -->
  
  
  <!-- append path to images -->
  
  
  <!-- Roles for hierarchizing (in hierarchy-by-role.xsl): -->

  <xsl:variable name="hub:hierarchy-role-regexes-x" as="xs:string+"
    select="(
    '(   Buchtitel ) (_-_.+)?$',
    '(   Titel ) (_-_.+)?$',    
    '(   berschrift1 ) (_-_.+)?$',
    '( berschrift2 ) (_-_.+)?$',
    '( berschrift3 ) (_-_.+)?$',
    '( berschrift4 ) (_-_.+)?$',
    '( berschrift5 ) (_-_.+)?$',
    '( berschrift6 ) (_-_.+)?$',
    '( berschrift7 ) (_-_.+)?$',
    '( berschrift8 ) (_-_.+)?$',
    '( berschrift9 ) (_-_.+)?$'
    )" />
    
  <xsl:variable name="hub:hierarchy-title-roles" as="xs:boolean" select="true()"/>  
  
  <!-- figure-legends -->

  <xsl:variable name="hub:figure-title-role-regex-x"  as="xs:string"
    select="'^(
    Figure_?title
    | figlegend
    | Figure_Legend
    | Beschriftung
    )$'" />
  
  <xsl:function name="hub:is-empty-para" as="xs:boolean">
    <xsl:param name="elt" as="element(*)"/>
    <xsl:sequence select="matches($elt, '^[\s\p{Zs}]*$')"/>
  </xsl:function>
  
  <!-- No need to dissolve centrally stored formatting --> 
  <xsl:template match="@role" mode="hub:twipsify-lengths">
    <xsl:copy />
    <xsl:apply-templates select="key('hub:style-by-role', .)/@*[name() = ('css:margin-left', 'css:text-indent')]" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="@css:text-indent | @css:margin-left" mode="hub:twipsify-lengths">
    <xsl:attribute name="{local-name()}" select="hub:to-twips(.)" />
  </xsl:template>
  
  <xsl:template match="/*/info" mode="hub:twipsify-lengths">
    <xsl:copy-of select="."/>
  </xsl:template>  
  
  <!-- remove bogus content -->
  <xsl:template match="@docx2hub:*" mode="hub:clean-hub"/>
  
</xsl:stylesheet>