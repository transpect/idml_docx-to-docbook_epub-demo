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

  <xsl:variable name="work-metadata" select="$metadata/ONIXmessage/product[a001 = $work]" as="element(product)?"/>

  <xsl:template name="main">
    <html>
      <head>
        <xsl:call-template name="htmltitle"/>
        <xsl:apply-templates select="$htmlinput[1]/html:html/html:head/node() except $htmlinput[1]/html:html/html:head/html:title"/>
      </head>
      <!-- will be generated: -->
      <xsl:call-template name="body"/>
    </html>
  </xsl:template>

  <!-- title of the html document-->
  <xsl:template name="htmltitle" as="element(html:title)">
    <title>
      <xsl:value-of select="$htmlinput//title"/> 
    </title>
  </xsl:template>
   
  <xsl:template name="htmlinput-body">
    <xsl:apply-templates select="$htmlinput[1]/html:html/html:body/node() except ($htmlinput[1]/html:html/html:body/html:div[@class = 'toc'])"/>
    <xsl:apply-templates select="$htmlinput[1]/html:html/html:body/html:div[@class = 'toc']" mode="discard-toc"/>
  </xsl:template>

  <xsl:template name="metadaten">
    <xsl:param name="_content" as="item()*"/>
    <xsl:if test="$work-metadata">
      <a rel="transclude" href="#metadaten"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="infos">
    <xsl:param name="_content" as="item()*"/>
    <xsl:if test="$work-metadata">
      <a rel="transclude" href="#infos"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="author">
    <xsl:param name="_content" as="item()*"/>
    <p class="author">
      <xsl:value-of select="$_content"/>
      <xsl:apply-templates select="$metadata//descriptivedetail/contributor/b036" mode="#current" />
    </p>  
  </xsl:template>

  <xsl:template name="title">
    <xsl:param name="_content" as="item()*"/>
    <p class="title">
      <xsl:value-of select="$_content"/>
      <xsl:apply-templates select="$metadata//descriptivedetail/titledetail/titleelement/b203" mode="#current" />
    </p>  
  </xsl:template>
  
  <xsl:template name="keywords">
    <xsl:param name="_content" as="item()*"/>
    <p class="title">
      <xsl:value-of select="$_content"/>
      <xsl:apply-templates select="$metadata//descriptivedetail/subject/b070" mode="#current" />
    </p>  
  </xsl:template>
  
  <xsl:template name="publisher">
    <xsl:param name="_content" as="item()*"/>
    <p class="publisher">
      <xsl:value-of select="$_content"/>
      <xsl:apply-templates select="$metadata//publishingdetail/publisher/b081" mode="#current" />
    </p>  
  </xsl:template>
  
  <xsl:template name="year">
    <xsl:param name="_content" as="item()*"/>
    <p class="year">
      <xsl:value-of select="$_content"/>
      <xsl:apply-templates select="$metadata//publishingdetail/publishingdate/b306" mode="#current" />
    </p>  
  </xsl:template>
  
  <xsl:template name="weburl-whitepaper">
    <xsl:param name="_content" as="item()*"/>
    <p class="keywords">
      <xsl:value-of select="$_content"/>
      <a href="{$metadata//productsupply/supplydetail/supplier/website/b295}">
        <xsl:apply-templates select="$metadata//productsupply/supplydetail/supplier/website/b295" mode="#current" />
      </a>
    </p>  
  </xsl:template>
  
  <xsl:template name="weburl">
    <xsl:param name="_content" as="item()*"/>
    <a href="{$metadata//relatedmaterial/relatedproduct[1]/website/b295}">
      <xsl:sequence select="$_content"/>        
    </a>   
  </xsl:template>
  
  <xsl:template name="weburl-manual">
    <xsl:param name="_content" as="item()*"/>
    <xsl:sequence select="$_content"/>    
    <a href="{$metadata//relatedmaterial/relatedproduct[2]/website/b295}">    
      <xsl:apply-templates select="$metadata//relatedmaterial/relatedproduct[2]/website/b295" mode="#current" />
    </a>
  </xsl:template>
  
  <xsl:template name="weburl-demo">
    <xsl:param name="_content" as="item()*"/>
    <xsl:sequence select="$_content"/>    
    <a href="{$metadata//relatedmaterial/relatedproduct[3]/website/b295}">    
      <xsl:apply-templates select="$metadata//relatedmaterial/relatedproduct[3]/website/b295" mode="#current" />
    </a>
  </xsl:template>
  
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
