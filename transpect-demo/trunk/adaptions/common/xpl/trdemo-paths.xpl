<?xml version="1.0" encoding="utf-8"?>
<p:declare-step
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:transpect="http://www.le-tex.de/namespace/transpect"
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
	
  <p:option name="file" required="false" select="''"/>
  <p:option name="pipeline" select="'unknown'"/>
  
  <p:option name="debug" select="'yes'"/> 
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="progress" select="'yes'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:option name="interface-language" select="'en'"/>
  <p:option name="clades" select="''"/>
	
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/paths.xpl"/>
	<p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/simple-progress-msg.xpl"/>
	
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
  
  <p:load name="import-paths-xsl">
    <p:with-option name="href" select="(/*/@paths-xsl-uri, 'http://transpect.le-tex.de/book-conversion/converter/xsl/paths.xsl')[1]"/>
  </p:load>
  
  <transpect:paths name="paths" determine-transpect-project-version="yes">
    <p:with-option name="pipeline" select="$pipeline"/>
    <p:with-option name="interface-language" select="$interface-language"/>
    <p:with-option name="clades" select="$clades"/>
    <p:with-option name="file" select="$file"/>
    <p:with-option name="debug" select="$debug"/>  
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>  
    <p:with-option name="progress" select="$progress"/>
    <p:input port="conf">
      <p:pipe port="conf" step="trdemo-paths"/>
    </p:input>
  </transpect:paths>
  
  <p:sink/>
  
  <!--<transpect:paths name="paths">
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
  </transpect:paths>-->
  
</p:declare-step>