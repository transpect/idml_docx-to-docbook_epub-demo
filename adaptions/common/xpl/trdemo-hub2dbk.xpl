<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:letex="http://www.le-tex.de/namespace"
	xmlns:hub2dbk="http://www.le-tex.de/namespace/hub2dbk"
	xmlns:trdemo="http://www.le-tex.de/namespace/transpect-demo"
	version="1.0"
	name="trdemo-hub2dbk"
	type="trdemo:hub2dbk">
	
	<!-- port declarations -->
	
	<p:input port="source"/>
	
	<p:output port="result"/>
	
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
	
	<p:option name="progress" required="false" select="'yes'">
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
	
	<p:import href="http://transpect.le-tex.de/hub2dbk/xpl/hub2dbk.xpl"/>
	
	<hub2dbk:convert>
		<p:with-option name="debug" select="$debug"/>
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
	</hub2dbk:convert>
	
</p:declare-step>