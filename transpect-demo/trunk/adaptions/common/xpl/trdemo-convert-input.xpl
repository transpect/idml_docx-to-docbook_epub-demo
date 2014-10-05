<?xml version="1.0" encoding="utf-8"?>
<p:declare-step
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:bc="http://transpect.le-tex.de/book-conversion"
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
	
	<p:option name="progress" select="'yes'">
		<p:documentation>
			Whether to display progress information as text files in a certain directory
		</p:documentation>
	</p:option>
	
	<p:option name="status-dir-uri" select="concat($debug-dir-uri, '/status')">
		<p:documentation>
			Expects URI where the text files containing the progress information are stored.
		</p:documentation>
	</p:option>
	
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
			</idml2xml:hub>		
		</p:when>
		<p:when test="matches($file, '^.+\.docx$')">
			<docx2hub:convert name="docx2hub">
				<p:with-option name="docx" select="$file"/>
				<p:with-option name="srcpaths" select="'yes'"/>
				<p:with-option name="debug" select="$debug"/>
				<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
			</docx2hub:convert>
		</p:when>
	</p:choose>

	<bc:evolve-hub name="evolve-hub-dyn" srcpaths="yes">
		<p:documentation>
			Build headline hierarchy, detect lists, figure captions etc.
		</p:documentation>
		<p:input port="paths">
			<p:pipe port="paths" step="trdemo-convert-input"/>
		</p:input>
		<p:with-option name="debug" select="$debug"/>
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
	</bc:evolve-hub>

</p:declare-step>