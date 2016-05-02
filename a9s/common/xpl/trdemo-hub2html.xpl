<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:hub2htm="http://transpect.io/hub2htm"
  xmlns:trdemo="http://transpect.io/demo"
  name="trdemo-hub2html"
  type="trdemo:hub2html"
  version="1.0">
  
  <p:input port="source" primary="true"/>
  
  <p:input port="paths" primary="false"/>
  
  <p:output port="result"/>
  
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:import href="http://transpect.io/hub2html/xpl/hub2html.xpl"/>
  
  <hub2htm:convert name="hub2htm-convert">
    <p:input port="source">
      <p:pipe port="source" step="trdemo-hub2html"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="paths" step="trdemo-hub2html"/>
    </p:input>
    <p:input port="other-params">
      <p:inline>
        <c:param-set>
          <c:param name="overwrite-image-paths" value="no"/>
        </c:param-set>
      </p:inline>
    </p:input>
    <p:with-param name="html-title" select="/c:param-set/c:param[@name eq 'basename']/@value">
      <p:pipe port="paths" step="trdemo-hub2html"/>
    </p:with-param>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/> 
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </hub2htm:convert>
  
</p:declare-step>