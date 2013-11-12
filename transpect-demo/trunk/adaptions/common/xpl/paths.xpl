<?xml version="1.0" encoding="utf-8"?>
<p:declare-step
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:bc="http://transpect.le-tex.de/book-conversion"
  xmlns:transpect="http://www.le-tex.de/namespace/transpect"
  version="1.0"
  name="transpect-paths"
  type="transpect:paths">
  
  <p:option name="series" required="false" select="''"/>
  <p:option name="work" required="false" select="''"/>
  <p:option name="publisher" required="false" select="''"/>
  <p:option name="file" required="false" select="''"/>
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="resolve-uri('debug')"/>
  <p:option name="pipeline" />
  <p:option name="progress" required="false" select="'no'">
    <p:documentation>Whether to display progress information as text files in a certain directory</p:documentation>
  </p:option>
  
  <p:input port="conf" primary="true"/>
  <p:output port="result" primary="true"/>
  
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
      <p:pipe port="conf" step="transpect-paths"/>
    </p:input>
  </bc:paths>
  
</p:declare-step>