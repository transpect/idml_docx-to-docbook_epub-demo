<?xml version="1.0" encoding="utf-8"?>
<p:declare-step
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:transpect="http://www.le-tex.de/namespace/transpect"
  xmlns:trdemo="http://www.le-tex.de/namespace/transpect-demo"
  xmlns:docx2hub="http://www.le-tex.de/namespace/docx2hub"
  xmlns:idml2xml="http://www.le-tex.de/namespace/idml2xml"
  version="1.0"
  name="trdemo-convert-input"
  type="trdemo:convert-input">
	
	<!-- port declarations -->
	
	<p:input port="paths" primary="true">
		<p:documentation>
			The 'paths' port expects a c:param-set document including the file pathsv.
		</p:documentation>
	</p:input>
	
	<p:output port="result" primary="true"/>
	
	<!-- options -->
	
  <p:option name="debug" select="'yes'"/> 
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
	
	<!-- imports -->
	
	<p:import href="http://transpect.le-tex.de/docx2hub/wml2hub.xpl"/>
	<p:import href="http://transpect.le-tex.de/idml2xml/xpl/idml2hub.xpl"/>
	<p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/evolve-hub.xpl"/>
	
	<!-- load either docx2hub or idml2xml -->
	
	<p:choose>
		<p:variable name="file" select="/c:param-set/c:param[@name eq 'file']/@value"/>
		<p:when test="matches($file, '^.+\.idml$')">
			<idml2xml:hub name="idml2hub">
				<p:with-option name="idmlfile" select="$file"/>
				<p:with-option name="all-styles" select="'no'"/>
				<p:with-option name="srcpaths" select="'yes'"/>
				<p:with-option name="debug" select="$debug"/>
				<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
			  <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
			</idml2xml:hub>		
		</p:when>
		<p:when test="matches($file, '^.+\.docx$')">
			<docx2hub:convert name="docx2hub">
				<p:with-option name="docx" select="$file"/>
				<p:with-option name="srcpaths" select="'yes'"/>
				<p:with-option name="debug" select="$debug"/>
				<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
			  <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
			</docx2hub:convert>
		</p:when>
	</p:choose>

	<transpect:evolve-hub name="evolve-hub-dyn" srcpaths="yes">
		<p:documentation>
			Build headline hierarchy, detect lists, figure captions etc.
		</p:documentation>
		<p:input port="paths">
			<p:pipe port="paths" step="trdemo-convert-input"/>
		</p:input>
		<p:with-option name="debug" select="$debug"/>
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
	  <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</transpect:evolve-hub>

</p:declare-step>