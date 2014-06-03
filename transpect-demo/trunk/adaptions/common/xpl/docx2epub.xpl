<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:bc="http://transpect.le-tex.de/book-conversion"
  xmlns:docx2hub="http://www.le-tex.de/namespace/docx2hub"
  xmlns:hub2htm="http://www.le-tex.de/namespace/hub2htm"
  xmlns:transpect="http://www.le-tex.de/namespace/transpect"
  xmlns:trdemo="http://www.le-tex.de/namespace/trdemo"
  xmlns:letex="http://www.le-tex.de/namespace"
  name="docx2epub"
  type="trdemo:docx2epub"
  version="1.0">
  
  <p:documentation>
    This step expects a Word DOCX file and converts it to Docbook, 
    EPUB and provides a HTML checking report.
  </p:documentation>
  
  <p:input port="conf" primary="true">
    <p:documentation>
      The conf port expects the Transpect configuration file.
    </p:documentation>
    <p:document href="http://customers.le-tex.de/generic/book-conversion/conf/conf.xml"/>
  </p:input>
  <p:input port="schema" primary="false">
    <p:documentation>Excepts the Docbook 5.0 RNG schema</p:documentation>
    <p:document href="http://www.le-tex.de/resource/schema/docbook/5.0/docbook.rng"/>
  </p:input>
  
  <p:output port="hub" primary="false">
    <p:documentation>
      The 'hub' output port provides the evolved hub including srcpaths.
    </p:documentation>
    <p:pipe port="result" step="evolve-hub-dyn"/>
  </p:output>
  <p:output port="flat-hub" primary="false">
    <p:documentation>
      The 'flat-hub' output port provides the flat hub file derived from docx conversion.
    </p:documentation>
    <p:pipe port="result" step="docx2hub"/>
  </p:output>
  <p:output port="docbook" primary="false">
    <p:documentation>
      The 'docbook' output port provides Docbook-flavoured XML.
    </p:documentation>
    <p:pipe port="result" step="remove-srcpath-from-docbook"/>
  </p:output>
  <p:output port="schematron" primary="false">
    <p:documentation>
      The 'schematron' output port provides the collected reports of all schematron checks.
    </p:documentation>
    <p:pipe port="result" step="errorPI2svrl"/>
  </p:output>
  <p:output port="html" primary="false">
    <p:documentation>
      The 'html' output port provides a HTML file 
    </p:documentation>
    <p:pipe port="result" step="remove-srcpath-from-html"/>
  </p:output>
  <p:output port="htmlreport" primary="false">
    <p:documentation>
      The 'htmlreport' output port provides the HTML report file with Schematron and RelaxNG messages.
    </p:documentation>
    <p:pipe port="result" step="htmlreport"/>
  </p:output>
  <p:output port="result" primary="true">
    <p:documentation>
      The 'epub' output port provides the result of the EPUB conversion.
    </p:documentation>
    <p:pipe port="result" step="epub-convert"/>
  </p:output>
  
  <p:serialization port="docbook" omit-xml-declaration="false"/>
  <p:serialization port="hub" omit-xml-declaration="false"/>
  
  <p:option name="docxfile" required="true">
    <p:documentation>
      The path to the DOCX file.
    </p:documentation>
  </p:option>
  <p:option name="hub-version" select="'1.1'">
    <p:documentation>
      The version of the HUB XML Format. See https://github.com/le-tex/Hub for the RelaxNG schema. 
    </p:documentation>
  </p:option>
  
  <p:option name="publisher" select="''" required="false">
    <p:documentation>
      Used to set the publisher statically. If this option is not set, the 
      step named "paths" will determine the publisher name by the input filename.
    </p:documentation>
  </p:option>
  <p:option name="series" select="''" required="false">
    <p:documentation>
      Used to set the book series statically. If this option is not set, the 
      step named "paths" will determine the series name by the input filename.
    </p:documentation>
  </p:option>
  <p:option name="work" select="''" required="false">
    <p:documentation>
      Used to set the work statically. If this option is not set, the 
      step named "paths" will determine the work name by the input filename.
    </p:documentation>
  </p:option>
  
  <p:option name="debug" select="'no'">
    <p:documentation>
      Used to switch debug mode on or off. Pass 'yes' to enable debug mode.
    </p:documentation>
  </p:option> 
  <p:option name="debug-dir-uri" select="'debug'">
    <p:documentation>
      Expects a file URI of the directory that should be used to store debug information. 
    </p:documentation>
  </p:option>
  
  <p:option name="progress" required="false" select="'yes'">
    <p:documentation>
      Whether to display progress information as text files in a certain directory
    </p:documentation>
  </p:option>
  <p:option name="check" required="false" select="'yes'">
    <p:documentation>
      Pass "yes" to enable checking with Schematron.
    </p:documentation>
  </p:option>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.le-tex.de/docx2hub/wml2hub.xpl"/>
  <p:import href="http://transpect.le-tex.de/hub2html/xpl/hub2html.xpl"/>
  <p:import href="http://transpect.le-tex.de/hub2docbook/xpl/hub2docbook.xpl"/>  
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/evolve-hub.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/empty-report.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/validate-with-schematron.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/check-styles.xpl"/>
  <p:import href="http://transpect.le-tex.de/xproc-util/store-debug/store-debug.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/errorPI2svrl.xpl"/>
  <p:import href="http://transpect.le-tex.de/calabash-extensions/ltx-validate-with-rng/rng-validate-to-PI.xpl"/>
  
  <p:import href="paths.xpl"/>
  <p:import href="epub.xpl"/>
  
  <trdemo:paths name="paths"> 
    <p:with-option name="pipeline" select="'docx2epub.xpl'"/> 
    <p:with-option name="publisher" select="$publisher"/> 
    <p:with-option name="series" select="$series"/> 
    <p:with-option name="work" select="$work"/> 
    <p:with-option name="file" select="$docxfile"/> 
    <p:with-option name="debug" select="$debug"/> 
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/> 
    <p:with-option name="progress" select="$progress"/> 
    <p:input port="conf"> 
      <p:pipe port="conf" step="docx2epub"/> 
    </p:input>
  </trdemo:paths>
    
  <docx2hub:convert name="docx2hub">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="docx" select="/c:param-set/c:param[@name eq 'file']/@value"/>
    <p:with-option name="hub-version" select="$hub-version"/>
    <p:with-option name="srcpaths" select="'yes'"/>
  </docx2hub:convert>
  
  <bc:evolve-hub name="evolve-hub-dyn" srcpaths="yes">
    <p:documentation>
      Build headline hierarchy, detect lists, figure captions etc.
    </p:documentation>
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </bc:evolve-hub>

  <p:sink/>
  
  <bc:empty-report name="create-empty-report">
    <p:with-option name="pipeline" select="'docx2epub'"/>
  </bc:empty-report>
  
  <p:sink/>
  
  <bc:check-styles name="check-styles">
    <p:input port="source">
      <p:pipe port="result" step="evolve-hub-dyn"/>
    </p:input>
    <p:input port="html-in">
      <p:empty/>
    </p:input>
    <p:input port="report-in">
      <p:pipe port="result" step="create-empty-report"/>
    </p:input>
    <p:input port="parameters">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="active" select="$check"/>
  </bc:check-styles>
  
  <bc:validate-with-schematron name="validate-business-rules">
    <p:input port="html-in">
      <p:empty/>
    </p:input>
    <p:input port="report-in">
      <p:pipe port="report" step="check-styles"/>
    </p:input>
    <p:input port="parameters">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-param name="family" select="'business-rules'"/>
    <p:with-param name="step-name" select="'validate-business-rules'"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="active" select="$check"/>
  </bc:validate-with-schematron>
  
  <p:sink/>
  
  <letex:hub2docbook name="hub2docbook">
    <p:input port="source">
      <p:pipe port="result" step="evolve-hub-dyn"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </letex:hub2docbook>
  
  <!-- remove srcpaths -->
  <p:delete match="@srcpath" name="remove-srcpath-from-docbook"/>  
  
  <letex:validate-with-rng-PI name="rng2pi">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:input port="schema">
      <p:pipe port="schema" step="docx2epub"/>
    </p:input>
  </letex:validate-with-rng-PI>
  
  <letex:store-debug pipeline-step="rngvalid/with-PIs">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </letex:store-debug>
  
  <transpect:errorPI2svrl name="errorPI2svrl" severity="error">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:input port="report-in">
      <p:pipe port="report" step="validate-business-rules"/>
    </p:input>
  </transpect:errorPI2svrl>
  
  <hub2htm:convert name="hub2htm">
    <p:input port="source">
      <p:pipe port="result" step="evolve-hub-dyn"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:input port="other-params">
      <p:inline>
        <c:param-set>
          <c:param name="overwrite-image-paths" value="no"/>
          <c:param name="generate-toc" value="yes"/>
          <c:param name="generate-index" value="yes"/>
        </c:param-set>
      </p:inline>
    </p:input>
    <p:with-param name="html-title" select="/c:param-set/c:param[@name eq 'work-basename']/@value">
      <p:pipe port="result" step="paths"/>
    </p:with-param>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </hub2htm:convert>
  
  <p:delete match="@srcpath" name="remove-srcpath-from-html"/>
  
  <transpect:patch-svrl name="htmlreport">
    <p:input port="source">
      <p:pipe port="result" step="hub2htm"/>
    </p:input>
    <p:input port="svrl">
      <p:pipe step="errorPI2svrl" port="report"/>
    </p:input>
    <p:input port="params">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-option name="severity-default-name" select="'Warning'"/>    
    <p:with-option name="report-title" select="/c:param-set/c:param[@name eq 'work-basename']/@value">
      <p:pipe port="result" step="paths"/>
    </p:with-option>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </transpect:patch-svrl>
  
  <trdemo:epub name="epub-convert">
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:input port="source">
      <p:pipe port="result" step="remove-srcpath-from-html"/>
    </p:input>
    <p:input port="report-in">
      <p:pipe port="report" step="validate-business-rules"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </trdemo:epub>
  
</p:declare-step>