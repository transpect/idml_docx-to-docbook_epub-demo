<?xml version="1.0" encoding="utf-8"?>
<p:declare-step
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:bc="http://transpect.le-tex.de/book-conversion"
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:trdemo="http://www.le-tex.de/namespace/transpect-demo"
  version="1.0"
  name="trdemo-paths"
  type="trdemo:paths">
  
  <p:documentation>
    The paths step evaluates dynamically publisher, book series, 
    work name and paths by the input filename. It provides a c:param-set document 
    for subsequent steps.
  </p:documentation>

  <p:input port="conf" primary="true"/>
  <p:input port="report-in">
    <p:inline>
    	<c:reports pipeline="trdemo-paths"/>
    </p:inline>
  </p:input>

  <p:output port="result" primary="true">
    <p:pipe port="result" step="paths"/>
  </p:output>
	
  <p:output port="report">
    <p:pipe port="report" step="paths"/>
  </p:output>

  <p:option name="publisher" required="false" select="''">
    <p:documentation>
      Used to set the publisher statically. If this option is not set, the 
      step named "paths" will determine the publisher name by the input filename.
    </p:documentation>
  </p:option>
  <p:option name="series" required="false" select="''">
    <p:documentation>
      Used to set the book series statically. If this option is not set, the 
      step named "paths" will determine the series name by the input filename.
    </p:documentation>
  </p:option>
  <p:option name="work" required="false" select="''">
    <p:documentation>
      Used to set the work statically. If this option is not set, the 
      step named "paths" will determine the work name by the input filename.
    </p:documentation>
  </p:option>
	
  <p:option name="file" required="false" select="''"/>
	
  <p:option name="debug" required="false" select="'no'">
    <p:documentation>
      Used to switch debug mode on or off. Pass 'yes' to enable debug mode.
    </p:documentation>
  </p:option>
  
	<p:option name="debug-dir-uri" required="false" select="resolve-uri('debug')">
    <p:documentation>
      Expects a file URI of the directory that should be used to store debug information. 
    </p:documentation>
  </p:option>
  
	<p:option name="pipeline"/>
	
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/paths.xpl"/>
	<p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/simple-progress-msg.xpl"/>
	
  <p:variable name="status-dir-uri" select="concat($debug-dir-uri, '/status')">
    <p:documentation>
      Expects URI where the text files containing the progress information are stored.
    </p:documentation>
  </p:variable>
	
	<letex:simple-progress-msg file="trdemo-paths.txt">
		<p:input port="msgs">
			<p:inline>
				<c:messages>
					<c:message xml:lang="en">Generating File Paths</c:message>
					<c:message xml:lang="de">Generiere Dateisystempfade</c:message>
				</c:messages>
			</p:inline>
		</p:input>
		<p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</letex:simple-progress-msg>
  
  <bc:paths name="paths">
    <p:with-option name="pipeline" select="$pipeline"/>
    <p:with-option name="publisher" select="$publisher"/>
    <p:with-option name="series" select="$series"/>
    <p:with-option name="work" select="$work"/>
    <p:with-option name="file" select="$file"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  	<p:input port="stylesheet">
  		<p:document href="../xsl/trdemo-paths.xsl"/>
  	</p:input>
    <p:input port="conf">
      <p:pipe port="conf" step="trdemo-paths"/>
    </p:input>
  </bc:paths>
  
</p:declare-step>