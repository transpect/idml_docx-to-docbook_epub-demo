<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:bc="http://transpect.le-tex.de/book-conversion"
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
	</p:output>
	
	<!-- options -->
	
	<p:option name="debug" select="'no'">
		<p:documentation>
			Used to switch debug mode on or off. Pass 'yes' to enable debug mode.
		</p:documentation>
	</p:option>
	
	<p:option name="debug-dir-uri" select="'debug'">
		<p:documentation>
			Expects a file URI of the directory that should be used to store debug information. 
		</p:documentation>
	</p:option>
	
	<!-- imports -->
	
	<p:import href="http://transpect.le-tex.de/hub2dbk/xpl/hub2dbk.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/load-cascaded.xpl"/>
  
  <bc:load-cascaded name="load-hub2dbk-stylesheet" filename="hub2dbk/hub2dbk.xsl">
    <p:input port="paths">
      <p:pipe port="paths" step="trdemo-hub2dbk"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </bc:load-cascaded>
	
	<hub2dbk:convert>
	  <p:input port="source">
	    <p:pipe port="source" step="trdemo-hub2dbk"/>
	  </p:input>
	  <p:input port="stylesheet">
	    <p:pipe port="result" step="load-hub2dbk-stylesheet"/>
	  </p:input>
		<p:with-option name="debug" select="$debug"/>
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
	</hub2dbk:convert>
	
</p:declare-step>