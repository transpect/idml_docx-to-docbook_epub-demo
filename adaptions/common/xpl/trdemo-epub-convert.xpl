<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:epub="http://transpect.le-tex.de/epubtools"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:trdemo="http://www.le-tex.de/namespace/transpect-demo" 
  version="1.0" 
  type="trdemo:epub-convert"
  name="trdemo-epub-convert"> 

  <p:input port="source" primary="false"/>
  <p:input port="paths" primary="true"/>
  
  <p:output port="result" primary="true">
    <p:pipe port="result" step="epub-convert"/>
  </p:output>
  
  <p:output port="report" primary="false">
    <p:pipe port="result" step="epubcheck"/>
  </p:output>

  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  <p:option name="local-css" select="'false'"/>
  <p:option name="svrl-srcpath" select="'/'"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.le-tex.de/epubtools/epub-convert.xpl"/>
  <p:import href="http://transpect.le-tex.de/epubcheck/xpl/epubcheck.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/load-cascaded.xpl"/>
	<p:import href="http://transpect.le-tex.de/xproc-util/store-debug/store-debug.xpl"/>
	
  <p:xslt name="load-meta">
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:input port="source">
      <p:pipe port="paths" step="trdemo-epub-convert"/>
    </p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet 
        	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
        	xmlns:c="http://www.w3.org/ns/xproc-step"
          xmlns:dc="http://purl.org/dc/elements/1.1/" 
          version="2.0">

          <xsl:template match="/c:param-set">
          	<epub-config format="EPUB3" layout="reflowable">
          		
          		<types>

          			<type name="landmarks" heading="Übersicht" hidden="true" types="bodymatter toc"/>
          			<type name="toc" heading="Inhaltsverzeichnis" file="toc" hidden="true"/>
          			<type name="cover" heading="Cover" file="cover"/>
          			<type name="frontmatter" heading="Vorspann"/>
          			<type name="bodymatter" heading="Hauptteil"/>
          			<type name="backmatter" heading="Anhang"/>
          			<type name="glossary" heading="Glossar"/>
          			<type name="letex:bio" file="author"/>
          			<type name="letex:about-the-book" file="about-the-book"/>
          			<type name="abstract" file="about-the-content"/>
          			<type name="fulltitle" file="title"/>
          			<type name="copyright-page" file="copyright"/>
          			<type name="part" file="part"/>
          			<type name="chapter" file="chapter"/>
          			<type name="appendix" file="appendix"/>
          			<type name="glossary" file="glossary"/>
          			<type name="other-credits" file="other-credits"/>
          			<type name="letex:popup" file="popup"/>
          			<type name="letex:advertisement" file="advertisement"/>
          		</types>
          		
          		<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
          			<dc:identifier><xsl:value-of select="c:param[@name eq 'work-basename']/@value"/></dc:identifier>
          			<dc:title>Mustertitel</dc:title>
          			<dc:creator><xsl:value-of select="c:param[@name eq 'publisher']/@value"/></dc:creator>
          			<dc:publisher><xsl:value-of select="c:param[@name eq 'publisher']/@value"/></dc:publisher>
          			<dc:date><xsl:value-of select="current-date()"/></dc:date>
          		  <dc:language>de</dc:language>
          		</metadata>
          		
          		<hierarchy media-type="application/xhtml+xml" max-population="40" max-text-length="200000">
          			<unconditional-split elt="div" attr="class" attval="white"/>
          			<unconditional-split elt="h1"/>
          			<heading elt="h1"/>
          			<unconditional-split attr="epub:type" attval="letex:bio"/>
          			<unconditional-split attr="epub:type" attval="cover"/>
          		</hierarchy>
          	
          	</epub-config>
          	
          </xsl:template>

        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>

  <p:sink/>

  <p:parameters name="params">
    <p:input port="parameters">
      <p:pipe port="paths" step="trdemo-epub-convert"/>
    </p:input>
  </p:parameters>

  <p:add-attribute name="add-base-uri" match="/*" attribute-name="xml:base">
    <p:with-option name="attribute-value"
      select="replace(replace(/c:param-set/c:param[@name eq 'file-uri']/@value, '/(docx|xml|hub|idml|zip)/', '/epub/'), '\.(docx|xml|hub|idml|zip)$', '.html')">
      <p:pipe port="result" step="params"/>
    </p:with-option>
    <p:input port="source">
      <p:pipe port="source" step="trdemo-epub-convert"/>
    </p:input>
  </p:add-attribute>
    
  <letex:store-debug pipeline-step="epubtools/pre-epubconvert">
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </letex:store-debug>
  
  <epub:convert name="epub-convert">
    <p:input port="source">
      <p:pipe port="result" step="add-base-uri"/>
    </p:input>
    <p:input port="meta">
      <p:pipe port="result" step="load-meta"/>
    </p:input>
  	<p:input port="conf">
  		<p:empty/>
  	</p:input>
    <p:with-option name="terminate-on-error" select="'no'"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </epub:convert>
  
  <letex:epubcheck name="epubcheck">
    <p:with-option name="epubfile-path" select="replace(/c:param-set/c:param[@name eq 'file']/@value, '^(.+\.)(docx|idml|epub)$', '$1epub', 'i')">
      <p:pipe port="paths" step="trdemo-epub-convert"/>
    </p:with-option>
    <p:with-option name="epubcheck-path" select="concat(/c:param-set/c:param[@name eq 'common-path']/@value, '../../epubcheck/bin/epubcheck-3.0.1.jar')">
      <p:pipe port="paths" step="trdemo-epub-convert"/>
    </p:with-option>
    <p:with-option name="svrl-srcpath" select="$svrl-srcpath"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </letex:epubcheck>
  
  <p:sink/>

</p:declare-step>