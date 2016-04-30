<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:transpect="http://www.le-tex.de/namespace/transpect"
	xmlns:letex="http://www.le-tex.de/namespace"
	xmlns:hub2dbk="http://www.le-tex.de/namespace/hub2dbk"
	xmlns:trdemo="http://www.le-tex.de/namespace/transpect-demo"
	version="1.0"
	name="trdemo-hub2dbk"
	type="trdemo:hub2dbk">
	
	<!-- port declarations -->
	
	<p:input port="source" primary="true">
	  <p:documentation>
	    The input port expects a Hub XML document.
	  </p:documentation>
	</p:input>
  
  <p:input port="paths" primary="false">
    <p:documentation>
      The paths document.
    </p:documentation>
  </p:input>
	
	<p:output port="result" primary="true">
	  <p:documentation>
	    The output port provides a Docbook 5.0 XML document.
	  </p:documentation>
		<p:pipe port="result" step="hub2dbk"/>
	</p:output>
	
	<p:output port="dbk-htmltables">
	  <p:documentation>
	    The output port provides a Docbook 5.0 XML document with the HTML table model instead of CALS.
	  </p:documentation>
		<p:pipe port="result" step="cals2html-table"/>
	</p:output>
	
	<!-- options -->
	
  <p:option name="debug" select="'yes'"/> 
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
	<!-- imports -->
	
	<p:import href="http://transpect.le-tex.de/hub2dbk/xpl/hub2dbk.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/load-cascaded.xpl"/>
  
  <transpect:load-cascaded name="load-hub2dbk-stylesheet" filename="hub2dbk/hub2dbk.xsl">
    <p:input port="paths">
      <p:pipe port="paths" step="trdemo-hub2dbk"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </transpect:load-cascaded>
	
	<hub2dbk:convert name="hub2dbk">
	  <p:input port="source">
	    <p:pipe port="source" step="trdemo-hub2dbk"/>
	  </p:input>
	  <p:input port="stylesheet">
	    <p:pipe port="result" step="load-hub2dbk-stylesheet"/>
	  </p:input>
		<p:with-option name="debug" select="$debug"/>
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
	  <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</hub2dbk:convert>
	
	<p:xslt initial-mode="cals2html-table" name="cals2html-table">
		<p:input port="parameters"><p:empty/></p:input>
		<p:input port="stylesheet">
			<p:pipe port="result" step="load-hub2dbk-stylesheet"/>
		</p:input>
	</p:xslt>
	
	<p:sink/>
	
</p:declare-step>