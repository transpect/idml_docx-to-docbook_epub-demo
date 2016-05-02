<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:epub="http://transpect.io/epubtools"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:tr="http://transpect.io"  
  xmlns:trdemo="http://transpect.io/demo" 
  version="1.0" 
  type="trdemo:epub-convert"
  name="trdemo-epub-convert"> 

  <p:input port="source" primary="true"/>
  <p:input port="paths" primary="false"/>
  
  <p:output port="result" primary="true">
    <p:pipe port="result" step="epub-convert"/>
  </p:output>
  
  <p:output port="report" primary="false" sequence="true">
  	<p:pipe port="report" step="epub-convert"/>
    <p:pipe port="report" step="kindlegen"/>
    <p:pipe port="result" step="epubcheck"/>
  </p:output>

  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  <p:option name="local-css" select="'false'"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/epubtools/xpl/epub-convert.xpl"/>
  <p:import href="http://transpect.io/epubcheck-idpf/xpl/epubcheck.xpl"/>
  <p:import href="http://transpect.io/kindlegen/xpl/kindlegen.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
	<p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <!--  *
        * Load the epub-config skeleton 
        * -->
  
  <tr:load-cascaded name="load-epub-config" filename="epubtools/epub-config.xml">
    <p:input port="paths">
      <p:pipe port="paths" step="trdemo-epub-convert"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tr:load-cascaded>
  
  <!--  *
        * Patch the current values from the paths document into the epub-config skeleton.  
        * -->  
  
  <p:xslt name="patch-epub-config">
    <p:input port="parameters">
      <p:pipe port="paths" step="trdemo-epub-convert"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xsl/trdemo-epub-config.xsl"/>
    </p:input>
  </p:xslt>
  
  <tr:store-debug pipeline-step="epubtools/epub-config">
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </tr:store-debug>
  
  <p:sink/>
  
  <!--  *
        * The step epub:convert locate the HTML file with it's base URI. Therefore 
        * it's necessary to patch the base uri to the current location of the HTML file. 
        * -->
  
  <p:add-attribute name="add-base-uri" match="/*" attribute-name="xml:base">
    <p:with-option name="attribute-value"
      select="replace(replace(/c:param-set/c:param[@name eq 'file']/@value, '/(docx|idml)/', '/epub/'), '\.(docx|idml)$', '.html')">
      <p:pipe port="paths" step="trdemo-epub-convert"/>
    </p:with-option>
    <p:input port="source">
      <p:pipe port="source" step="trdemo-epub-convert"/>
    </p:input>
  </p:add-attribute>
  
  <!--  *
        * The step epub:convert locate the HTML file with it's base URI. Therefore 
        * it's necessary to patch the base uri to the current location of the HTML file. 
        * -->
  
  <epub:convert name="epub-convert">
    <p:input port="source">
      <p:pipe port="result" step="add-base-uri"/>
    </p:input>
    <p:input port="meta">
      <p:pipe port="result" step="patch-epub-config"/>
    </p:input>
  	<p:input port="conf">
  		<p:empty/>
  	</p:input>
    <p:with-option name="terminate-on-error" select="'no'"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </epub:convert>
  
  <!--  *
        * The following step implements epubcheck and generates an SVRL report.
        * -->
  
  <tr:kindlegen name="kindlegen" cx:depends-on="epub-convert">
    <p:with-option name="epub" select="/c:result/@os-path"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:kindlegen>
  
  <p:sink/>
  
  <tr:epubcheck name="epubcheck" cx:depends-on="kindlegen">
    <p:with-option name="epubfile-path" select="/c:result/@os-path">
      <p:pipe port="result" step="epub-convert"/>
    </p:with-option>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:epubcheck>
  
</p:declare-step>