<?xml version="1.0" encoding="utf-8"?>
<p:declare-step
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:bc="http://transpect.le-tex.de/book-conversion"
  xmlns:trdemo="http://www.le-tex.de/namespace/trdemo"
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
      <c:reports pipeline="transpect-demo"/>
    </p:inline>
  </p:input>

  <p:output port="result" primary="true">
    <p:pipe port="result" step="paths"/>
  </p:output>
  <p:output port="report">
    <p:pipe port="result" step="insert-report"/>
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
  <p:option name="pipeline" />
  <p:option name="progress" required="false" select="'no'">
    <p:documentation>Whether to display progress information as text files in a certain directory</p:documentation>
  </p:option>
    
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/paths.xpl"/>
  
  <p:identity name="import-paths-xsl">
    <p:input port="source">
      <p:document href="../xsl/paths.xsl"/>
    </p:input>
  </p:identity>
  
  <bc:paths name="paths">
    <p:with-option name="pipeline" select="$pipeline"/>
    <p:with-option name="publisher" select="$publisher"/>
    <p:with-option name="series" select="$series"/>
    <p:with-option name="work" select="$work"/>
    <p:with-option name="file" select="$file"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="progress" select="$progress"/>
    <p:input port="conf">
      <p:pipe port="conf" step="trdemo-paths"/>
    </p:input>
    <p:input port="report-in">
      <p:pipe port="report-in" step="trdemo-paths"/>
    </p:input>
  </bc:paths>
  
  <p:sink/>

  <p:insert name="insert-report" position="last-child">
    <p:input port="source">
      <p:pipe port="report-in" step="trdemo-paths"/>
    </p:input>
    <p:input port="insertion">
      <p:pipe port="report" step="paths"/>
    </p:input>
  </p:insert>
  
  <p:sink/>

</p:declare-step>