<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:bc="http://transpect.le-tex.de/book-conversion"
  xmlns:hub2htm="http://www.le-tex.de/namespace/hub2htm"
  xmlns:docx2hub = "http://www.le-tex.de/namespace/docx2hub"
  xmlns:trdemo="http://www.le-tex.de/namespace/trdemo"
  xmlns:transpect="http://www.le-tex.de/namespace/transpect"
  xmlns:letex="http://www.le-tex.de/namespace"
  name="docx2idml"
  version="1.0">
  
  <p:input port="conf" primary="true">
    <p:document href="http://customers.le-tex.de/generic/book-conversion/conf/conf.xml"/>
  </p:input>
  
  <p:output port="hub" primary="false">
    <p:pipe port="result" step="docx2hub"/>
  </p:output>
  <p:serialization port="hub" omit-xml-declaration="false"/>
  
  <p:option name="docxfile" required="true"/>
  <p:option name="hub-version" select="'1.1'"/>
  
  <p:option name="publisher" select="''" required="false"/>
  <p:option name="series" select="''" required="false"/> 
  <p:option name="work" select="''" required="false"/> 
  
  <p:option name="progress" required="false" select="'yes'"/>
  <p:option name="debug" select="'yes'"/> 
  <p:option name="debug-dir-uri" select="'debug'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.le-tex.de/docx2hub/wml2hub.xpl" />
  <p:import href="http://transpect.le-tex.de/idmlval/xpl/idmlval.xpl" />
  <p:import href="http://transpect.le-tex.de/xml2idml/xpl/xml2idml.xpl" />
  <p:import href="http://transpect.le-tex.de/xproc-util/store-debug/store-debug.xpl"/>
  <p:import href="paths.xpl"/>
  
  <trdemo:paths name="paths"> 
    <p:with-option name="pipeline" select="'docx2idml.xpl'"/> 
    <p:with-option name="publisher" select="$publisher"/> 
    <p:with-option name="series" select="$series"/> 
    <p:with-option name="work" select="$work"/> 
    <p:with-option name="file" select="$docxfile"/> 
    <p:with-option name="progress" select="$progress"/> 
    <p:with-option name="debug" select="$debug"/> 
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/> 
    <p:input port="conf"> 
      <p:pipe port="conf" step="docx2idml"/> 
    </p:input>
  </trdemo:paths>
    
  <docx2hub:convert name="docx2hub">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="docx" select="/c:param-set/c:param[@name eq 'file']/@value"/>
    <p:with-option name="hub-version" select="$hub-version"/>
    <p:with-option name="srcpaths" select="'no'"/>
  </docx2hub:convert>

  <bc:xml2idml name="hub2idml">
    <p:with-option name="template" select="'hub2idml/template.idml'" />
    <p:with-option name="mapping" select="'hub2idml/mapping.xml'"/>
    <!--<p:with-option name="idml-target-uri" select="$idml-target-uri"/>-->
    <p:with-option name="debug" select="$debug" />
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
  </bc:xml2idml>

  <p:sink/>

</p:declare-step>