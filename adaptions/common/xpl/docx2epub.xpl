<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:docx2hub="http://www.le-tex.de/namespace/docx2hub"
  xmlns:transpect="http://www.le-tex.de/namespace/transpect"
  name="docx2epub">
  
  <p:input port="conf">
    <p:document href="../../../conf/conf.xml"/>
  </p:input>
  <p:input port="source">
    <p:empty/>
  </p:input>
  <p:output port="result"/>
  
  
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
  <p:import href="paths.xpl"/>
  
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
  
<!--
  <docx2hub:convert name="docx2hub"> 
    <p:with-option name="debug" select="$debug"/> 
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/> 
    <p:with-option name="docx" select="$docx"/> 
    <p:with-option name="hub-version" select="$hub-version"/> 
  </docx2hub:convert>-->
  
  <p:identity/>
</p:declare-step>