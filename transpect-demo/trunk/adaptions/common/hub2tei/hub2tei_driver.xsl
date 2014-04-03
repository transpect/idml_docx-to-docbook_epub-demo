<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:hub="http://www.le-tex.de/namespace/hub"
  xmlns:hub2tei="http://www.le-tex.de/namespace/hub2tei"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="dbk hub2tei hub xlink css xs letex cx"
  version="2.0">
  
  <xsl:import href="http://transpect.le-tex.de/hub2tei/xsl/hub2tei.xsl"/>
  <xsl:param name="work-path"/>
  
  <!-- virtual units: when there is no heading -->
  <xsl:template match="*[name() = ('part', 'chapter', 'section', 'appendix')][matches(dbk:title/@role, 'virtual')][matches(dbk:title, '^\s*$')]" mode="hub2tei:dbk2tei">
    <div type="{concat('virtual-', name())}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="dbk:toc" mode="hub2tei:dbk2tei">
    <divGen type="toc">
      <xsl:apply-templates select="." mode="toc-depth"/>
      <xsl:apply-templates select="dbk:title" mode="#current"/>
    </divGen>
  </xsl:template>
  
  <xsl:template match="dbk:toc" mode="toc-depth">
    <xsl:attribute name="rendition" select="'3'"/>
  </xsl:template>
  
  <xsl:template match="dbk:title" mode="hub2tei:dbk2tei">
    <head>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </head>
  </xsl:template>
  
  <xsl:template match="dbk:index" mode="hub2tei:dbk2tei">
    <divGen type="index">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </divGen>
  </xsl:template>
  
  <xsl:template match="*[name() = ('part', 'chapter', 'section', 'appendix')][matches(dbk:title/@role, 'virtual')]/dbk:title[matches(., '^\s*$')]" mode="hub2tei:dbk2tei"/>

  <xsl:variable name="basic-style-regex" select="'(
                                              ^(0|_)?1_Impressum
                                              |(0|_)?3_Grund(schrift|text)
                                              |(0|_)?(4|5)_Anhang
                                              )
                                              (_Einschub)?(_-_.+)?$'"  as="xs:string"/>
  
  <xsl:variable name="caption-style-regex" select="'(Bildlegende|abbildung_legende|p_legende)'"  as="xs:string"/> 
  <xsl:variable name="poem-style-regex" select="'((g|G)edicht)'"  as="xs:string"/>
  
  <xsl:template match="@role[matches(., $basic-style-regex)]" mode="hub2tei:dbk2tei">
    <xsl:variable name="modifiers" as="xs:string*">
      <xsl:if test="matches(., '_-_noindent')">
        <xsl:sequence select="'noindent'"/>
      </xsl:if>
      <xsl:if test="matches(., '_-_top')">
        <xsl:sequence select="'top'"/>
      </xsl:if>
    </xsl:variable>
    <xsl:if test="exists($modifiers)">
      <xsl:attribute name="rend" select="$modifiers"/>  
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="dbk:para[matches(@role, $poem-style-regex)]" mode="hub2tei:dbk2tei">
    <l>
      <xsl:apply-templates select="@*" mode="hub2tei:dbk2tei"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </l>
  </xsl:template>
  
  <xsl:template match="mediaobject[imageobject/imagedata/@fileref] | inlinemediaobject[imageobject/imagedata/@fileref]" mode="hub2tei:dbk2tei" 
    xpath-default-namespace="http://docbook.org/ns/docbook">
      <graphic>
        <xsl:attribute name="url" select="if (/hub/info/keywordset/keyword[@role eq 'source-type'] eq 'docx') then .//@fileref else letex:image-path(.//@fileref)"/>
        <xsl:if test="imageobject/imagedata/@width">
          <xsl:attribute name="width" select="if (matches(imageobject/imagedata/@width,'^\.')) then replace(imageobject/imagedata/@width,'^\.','0.') else imageobject/imagedata/@width"/>
        </xsl:if>
        <xsl:if test="imageobject/imagedata/@depth">
          <xsl:attribute name="height" select="if (matches(imageobject/imagedata/@depth,'[0-9]$')) then string-join((imageobject/imagedata/@depth,'pt'),'') else imageobject/imagedata/@depth"/>
        </xsl:if>
        <xsl:if test="./@role">
          <xsl:attribute name="rend" select="@role"/>
        </xsl:if>
      </graphic>
  </xsl:template>
  
 <xsl:function name="letex:image-path" as="xs:string">
   <xsl:param name="path" as="xs:string"/>
       <xsl:variable name="image-path" select="string-join(
         (
         $work-path,
         'images/',
         replace(($path)[1], '^.*?/([^/]+)$', '$1')
         ),
         '')" as="xs:string"/>
       <xsl:sequence select="if (not(matches($image-path, '_png\.'))) 
         then replace($image-path, '\.(tiff?|ai|pdf)$', '.jpg') 
         else replace($image-path, '_png\.(tiff?$|ai|pdf)$', '.png')"/>
 </xsl:function>
   

  <xsl:template match="dbk:chapter[dbk:title[matches(., 'Inhalt')]]" mode="hub2tei:dbk2tei"/>
  
  <xsl:template match="dbk:figure/dbk:title[dbk:phrase[@role = 'hub:caption-text']]" mode="hub2tei:dbk2tei" priority="2"/>
   
  <!-- preliminary? -->
  <xsl:template match="dbk:sidebar" mode="hub2tei:dbk2tei">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="@url[matches(., 'file:')]" mode="hub2tei:tidy hub2tei:dbk2tei">
    <xsl:attribute name="url" select="replace(., '^file:(\w)', 'file:/$1')"/>
  </xsl:template>  

  <xsl:template match="tei:seg[every $a in @* satisfies (name($a) = 'srcpath')]" mode="hub2tei:tidy">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
 <xsl:template match="dbk:indexterm" mode="hub2tei:dbk2tei">
    <index rend="index">
      <term>
        <xsl:apply-templates select="@*, node()" mode="#current"/>
      </term>
    </index>
  </xsl:template>
 
  <xsl:template match="dbk:primary | dbk:secondary" mode="hub2tei:dbk2tei">
      <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
    
</xsl:stylesheet>