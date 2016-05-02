<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:tr="http://transpect.io"
  xmlns:trdemo="http://transpect.io/transpect-demo"
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
    <p:empty/>
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
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  <p:import href="http://transpect.io/xproc-util/recursive-directory-list/xpl/recursive-directory-list.xpl"/>
  
  <tr:simple-progress-msg name="start-msg" file="patch-filerefs.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Patch file references and copy files.</c:message>
          <c:message xml:lang="de">Patche Dateireferenzen und kopiere Dateien.</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>
  
  <p:sink/>
  
  <!--  * 
        * perform a directory listing recursively
        * -->
  <tr:recursive-directory-list name="directory-list">
    <p:with-option name="path" select="replace(/c:param-set/c:param[@name eq 'file']/@value, '^(.+)/.+?$', '$1')">
      <p:pipe port="paths" step="trdemo-patch-and-copy-filerefs"/>
    </p:with-option>
  </tr:recursive-directory-list>  

  <tr:store-debug pipeline-step="trdemo/directory-list">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:for-each>
    <!--  *
          * iterate over directories and subdirectories
          * -->
    <p:iteration-source select="//c:directory"/>
    <p:variable name="xmlbase" select="c:directory/@xml:base"/>
    <!--  *
          * iterate over all image files
          * -->
    <p:for-each name="file-iteration">
      <p:iteration-source select="c:directory/c:file[matches(@name, '^.+\.(ai|eps|pdf|png|jpeg|jpg|png|svg|tif|tiff)$', 'i')]"/>
      <!--  *
            * evaluate target directory from file URI of the input file. 
            * -->
      <p:variable name="target-dir" select="concat(replace(/c:param-set/c:param[@name eq 'file']/@value, '^(.+)/.+$', '$1'), '/', $assets-dirname, '/')">
        <p:pipe step="trdemo-patch-and-copy-filerefs" port="paths"/>
      </p:variable>
      <!--  *
            * strip filename from file path  
            * -->
      <p:variable name="href" select="concat($xmlbase, c:file/@name)"/>
      <p:variable name="filename" select="replace(c:file/@name, '^.+/(.+)$', '$1')"/>
      
      <cx:message xmlns:cx="http://xmlcalabash.com/ns/extensions">
        <p:with-option name="message" select="concat('copy ', c:file/@name, ' &gt;&gt;&gt; ', $target-dir )"/>
      </cx:message>
      
      <cxf:copy fail-on-error="true">
        <p:with-option name="href" select="$href">
          <p:pipe port="current" step="file-iteration"/>
        </p:with-option> 
        <p:with-option name="target" select="concat($target-dir, $filename)"/>
      </cxf:copy>
      
    </p:for-each>    
    
  </p:for-each>
  <!--  * 
        * this pipeline is used to normalize filerefs 
        * -->
  <p:xslt name="normalize-filerefs">
    <p:input port="source">
      <p:pipe step="trdemo-patch-and-copy-filerefs" port="source"/>
      <p:pipe step="directory-list" port="result"/>
    </p:input>
    <p:input port="parameters">
      <p:pipe step="trdemo-patch-and-copy-filerefs" port="paths"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xsl/trdemo-patch-and-copy-filerefs.xsl"/>
    </p:input>
    <p:with-param name="assets-dirname" select="$assets-dirname"/>
  </p:xslt>
      
</p:declare-step>