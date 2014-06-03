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
  
  
  <!-- hierarchy by role (overwrite $hub:hierarchy-role-regexes-x) -->

  <xsl:variable name="hub:hierarchy-role-regexes-x" as="xs:string+"
    select="(
    '(  BookTitle
        | Buchtitel ) (_-_.+)?$',
    '(  Title
        | Titel ) (_-_.+)?$',    
    '(  heading1
        | berschrift1 
        | H1 ) (_-_.+)?$',
    '(  heading2
        | berschrift2
        | H2 ) (_-_.+)?$',
    '(  heading3
        | berschrift3 
        | H3 ) (_-_.+)?$',
    '(  heading4
        | berschrift4
        | H4 ) (_-_.+)?$',
    '(  heading5
        | berschrift5
        | H5 ) (_-_.+)?$',
    '(  heading6
        | berschrift6
        | H6 ) (_-_.+)?$',
    '(  heading7
        | berschrift7
        | H7 ) (_-_.+)?$',
    '(  heading8
        | berschrift8
        | H8 ) (_-_.+)?$',
    '(  heading9
        | berschrift9
        | H9 ) (_-_.+)?$'
    )" />
    
  <xsl:variable name="hub:hierarchy-title-roles" as="xs:boolean" select="true()"/>  
  
  <!-- figure-legends -->

  <xsl:variable name="hub:figure-title-role-regex-x"  as="xs:string"
    select="'^(
    Figure_?title
    | figlegend
    | Figure_Legend
    | Beschriftung
    | caption
    )$'" />
  
  <xsl:variable name="hub:table-title-role-regex-x"  as="xs:string"
    select="'^(
    Table_?title
    | tablelegend
    | Table_Legend
    | Beschriftung
    | caption
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

  <!-- show images in html report --><!--
  <xsl:template match="@fileref[matches(., 'container[:]word/')]" mode="hub:clean-hub">
    <xsl:variable name="srcdir" as="xs:string"
      select="tokenize(/*/*:info/*:keywordset[@role eq 'hub']/*:keyword[@role eq 'source-dir-uri'], '/')[. ne ''][last()]"/>
    <xsl:attribute name="fileref" select="concat($srcdir, '/', substring-after(., 'container:'))"/>
  </xsl:template>-->

</xsl:stylesheet>