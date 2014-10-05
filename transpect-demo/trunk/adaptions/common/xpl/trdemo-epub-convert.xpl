<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:bc="http://transpect.le-tex.de/book-conversion" 
  xmlns:epub="http://transpect.le-tex.de/epubtools"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:trdemo="http://www.le-tex.de/namespace/transpect-demo" 
  version="1.0" 
  name="trdemo-epub-convert" 
  type="trdemo:epub-convert">

  <p:input port="source" primary="false"/>
  <p:input port="paths" primary="true"/>
  
  <p:output port="result" primary="true">
    <p:pipe port="result" step="epub-convert"/>
  </p:output>

  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="resolve-uri('debug')"/>
  <p:option name="local-css" required="false" select="'false'"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.le-tex.de/epubtools/epub-convert.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/load-cascaded.xpl"/>
  <p:import href="http://transpect.le-tex.de/xproc-util/store-debug/store-debug.xpl"/>

  <bc:load-cascaded name="load-epub-heading-conf" filename="epubtools/heading-conf.xml">
    <p:input port="paths">
      <p:pipe port="paths" step="trdemo-epub"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </bc:load-cascaded>

  <p:sink/>

  <p:xslt name="load-meta">
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:input port="source">
      <p:pipe port="paths" step="trdemo-epub"/>
    </p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:c="http://www.w3.org/ns/xproc-step"
          xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">

          <xsl:template match="/c:param-set">
            <epub-config>
              <opf>
                <packageid>
                  <xsl:value-of select="c:param[@name eq 'work-basename']/@value"/>
                </packageid>
                <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
                  <dc:identifier>
                    <xsl:value-of select="c:param[@name eq 'work-basename']/@value"/>
                  </dc:identifier>
                  <dc:title>
                    <xsl:value-of select="c:param[@name eq 'work']/@value"/>
                  </dc:title>
                  <dc:creator>
                    <xsl:value-of select="c:param[@name eq 'publisher']/@value"/>
                  </dc:creator>
                  <dc:publisher>
                    <xsl:value-of select="c:param[@name eq 'publisher']/@value"/>
                  </dc:publisher>
                  <dc:date>
                    <xsl:value-of select="current-date()"/>
                  </dc:date>
                  <dc:language>de</dc:language>
                </metadata>
              </opf>
            </epub-config>
          </xsl:template>

        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>

  <p:sink/>

  <p:parameters name="params">
    <p:input port="parameters">
      <p:pipe port="paths" step="trdemo-epub"/>
    </p:input>
  </p:parameters>

  <p:add-attribute name="add-base-uri" match="/*" attribute-name="xml:base">
    <p:with-option name="attribute-value"
      select="replace(replace(/c:param-set/c:param[@name eq 'file-uri']/@value, '/(docx|xml|hub|idml)/', '/epub/'), '\.(docx|xml|hub|idml)$', '.html')">
      <p:pipe port="result" step="params"/>
    </p:with-option>
    <p:input port="source">
      <p:pipe port="source" step="trdemo-epub"/>
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
    <p:input port="conf">
      <p:pipe port="result" step="load-epub-heading-conf"/>
    </p:input>
    <p:input port="meta">
      <p:pipe port="result" step="load-meta"/>
    </p:input>
    <p:input port="report-in">
      <p:pipe step="trdemo-epub" port="report-in"/>
    </p:input>
    <p:with-option name="terminate-on-error" select="'no'"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </epub:convert>

</p:declare-step>