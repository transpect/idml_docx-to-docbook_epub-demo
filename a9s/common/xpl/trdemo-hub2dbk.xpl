<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:tr="http://transpect.io"
	xmlns:trdemo="http://transpect.io/demo"
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
	
	<p:import href="http://transpect.io/hub2dbk/xpl/hub2dbk.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  
  <tr:load-cascaded name="load-hub2dbk-stylesheet" filename="hub2dbk/hub2dbk.xsl">
    <p:input port="paths">
      <p:pipe port="paths" step="trdemo-hub2dbk"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tr:load-cascaded>
	
	<tr:hub2dbk name="hub2dbk">
	  <p:input port="source">
	    <p:pipe port="source" step="trdemo-hub2dbk"/>
	  </p:input>
	  <p:input port="stylesheet">
	    <p:pipe port="result" step="load-hub2dbk-stylesheet"/>
	  </p:input>
		<p:with-option name="debug" select="$debug"/>
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
	  <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
		<p:with-option name="top-level-element-name" 
			select="(/c:param-set/c:param[@name = 'dbk-top-level-element-name']/@value, 'chapter')[1]">
			<p:pipe port="paths" step="trdemo-hub2dbk"/>
		</p:with-option>
	</tr:hub2dbk>
	
	<p:xslt initial-mode="cals2html-table" name="cals2html-table">
		<p:input port="parameters"><p:empty/></p:input>
		<p:input port="stylesheet">
			<p:pipe port="result" step="load-hub2dbk-stylesheet"/>
		</p:input>
	</p:xslt>
	
	<p:sink/>
	
</p:declare-step>