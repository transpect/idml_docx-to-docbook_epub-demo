<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:bc="http://transpect.le-tex.de/book-conversion"
  xmlns:docx2hub="http://www.le-tex.de/namespace/docx2hub"
  xmlns:hub2htm="http://www.le-tex.de/namespace/hub2htm"
  xmlns:transpect="http://www.le-tex.de/namespace/transpect"
  name="docx2epub">
  
  <p:input port="conf" primary="true">
    <p:document href="../../../conf/conf.xml"/>
  </p:input>
  
  <p:output port="result">
    <p:pipe port="result" step="epub-convert"/>
  </p:output>
  
  <p:option name="docx" required="true"/>
  <p:option name="hub-version" select="'1.1'"/>
  <p:option name="series" select="''"/> 
  <p:option name="work" select="''"/> 
  <p:option name="publisher" select="''"/>
  <p:option name="debug" select="'yes'"/> 
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="progress" required="false" select="'yes'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" /> 
  <p:import href="http://transpect.le-tex.de/docx2hub/wml2hub.xpl"/> 
  <p:import href="http://transpect.le-tex.de/hub2html/xpl/hub2html.xpl"/>  
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/evolve-hub.xpl"/>
  <p:import href="paths.xpl"/>
  <p:import href="epub.xpl"/>
  
  <transpect:paths name="paths"> 
    <p:with-option name="pipeline" select="'docx2epub.xpl'"/> 
    <p:with-option name="publisher" select="$publisher"/> 
    <p:with-option name="series" select="$series"/> 
    <p:with-option name="work" select="$work"/> 
    <p:with-option name="file" select="$docx"/> 
    <p:with-option name="debug" select="$debug"/> 
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/> 
    <p:with-option name="progress" select="$progress"/> 
    <p:input port="conf"> 
      <p:pipe port="conf" step="docx2epub"/> 
    </p:input>
  </transpect:paths>
    
  <docx2hub:convert name="docx2hub">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="docx" select="/c:param-set/c:param[@name eq 'file']/@value"/>
    <p:with-option name="hub-version" select="$hub-version"/>
    <p:with-option name="srcpaths" select="'yes'"/>
  </docx2hub:convert>
  
  <bc:evolve-hub name="evolve-hub-dyn" srcpaths="yes">
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </bc:evolve-hub>
  
  <hub2htm:convert name="hub2htm">
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:input port="other-params">
      <p:empty/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </hub2htm:convert>
  
  <transpect:epub name="epub-convert">
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:input port="source">
      <p:pipe port="result" step="hub2htm"/>
    </p:input>
    <p:input port="report-in">
      <p:inline>
        <pseudo>xml</pseudo>
      </p:inline>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </transpect:epub>
  
</p:declare-step>