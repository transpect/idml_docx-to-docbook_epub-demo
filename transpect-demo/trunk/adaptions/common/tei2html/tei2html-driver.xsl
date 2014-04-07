<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:css="http://www.w3.org/1996/css" 
  xmlns:hub2htm="http://www.le-tex.de/namespace/hub2htm"
  xmlns:tei2html="http://www.le-tex.de/namespace/tei2html"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:html="http://www.w3.org/1999/xhtml" 
  xmlns:hub="http://www.le-tex.de/namespace/hub"
  xmlns="http://www.w3.org/1999/xhtml"  
  exclude-result-prefixes="css dbk xs tei2html hub2htm tei hub html"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="2.0">
  
  <xsl:import href="http://transpect.le-tex.de/tei2html/xslt/tei2html.xsl"/>

  <xsl:template match="@css:font-size" mode="hub2htm:css-style-overrides"/>  

  <xsl:template match="@css:font-family" mode="hub2htm:css-style-overrides"/>  
  
  <xsl:template match="@css:font-weight[. = 'bold']
                                       [ancestor::*[local-name() = ('head', 'h1', 'h2', 'h3', 'h4', 'h5')]]" mode="epub-alternatives"/>
  
  <!-- eventuell auch aus den css:rules rauswerfen -->
  <xsl:template match="tei:head//*/@rend[matches(., '(((s|S)emi)?(b|B)old|(m|M)edium)')]" mode="epub-alternatives">
    <xsl:attribute name="rend" select="replace(., '(((s|S)emi)?(b|B)old|(m|M)edium)', '')"/>
  </xsl:template>
  
  <xsl:template match="css:rules" mode="epub-alternatives"/>
      
  <xsl:template match="tei:text//text()[not(ancestor::*[local-name() = 'table'])]" mode="epub-alternatives">
    <xsl:value-of select="replace(., '&#x00AD;', '')"/>
  </xsl:template>
  
  <xsl:template match="tei:p[matches(@rend, 'p_inhaltsverz')]" mode="epub-alternatives"/>

  <xsl:template match="tei:body" mode="epub-alternatives">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="not(.//divGen[@type = 'toc'])">
        <tei:divGen type="toc" depth="3" xml:id="toc" rend="toc">
          <tei:head>Inhalt</tei:head>
        </tei:divGen>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:variable name="initial-image-regex" select="'o_initialabbildung'" as="xs:string"/>
  <xsl:variable name="poem-style-regex" select="'(G|g)edicht'" as="xs:string"/>
  
  <xsl:template match="html:img[matches(@class, $initial-image-regex)]" mode="clean-up" exclude-result-prefixes="html">
    <span class="initial-img">
      <xsl:sequence select="."/>
    </span>
  </xsl:template>
  
  <xsl:template match="css:rule/@css:font-size" mode="hub2htm:css-style-defs"/>
  
  <xsl:template match="css:rule/@css:font-family" mode="hub2htm:css-style-defs"/>
  
  <xsl:template match="css:rule/@css:text-indent[. = ('0pt', string-join(('-', ../@css:margin-left), ''))]" mode="hub2htm:css-style-defs"/>
  
  <xsl:template match="css:rule/@css:margin-left[string-join(('-', .), '') = (../@css:text-indent, '-0pt')]" mode="hub2htm:css-style-defs"/>
  
  <xsl:template match="css:rule/@css:text-align[. = ('left', 'justify')]" mode="hub2htm:css-style-defs"/>
  
  <xsl:template match="css:rule/@css:text-align-last[../@css:text-align[. = ('left', 'justify')]]" mode="hub2htm:css-style-defs"/>
  
<!--  <xsl:template match="cell/@css:width" mode="hub2htm:css-style-defs"/>-->
  <xsl:template match="cell/@css:padding-left[matches(., '^(\d{2})\d+?.*?(mm|pt)$')]" mode="epub-alternatives">
    <xsl:attribute name="css:padding-left" select="replace(., '^(\d{2})\d+?.*?(mm|pt)$', '$1$2')"/>
  </xsl:template>
  
  <xsl:template match="@css:direction" mode="hub2htm:css-style-defs"/>
  
  <xsl:template match="div[@type eq 'virtual']" mode="tei2html_heading-level" as="xs:integer?">
    <xsl:sequence select="count(ancestor::div[@type = ('chapter', 'section', 'appendix')]) + 2"/>
  </xsl:template>

  <xsl:template match="div[@type eq 'virtual']" mode="tei2html" priority="2">
    <xsl:variable name="heading-level" select="tei2html:heading-level(.)"/>
    <xsl:element name="{concat('h', $heading-level)}">
      <xsl:attribute name="title" select="concat(string-join(tokenize(*[1], '[\s\p{Zs}]+')[position() = (1 to 8)], ' '), '…')"/>
    </xsl:element>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template name="toc">
    <div class="toc">
      <xsl:choose>
        <xsl:when test="exists(* except head)">
          <!-- explicitly rendered toc -->
          <xsl:apply-templates mode="tei2html"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="head" mode="tei2html">
         </xsl:apply-templates>
          <xsl:apply-templates
            select="//head[parent::div[@type = 'section'] | parent::div[@type = 'chapter'] | parent::div[@type = 'appendix'] |
            parent::div[@type = 'part'] | parent::div[@type = 'glossary']]
            [not(ancestor::boxed-text or ancestor::divGen[@type = 'toc'])]
            [not(ancestor::*[1][local-name() = 'div']/preceding-sibling::*[1][local-name() = 'head'][matches(@rend, 'Headline_Autor')])]
            [tei2html:heading-level(.) le number((current()/@rendition, 100)[1]) + 1]"
            mode="toc"/>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>  
  
  <!-- to do: Autor/Titel -->
  <xsl:template match="head" mode="toc" exclude-result-prefixes="#all">
    <p class="toc{tei2html:heading-level(.)}">
      <a href="#{(@id, generate-id())[1]}">
<!--        <xsl:if test="label">
          <xsl:apply-templates select="label/node()" mode="strip-indexterms-etc"/>
          <xsl:text>&#x2002;</xsl:text>
        </xsl:if>-->
        <xsl:choose>
          <xsl:when test="matches(., '^\s*?\d+')">
            <xsl:apply-templates mode="strip-indexterms-etc">
              <xsl:with-param name="in-toc" select="true()" as="xs:boolean" tunnel="yes"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="tei2html">
              <xsl:with-param name="in-toc" select="true()" as="xs:boolean" tunnel="yes"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
          <xsl:if test="matches(@rend, 'Headline_Autor')">
          <br/>
          <xsl:apply-templates select="following-sibling::div[1]/head[1]" mode="strip-indexterms-etc"/>
        </xsl:if>
        <xsl:if test="matches(., '^\s*\d+\s*$')">
          <xsl:variable name="content">
          <xsl:apply-templates select="following-sibling::*[1]" mode="strip-indexterms-etc"/>
          </xsl:variable>
          <xsl:text>&#x2002;</xsl:text>
          <xsl:sequence select="concat(string-join(tokenize($content, '[\s\p{Zs}]+')[position() = (1 to 8)], ' '), '…')"/>
        </xsl:if>
      </a>
    </p>
  </xsl:template>
  
    
  <!-- replaces line breaks with space in heading titles, if there is none before or after -->
  <xsl:template match="head/lb" mode="strip-indexterms-etc tei2html">
    <xsl:choose>
      <xsl:when test="preceding-sibling::node()[1]/(self::text()) and matches(preceding-sibling::node()[1], '\s$') or
                      following-sibling::node()[1]/(self::text()) and matches(following-sibling::node()[1], '^\s')"/>
      <xsl:otherwise>
        <xsl:sequence select="'&#160;'"/>
      </xsl:otherwise>
    </xsl:choose>  
  </xsl:template>
  
  <xsl:template match="head[starts-with(@rend, 'p_h_virtual')]" mode="tei2html"/>
    
  <xsl:template match="head" mode="tei2html" exclude-result-prefixes="#all">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:variable name="level" select="tei2html:heading-level(.)" as="xs:integer?"/>
    <xsl:element name="{if ($level) then concat('h', $level) else 'p'}">
      <xsl:copy-of select="(../@id, ../@xml:id, parent::title-group/../../@id)[1][not($divify-sections = 'yes')]"/>
      <xsl:if test="parent::div[1][@type] or parent::divGen[1][@type]">
        <xsl:attribute name="class" select="(parent::div, parent::divGen)[1]/@type"/>
<!--        <xsl:attribute name="class" select="concat(@rend, ' ', if(parent::div[@type] or parent::divGen[@type]) then ((parent::div, parent::divGen)[1]/@type) else local-name())"/>-->
      </xsl:if>
      <xsl:apply-templates select="@* except @rend" mode="#current"/>
      <xsl:apply-templates select="." mode="class-att"/>
      <!--     <xsl:sequence select="hub2htm:style-overrides(.)"/>-->
      <xsl:variable name="label" select="label"/>
      <xsl:attribute name="title">
        <xsl:if test="$label ne ''">
          <xsl:apply-templates select="$label" mode="strip-indexterms-etc"/>
          <xsl:apply-templates select="$label" mode="label-sep"/>
        </xsl:if>
        <xsl:variable name="stripped" as="text()">
          <xsl:value-of>
            <xsl:apply-templates select="node() except label" mode="strip-indexterms-etc"/>  
            <xsl:if test="../subtitle[matches(., '\S')] or matches($label, '^\d+$')">
              <xsl:text>&#x2002;</xsl:text>
            </xsl:if>
            <xsl:apply-templates select="../subtitle/node()" mode="strip-indexterms-etc"/> 
            <xsl:sequence select="if (not(../subtitle) and matches(., '^\s*\d+\s*$')) then
                (string-join(tokenize(following-sibling::*[1], '[\s\p{Zs}]+')[position() = (1 to 8)], ' '), '…') else ''"
                />
          </xsl:value-of>
        </xsl:variable>
        <xsl:sequence select="replace($stripped, '^[\p{Zs}\s]*(.+?)[\p{Zs}\s]*$', '$1')"/>
      </xsl:attribute>
      <xsl:apply-templates select="label" mode="#current"/>
      <xsl:if test="not($in-toc)">
        <a id="{generate-id()}" />  
      </xsl:if>
      <xsl:apply-templates select="node() except label" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="head/label" mode="tei2html">
    <span class="ziffer">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="html:div[@class = 'pb' and (following-sibling::*[1]/local-name() = ('h1', 'h2', 'h3', 'h4', 'h5') or
    following-sibling::html:div[matches(@class, 'toc')] or
    following-sibling::html:div[matches(@class, 'pb')] or
    ancestor::html:div[matches(@class, 'imprint')] or
    ancestor::html:div[matches(@class, 'poem')]
    )
    ]" mode="clean-up" priority="5"/>
  
  
  <!-- TO DO: Zahlwoerter beandeln, eventuell auch eine regex -->
  <xsl:template match="*[local-name() = ('h1', 'h2', 'h3', 'h4', 'h5')]/text()
                        [matches(., '^\w+er\s+Teil\s*')]" mode="clean-up">
     <span class="ziffer">
       <xsl:sequence select="replace(., '^(\w+er\s+Teil\s*)(.*?)$', '$1')"/>
     </span>    
       <xsl:sequence select="replace(., '^(\w+er\s+Teil\s*)(.*?)$', '$2')"/>
  </xsl:template>
  
  <xsl:template match="@class" mode="clean-up" priority="2">
    <xsl:attribute name="class" select="string-join(tokenize(., '_-_'), ' ')"/>
  </xsl:template>
  
</xsl:stylesheet>