<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  xmlns:trdemo="http://transpect.io/demo"
  xmlns:docx2hub="http://transpect.io/docx2hub"
  xmlns:idml2xml="http://transpect.io/idml2xml" 
  xmlns:dbk="http://docbook.org/ns/docbook"
  version="1.0" 
  name="trdemo-convert-input" 
  type="trdemo:convert-input">

  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <h1>trdemo:convert-input</h1>
    <p>This step takes the paths document and converts either a DOCX or IDML file first to flat and
      then to evolved Hub XML.</p>
  </p:documentation>

  <!-- port declarations -->

  <p:input port="paths">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h3>Input port: <code>paths</code></h3>
      <p>The 'paths' port expects a c:param-set document including the file paths.</p>
    </p:documentation>
  </p:input>

  <p:output port="result" primary="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h3>Output port: <code>result</code></h3>
      <p>The output port </p>
    </p:documentation>
  </p:output>
  
  <p:output port="report" sequence="true">
    <p:pipe port="report" step="convert-depending-on-format"/>
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h3>Output port: <code>report</code></h3>
      <p>SVRL report of converted input files</p>
    </p:documentation>
  </p:output>

  <!-- options -->

  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>

  <!-- imports -->

  <p:import href="http://transpect.io/docx2hub/xpl/docx2hub.xpl"/>
  <p:import href="http://transpect.io/idml2xml/xpl/idml2hub.xpl"/>
  <p:import href="http://transpect.io/evolve-hub/xpl/evolve-hub.xpl"/>
  <p:import href="http://transpect.io/htmlreports/xpl/validate-with-schematron.xpl"/>
  
  <p:import href="trdemo-patch-and-copy-filerefs.xpl"/>

  
  
  <!-- load either docx2hub or idml2xml -->
  
  <p:choose name="convert-depending-on-format">
    <p:variable name="file" select="/c:param-set/c:param[@name eq 'file']/@value"/>
    <p:when test="matches($file, '^.+\.idml$', 'i')">
      <p:output port="result" primary="true"/>
      <p:output port="report" sequence="true" primary="false">
        <p:pipe port="report" step="sch_idml"/>
      </p:output>

      <idml2xml:hub name="idml2hub">
        <p:with-option name="idmlfile" select="$file"/>
        <p:with-option name="all-styles" select="'no'"/>
        <p:with-option name="srcpaths" select="'yes'"/>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      </idml2xml:hub>
      
      <tr:validate-with-schematron name="sch_idml">
        <p:input port="source">
          <p:pipe port="DocumentStoriesSorted" step="idml2hub"/>
        </p:input>
        <p:input port="html-in">
          <p:empty/>
        </p:input>
        <p:input port="parameters">
          <p:pipe port="paths" step="trdemo-convert-input"/>
        </p:input>
        <p:with-param name="family" select="'idml'"/>
        <p:with-param name="step-name" select="'sch_idml2hub_dss'"/>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
        <p:with-option name="active" select="'yes'"/>
      </tr:validate-with-schematron>
      
      <p:identity>
        <p:input port="source">
          <p:pipe port="result" step="idml2hub"/>
        </p:input>
      </p:identity>

    </p:when>
    <p:when test="matches($file, '^.+\.docx$', 'i')">
      <p:output port="result" primary="true"/>
      <p:output port="report" sequence="true" primary="false">
        <p:pipe port="report" step="docx2hub"/>
      </p:output>
      
      <docx2hub:convert name="docx2hub">
        <p:with-option name="docx" select="$file"/>
        <p:with-option name="srcpaths" select="'yes'"/>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      </docx2hub:convert>
      
    </p:when>
  </p:choose>

  <tr:evolve-hub name="evolve-hub-dyn" srcpaths="yes">
    <p:documentation> Build headline hierarchy, detect lists, figure captions etc. </p:documentation>
    <p:input port="paths">
      <p:pipe port="paths" step="trdemo-convert-input"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:evolve-hub>

  <trdemo:patch-and-copy-filerefs>
    <p:input port="paths">
      <p:pipe port="paths" step="trdemo-convert-input"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:with-option name="assets-dirname"
      select="(/dbk:hub/dbk:info/dbk:keywordset[@role eq 'hub']/dbk:keyword[@role eq 'assets-dirname'], 'assets')[1]"
    />
  </trdemo:patch-and-copy-filerefs>

</p:declare-step>
