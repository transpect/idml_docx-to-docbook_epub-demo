<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:bc="http://transpect.le-tex.de/book-conversion"
  xmlns:docx2hub = "http://www.le-tex.de/namespace/docx2hub"
  xmlns:transpect="http://www.le-tex.de/namespace/transpect"
  xmlns:letex="http://www.le-tex.de/namespace"
  name="docx2epub_and_docx2idml"
  version="1.0">
  
  <p:input port="conf" primary="true">
    <p:document href="http://customers.le-tex.de/generic/book-conversion/conf/conf.xml"/>
  </p:input>

  <p:input port="schema" primary="false">
    <p:documentation>See input port schema in docx2epub.xpl</p:documentation>
    <p:document href="http://www.le-tex.de/resource/schema/hub/1.1/hub.rng"/>
  </p:input>

  <p:output port="flat-hub">
    <p:pipe port="flat-hub" step="docx2epub"/>
  </p:output>
  <p:output port="evolved-hub">
    <p:pipe port="hub" step="docx2epub"/>
  </p:output>
  <p:output port="htmlreport">
    <p:pipe port="htmlreport" step="docx2epub"/>
  </p:output>
  <p:output port="schematron">
    <p:pipe port="schematron" step="docx2epub"/>
  </p:output>
  <p:output port="html">
    <p:pipe port="html" step="docx2epub"/>
  </p:output>
  
  <p:option name="docxfile" required="true"/>
  <p:option name="idml-target-uri" required="true"/>
  <p:option name="epub-target-uri" required="true"/>
  <p:option name="hub-target-uri" required="true"/>
  <p:option name="final-zip-target-uri" required="true"/>
  <p:option name="hub-version" select="'1.1'"/>
  
  <p:option name="publisher" select="''" required="false"/>
  <p:option name="series" select="''" required="false"/> 
  <p:option name="work" select="''" required="false"/> 
  
  <p:option name="progress" select="'yes'"/>
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="paths.xpl"/>
  <p:import href="docx2epub.xpl"/>
  <p:import href="http://transpect.le-tex.de/xml2idml/xpl/xml2idml.xpl" />
  <p:import href="http://transpect.le-tex.de/xproc-util/store-zip/xpl/store-zip.xpl"/>
  
  <transpect:paths name="paths"> 
    <p:with-option name="pipeline" select="'docx2epub_and_docx2idml.xpl'"/> 
    <p:with-option name="publisher" select="$publisher"/> 
    <p:with-option name="series" select="$series"/> 
    <p:with-option name="work" select="$work"/> 
    <p:with-option name="file" select="$docxfile"/> 
    <p:with-option name="progress" select="$progress"/> 
    <p:with-option name="debug" select="$debug"/> 
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/> 
    <p:input port="conf"> 
      <p:pipe port="conf" step="docx2epub_and_docx2idml"/> 
    </p:input>
  </transpect:paths>

  <p:sink/>

  <!-- first main step: convert docx to epub-->
  <transpect:docx2epub name="docx2epub">
    <p:with-option name="docxfile" select="$docxfile"/>
    <p:with-option name="progress" select="$progress"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:input port="conf">
      <p:pipe port="conf" step="docx2epub_and_docx2idml"/>
    </p:input>
  </transpect:docx2epub>

  <p:sink/>

  <!-- second main step: convert hub (docx) to idml -->
  <bc:xml2idml name="hub2idml">
    <p:with-option name="template" select="'hub2idml/template.idml'" />
    <p:with-option name="mapping" select="'hub2idml/mapping.xml'"/>
    <p:with-option name="debug" select="$debug" />
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
    <p:with-option name="idml-target-uri" select="$idml-target-uri" />
    <p:input port="source">
      <p:pipe port="flat-hub" step="docx2epub"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
  </bc:xml2idml>

  <p:sink/>

  <p:store name="save-hub-output-for-store-zip" cx:depends-on="hub2idml"
    method="xml" encoding="UTF-8" omit-xml-declaration="false">
    <p:input port="source">
      <p:pipe port="hub" step="docx2epub"/>
    </p:input>
    <p:with-option name="href" select="concat('file:', $hub-target-uri)"/>
  </p:store>

  <!-- zip output and binaries -->
  <letex:store-zip name="zip-images-and-binaries" cx:depends-on="save-hub-output-for-store-zip">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="target-zip-uri" select="$final-zip-target-uri"/>
    <p:with-option name="additional-file-uris-to-zip-root" 
      select="string-join(
                ($idml-target-uri, $docxfile, $epub-target-uri, $hub-target-uri), 
                ' file:'
              )"/>
  </letex:store-zip>

  <p:sink/>

</p:declare-step>