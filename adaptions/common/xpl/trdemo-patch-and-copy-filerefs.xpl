<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:trdemo="http://www.le-tex.de/namespace/transpect-demo"
  name="trdemo-patch-and-copy-filerefs"
  type="trdemo:patch-and-copy-filerefs"
  version="1.0">
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <h1>trdemo:patch-and-copy-filerefs</h1>
    <p>This step patches absolute and relative file references in a Hub file. The new location 
      is relative to the file-uri provided in the paths document. Accordingly, the referenced 
      files are copied to the new location.</p>
  </p:documentation>
  
  <p:input port="source" primary="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h3>Input port: <code>source</code></h3>
      <p>The primary input port expects a Hub document.</p>
    </p:documentation>
  </p:input>
  <p:input port="paths" primary="false">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h3>Input port: <code>paths</code></h3>
      <p>The secondary input port expects the transpect paths document.</p>
    </p:documentation>
  </p:input>
  
  <p:output port="result">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h3>Output port: <code>result</code></h3>
      <p>The output port provides the hub document with patched file references.</p>
    </p:documentation>
  </p:output>
  
  <p:option name="assets-dirname" select="'assets'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h3>Option: <code>assets-dirname</code></h3>
      <p>Designated name of assets directory</p>
    </p:documentation>
  </p:option>
  
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.le-tex.de/xproc-util/file-uri/file-uri.xpl"/>
  <p:import href="http://transpect.le-tex.de/xproc-util/store-debug/store-debug.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/simple-progress-msg.xpl"/>
  
  <letex:simple-progress-msg name="success-msg" file="patch-filerefs.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Patch file references and copy files.</c:message>
          <c:message xml:lang="de">Patche Dateireferenzen und kopiere Dateien.</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </letex:simple-progress-msg>
  
  <!--  *
        * iterate over each imagedata element  
        * -->
  <p:for-each name="file-iteration">
    <p:iteration-source select="//*:imageobject/*:imagedata"/>
    <!--  *
          * get source-dir-uri of input file from hub document.  
          * -->
    <p:variable name="source-dir-uri" select="/*/*:info/*:keywordset[@role eq 'hub']/*:keyword[@role eq 'source-dir-uri']">
      <p:pipe step="trdemo-patch-and-copy-filerefs" port="source"/>
    </p:variable>
    <!--  *
          * evaluate target directory from file URI of the input file. 
          * -->
    <p:variable name="target-dir" select="concat(replace(/c:param-set/c:param[@name eq 'file']/@value, '^(.+)/.+$', '$1'), '/', $assets-dirname, '/')">
      <p:pipe step="trdemo-patch-and-copy-filerefs" port="paths"/>
    </p:variable>
    <!--  *
          * strip filename from file path  
          * -->
    <p:variable name="filename" select="replace(*:imagedata/@fileref, '^.+/(.+)$', '$1')"/>
    
    <cx:message xmlns:cx="http://xmlcalabash.com/ns/extensions">
      <p:with-option name="message" select="concat('copy ',replace(*:imagedata/@fileref, '^container:', $source-dir-uri ), ' to ', $target-dir )"/>
    </cx:message>
    
    <cxf:copy fail-on-error="true">
      <p:with-option name="href" select="replace(*:imagedata/@fileref, '^container:', $source-dir-uri )">
        <p:pipe port="current" step="file-iteration"/>
      </p:with-option> 
      <p:with-option name="target" select="concat($target-dir, $filename)"/>
    </cxf:copy>
    
  </p:for-each>
  
  <!--  *
        * patch file references according to the file paths above
        * -->
  <p:xslt name="normalize-filerefs">
    <p:input port="source">
      <p:pipe step="trdemo-patch-and-copy-filerefs" port="source"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xsl/trdemo-patch-and-copy-filerefs.xsl"/>
    </p:input>
    <p:with-param name="assets-dirname" select="$assets-dirname"/>
  </p:xslt>
  
  <letex:store-debug pipeline-step="trdemo/patch-and-copy-filerefs">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </letex:store-debug>
  
</p:declare-step>