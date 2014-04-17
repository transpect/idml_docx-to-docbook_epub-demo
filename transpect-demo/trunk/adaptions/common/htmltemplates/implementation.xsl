<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:html="http://www.w3.org/1999/xhtml" 
  xmlns:uv="http://unionsverlag.com/namespace" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="xs uv" 
  version="2.0">

  <xsl:variable name="metadata" as="document-node()" select="collection()[1]"/>
  <xsl:variable name="htmlinput" as="document-node(element(html:html))+" select="collection()[position() gt 1]"/>
  <xsl:param name="work" as="xs:string"/>


  <xsl:template name="main">
    <html>
      <head>
        <xsl:call-template name="htmltitle"/>
        <xsl:apply-templates select="$htmlinput[1]/html:html/html:head/node() except $htmlinput[1]/html:html/html:head/html:title"/>
<!--        <xsl:apply-templates select="($webtitle, $mastertitle)[1]/first_edition" mode="meta"/>-->
      </head>
      <!-- will be generated: -->
      <xsl:call-template name="body"/>
    </html>
  </xsl:template>

  <!-- title of the html document-->
  <xsl:template name="htmltitle" as="element(html:title)">
    <title>
<!--      <xsl:value-of select="($webtitle, $mastertitle)[1]/title"/>-->
      <xsl:value-of select="//title"/>
    </title>
  </xsl:template>
  

  

  <xsl:variable name="first-heading" select="($htmlinput[1]/html:html/html:body//html:h2[not(preceding-sibling::*[local-name() = 'p'])]
    [matches(@class, '(section|chapter)')][1], 
    $htmlinput[1]/html:html/html:body//html:h2[@class = 'part'][1])[1]" as="element(html:h2)?"/>
  
  <xsl:template name="htmlinput-body">
    <xsl:apply-templates select="$htmlinput[1]/html:html/html:body/node() except ($htmlinput[1]/html:html/html:body/html:div[@class = 'toc'])"/>
    <xsl:apply-templates select="$htmlinput[1]/html:html/html:body/html:div[@class = 'toc']" mode="discard-toc"/>
  </xsl:template>

  <xsl:template name="author">
    <xsl:param name="_content" as="item()*"/>
    <p class="author">
      <xsl:value-of select="$_content"/>
      <xsl:apply-templates select="$metadata//author" mode="#current" />
    </p>  
  </xsl:template>

  <xsl:template name="title">
    <xsl:param name="_content" as="item()*"/>
<!--    <h1>
      <xsl:attribute name="title" select="$_content"/>
      <xsl:attribute name="class" select="'split'"/>
    </h1>-->
    <p class="title">
      <xsl:value-of select="$_content"/>
      <xsl:apply-templates select="$metadata//title" mode="#current" />
    </p>  
  </xsl:template>
   
  <xsl:template name="keywords">
    <xsl:param name="_content" as="item()*"/>
    <p class="keywords">
      <xsl:value-of select="$_content"/>
      <xsl:apply-templates select="$metadata//keyword" mode="#current" />
<!--      <xsl:value-of select="$_content"/>
      <xsl:for-each-group select="$metadata//keywords" group-by="keyword">
        <xsl:apply-templates select="$metadata//keywords[keyword = current()]" mode="#current" />
      </xsl:for-each-group>-->
    </p>  
  </xsl:template>
  
  <xsl:template name="publisher">
    <xsl:param name="_content" as="item()*"/>
    <p class="publisher">
      <xsl:value-of select="$_content"/>
      <xsl:apply-templates select="$metadata//publisher" mode="#current" />
    </p>  
  </xsl:template>
  
  <xsl:template name="year">
    <xsl:param name="_content" as="item()*"/>
    <p class="year">
      <xsl:value-of select="$_content"/>
      <xsl:apply-templates select="$metadata//year" mode="#current" />
    </p>  
  </xsl:template>
  
  <xsl:template name="weburl">
    <xsl:param name="_content" as="item()*"/>
    <a href="{$metadata//weburl}">
      <xsl:sequence select="$_content"/>        
<!--      <xsl:apply-templates select="$metadata//weburl" mode="#current" />-->
    </a>   
  </xsl:template>
  
  <xsl:template name="weburl-manual">
    <xsl:param name="_content" as="item()*"/>
    <xsl:sequence select="$_content"/>    
    <a href="{$metadata//weburl-manual}">    
      <xsl:apply-templates select="$metadata//weburl-manual" mode="#current" />
    </a>
  </xsl:template>
  
  <xsl:template name="weburl-demo">
    <xsl:param name="_content" as="item()*"/>
    <xsl:sequence select="$_content"/>    
    <a href="{$metadata//weburl-demo}">    
      <xsl:apply-templates select="$metadata//weburl-demo" mode="#current" />
    </a>
  </xsl:template>
  
  
  
 
  
  <xsl:template name="toc">
    <xsl:param name="_content"/>
    <xsl:param name="depth" tunnel="yes"/>
    <xsl:apply-templates select="$htmlinput[1]/html:html/html:body/html:div[@class = 'toc']">
<!--      <xsl:with-param name="heading" select="$_content"/>
      <xsl:with-param name="depth" select="$depth"/>-->
    </xsl:apply-templates>
  </xsl:template>



  <xsl:template match="html:div[@class = 'toc']">
    <xsl:param name="heading"/>
    <xsl:param name="depth" tunnel="yes"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="matches($heading, '^\s*$')"/>
        <xsl:otherwise>
          <xsl:sequence select="$heading"/>
          <xsl:apply-templates select="*[matches(./local-name(), '^h\d')]" mode="discard-toc"/>
        </xsl:otherwise>
      </xsl:choose>
          <xsl:apply-templates select="html:p[xs:integer(replace(@class, '^toc', '')) le xs:integer($depth)]"/>
          <xsl:apply-templates select="html:p[xs:integer(replace(@class, '^toc', '')) le xs:integer($depth)]" mode="discard-toc"/>         
     </xsl:copy>
  </xsl:template>
  
  <!-- change class of first headline, so it will not be split-->
  <xsl:template match="*:h2[. = $first-heading]" priority="2">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="class" select="replace(@class, '(section|part|chapter)', '$1-1')"/>
      <xsl:apply-templates select="@* except @class, node()"/>
    </xsl:copy>
  </xsl:template>
 
  <xsl:template name="impress">
    <xsl:param name="_content"/>
<!--    <xsl:variable name="impress-data" select="($webtitle, $mastertitle)[1]/impress[not(matches(., '^\s*$'))]"/>-->
    <xsl:variable name="impress-data" select="//impress[not(matches(., '^\s*$'))]"/>
    <xsl:if test="$impress-data">
      <xsl:call-template name="_heading">
        <xsl:with-param name="content" select="$_content"/>
        <xsl:with-param name="class" select="'impress'"/>
<!--        <xsl:with-param name="prelim" select="$no-dedicated-info"/>-->
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="$impress-data"/>
  </xsl:template>
  
  <xsl:template match="*[matches(./local-name(), '^h\d')]" mode="discard-toc"/>
  <xsl:template match="html:p[matches(@class, 'toc')]" mode="discard-toc"/>  
  <xsl:template match="html:div[@class = 'toc']" mode="discard-toc"/>
   
<!--  <xsl:template name="title-page">
    <xsl:param name="_content"/>
    <div class="title-page{if ($no-dedicated-info) then ' prelim' else ''}">
      <xsl:call-template name="_heading">
        <xsl:with-param name="content" select="$_content"/>
        <xsl:with-param name="class" select="'contrib-group'"/>
        <xsl:with-param name="prelim" select="$no-dedicated-info"/>
      </xsl:call-template>
      <xsl:if test="$authors and $editors">
        <xsl:message terminate="yes">Titel <xsl:value-of select="$webtitle/title_id"/> (Werk <xsl:value-of select="$work"/>) hat sowohl Autoren als auch Herausgeber.</xsl:message>
      </xsl:if>
      <xsl:if test="not($authors) and not($editors)">
        <xsl:message terminate="yes">Titel <xsl:value-of select="$webtitle/title_id"/> (Werk <xsl:value-of select="$work"/>) hat weder Autoren noch Herausgeber.</xsl:message>
      </xsl:if>
      <p class="author_ed">
        <xsl:apply-templates select="($webtitle, $mastertitle)[1]/$authors, ($webtitle, $mastertitle)[1]/$editors"/>
        <xsl:if test="$editors">&#xa0;(Hrsg.)</xsl:if>
      </p>
      <xsl:apply-templates select="($webtitle, $mastertitle)[1]/title, ($webtitle, $mastertitle)[1]/subtitle, ($webtitle, $mastertitle)[1]/translation_title"/>
      <xsl:apply-templates select="($webtitle, $mastertitle)[1]/publisher"/>
    </div>
  </xsl:template>-->

  <xsl:template match="person_record" as="xs:string">
    <xsl:variable name="seq" as="xs:string*">
      <xsl:value-of select="first_name"/>
      <xsl:if test="normalize-space(first_name) and normalize-space(last_name)">
        <xsl:text xml:space="preserve"> </xsl:text>  
      </xsl:if>
      <xsl:value-of select="last_name"/>
      <xsl:if test="position() ne last()">
        <xsl:text xml:space="preserve">, </xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:sequence select="string-join($seq, '')"/>
  </xsl:template>

  <xsl:template name="about-book-text">
    <xsl:param name="_content"/>
    <!-- Check whether the document order really selects the webtitle first -->
<!--    <xsl:variable name="info-body" select="(($webtitle, $mastertitle)/info_body[not(matches(., '^\s*$'))])[1]"/>-->
    <xsl:variable name="info-body" select="(//info_body[not(matches(., '^\s*$'))])[1]"/>
    <xsl:if test="$info-body">
      <xsl:call-template name="_heading">
        <xsl:with-param name="content" select="$_content"/>
        <xsl:with-param name="class" select="'about'"/>
<!--        <xsl:with-param name="prelim" select="$no-dedicated-info"/>-->
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="$info-body"/>
  </xsl:template>

  <xsl:template name="_heading">
    <xsl:param name="content" as="item()*"/>
    <xsl:param name="class" as="xs:string?"/>
    <xsl:param name="prelim" as="xs:boolean"/>
    <xsl:apply-templates select="$content[matches(*[1]/local-name(), '^h\d')] except @class">
      <xsl:with-param name="class" select="string-join(($class, if ($prelim) then 'prelim' else '', if ($content/@class) then $content/@class else ''), ' ')"/>
    </xsl:apply-templates>
  </xsl:template>

  
    
<!--  <xsl:template match="info_body | impress">
    <xsl:choose>
      <xsl:when test="*:p">
        <xsl:apply-templates select="*" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <p class="noindent">
          <xsl:apply-templates mode="#current"/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>-->

<!--  <xsl:template match="p[position() = 1]" mode="title-page">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="class" select="string-join(('noindent', @class), ' ')"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>-->
  
<!--  <xsl:template match="*:text">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*:text | *:title" mode="extras">
      <xsl:apply-templates mode="#current"/>
  </xsl:template>-->





  <xsl:template match="*:br/@clear" mode="#all"/>
    
  <xsl:template match="@* | *">
    <xsl:param name="class" as="xs:string?"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="$class">
        <xsl:attribute name="class" select="string-join((@class, $class), ' ')"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
