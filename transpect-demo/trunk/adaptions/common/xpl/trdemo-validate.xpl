<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:bc="http://transpect.le-tex.de/book-conversion"
	xmlns:transpect="http://www.le-tex.de/namespace/transpect"
	xmlns:letex="http://www.le-tex.de/namespace"
	xmlns:trdemo="http://www.le-tex.de/namespace/transpect-demo"
	version="1.0"
	name="trdemo-validate"
	type="trdemo:validate">
	
	<!-- port declarations -->
	
	<p:input port="source" primary="true"/>
	
	<p:input port="paths" primary="false">
		<p:documentation>
			The 'paths' port expects a c:param-set document including the file pathsv.
		</p:documentation>
	</p:input>
	
	<p:input port="schema" primary="false">
		<p:documentation>Excepts the Docbook 5.0 RNG schema</p:documentation>
		<p:document href="http://www.le-tex.de/resource/schema/docbook/5.0/docbook.rng"/>
	</p:input>
	
	<p:output port="result" primary="true"/>
	
	<p:output port="report" primary="false"/>
	
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
	
	<p:option name="check" required="false" select="'yes'">
		<p:documentation>
			Pass "yes" to enable checking with Schematron.
		</p:documentation>
	</p:option>
	
	<!-- imports -->
	
	<p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/check-styles.xpl"/>
	<p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/validate-with-schematron.xpl"/>
	<p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/validate-with-rng.xpl"/>
	
	<bc:check-styles name="check-styles">
		<p:input port="html-in">
			<p:empty/>
		</p:input>
		<p:input port="parameters">
			<p:pipe port="paths" step="trdemo-validate"/>
		</p:input>
		<p:with-option name="debug" select="$debug"/>
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
		<p:with-option name="active" select="$check"/>
	</bc:check-styles>
	
	<bc:validate-with-schematron name="validate-business-rules">
		<p:input port="html-in">
			<p:empty/>
		</p:input>
		<p:input port="parameters">
			<p:pipe port="paths" step="trdemo-validate"/>
		</p:input>
		<p:with-param name="family" select="'business-rules'"/>
		<p:with-param name="step-name" select="'validate-business-rules'"/>
		<p:with-option name="debug" select="$debug"/>
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
		<p:with-option name="active" select="$check"/>
	</bc:validate-with-schematron>
	
	<bc:validate-with-rng name="validate-with-rng">
		<p:input port="schema">
			<p:pipe port="schema" step="trdemo-validate"/>
		</p:input>
	</bc:validate-with-rng>
	
</p:declare-step>