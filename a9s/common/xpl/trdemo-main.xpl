<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:tr="http://transpect.io"
	xmlns:trdemo="http://transpect.io/demo"
	name="trdemo-main"
	type="trdemo:main"
	version="1.0">
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <h1>trdemo:main</h1>
    <p>This is the frontend pipeline for the transpect demo. It checks and converts 
      a DOCX or IDML file to HTML, EPUB and Docbook XML and provides an HTML report.</p>
  </p:documentation>
	
	<!-- input port declarations -->
	
	<p:input port="conf" primary="true">
	  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	    <h3>Input port: <code>conf</code></h3>
	    <p>The 'conf' port expects the Transpect configuration file. Please see <a href="https://subversion.le-tex.de/common/transpect-demo/content/le-tex/setup-manual/en/out/xhtml/transpect-setup.xhtml#sec-cascade">here</a> 
	      for further information.</p> 
		</p:documentation>
		<p:document href="http://this.transpect.io/conf/transpect-conf.xml"/>
	</p:input>
	
	<p:input port="schema" primary="false">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		  <h3>Input port: <code>schema</code></h3>
		  <p>Expects a RelaxNG schema for Docbook 5.0.</p>
		</p:documentation>
	  <p:document href="http://www.docbook.org/xml/5.0/rng/docbook.rng"/>
	</p:input>
	
	<!-- output port declarations -->

	<p:output port="result" primary="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		  <h3>Output port: <code>result</code></h3>
			<p>The output port provides the HTML report with the Schematron 
			  and RelaxNG validation report messages.</p>
		</p:documentation>
	</p:output>
	
	<p:output port="docbook" primary="false">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		  <h3>Output port: <code>docbook</code></h3>
      <p>The output port provides a Docbook 5.0 XML document.</p>
		</p:documentation>
		<p:pipe port="result" step="strip-srcpath-from-dbk"/>
	</p:output>
	
	<p:output port="docbook-htmltables" primary="false">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		  <h3>Output port: <code>docbook</code></h3>
      <p>The output port provides a Docbook 5.0 XML document.</p>
		</p:documentation>
		<p:pipe port="result" step="strip-srcpath-from-dbk-htmltables"/>
	</p:output>
	
	<p:output port="html" primary="false">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		  <h3>Output port: <code>html</code></h3>
		  <p>The output port provides a XHTML document.</p> 
		</p:documentation>
		<p:pipe port="result" step="strip-srcpath-from-html"/>
	</p:output>

	<!-- output port serialization -->
	
  <p:serialization port="result" method="xhtml" media-type="application/xhtml+xml"/>
  <p:serialization port="html" method="xhtml" media-type="application/xhtml+xml"/>
  <p:serialization port="docbook" omit-xml-declaration="false"/>
	
	<!-- options -->
	
	<p:option name="file" required="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		  <h3>Option: <code>file</code></h3>
			<p>The path to the input file.</p>
		</p:documentation>
	</p:option>
		
	<p:option name="debug" select="'yes'">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		  <h3>Option: <code>debug</code></h3>
			<p>Used to switch debug mode on or off. Pass 'yes' to enable debug mode.</p>
		</p:documentation>
	</p:option> 
	
	<p:option name="debug-dir-uri" select="'debug'">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		  <h3>Option: <code>debug-dir-uri</code></h3>
			<p>File URI to the directory used to store debug information.</p> 
		</p:documentation>
	</p:option>
	
	<p:option name="status-dir-uri" select="'status'">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		  <h3>Option: <code>debug-dir-uri</code></h3>
			<p>File URI to the directory where the status files are stored. The status files 
			  can be used by a third party software to show status messages in an user interface.</p>
		</p:documentation>
	</p:option>
		
	<!-- import external modules -->
	
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	<p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
	<p:import href="http://transpect.io/htmlreports/xpl/patch-svrl.xpl"/>
	<p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
	
	<!-- import local modules -->
	
	<p:import href="trdemo-paths.xpl"/>
	<p:import href="trdemo-convert-input.xpl"/>
	<p:import href="trdemo-validate.xpl"/>
	<p:import href="trdemo-hub2dbk.xpl"/>
  <p:import href="trdemo-hub2html.xpl"/>
	<p:import href="trdemo-epub-convert.xpl"/>

	<tr:file-uri name="file-uri">
    <p:with-option name="filename" select="$file"/>
  </tr:file-uri>

	<trdemo:paths name="trdemo-paths">
		<p:input port="conf">
			<p:pipe port="conf" step="trdemo-main"/> 
		</p:input>
		<p:input port="params">
			<p:empty/>
		</p:input>
		<p:with-option name="file" select="/*/@local-href"/> 
		<p:with-option name="debug" select="$debug"/> 
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
	  <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</trdemo:paths>
	
	<trdemo:convert-input name="trdemo-convert-input">
		<p:with-option name="debug" select="$debug"/> 
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
	  <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</trdemo:convert-input>
	
	<trdemo:hub2dbk name="trdemo-hub2dbk">
	  <p:input port="paths">
	    <p:pipe port="result" step="trdemo-paths"/> 
	  </p:input>
		<p:with-option name="debug" select="$debug"/> 
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
	  <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</trdemo:hub2dbk>
	
	<tr:store-debug pipeline-step="trdemo/trdemo-hub2dbk">
		<p:with-option name="active" select="$debug"/>
		<p:with-option name="base-uri" select="$debug-dir-uri"/>
	</tr:store-debug>
	
	<p:delete match="@srcpath" name="strip-srcpath-from-dbk"/>
	
	<p:sink/>

	<p:delete match="@srcpath" name="strip-srcpath-from-dbk-htmltables">
		<p:input port="source">
			<p:pipe port="dbk-htmltables" step="trdemo-hub2dbk"/>
		</p:input>
	</p:delete>
	
	<tr:store-debug pipeline-step="trdemo/trdemo-hub2dbk-htmltables">
		<p:with-option name="active" select="$debug"/>
		<p:with-option name="base-uri" select="$debug-dir-uri"/>
	</tr:store-debug>
	
	<p:sink/>

	<trdemo:validate name="trdemo-validate">
		<p:input port="source">
		  <p:pipe port="result" step="trdemo-hub2dbk"/>
		</p:input>
		<p:input port="paths">
			<p:pipe port="result" step="trdemo-paths"/> 
		</p:input>
		<p:with-option name="debug" select="$debug"/> 
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
	  <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</trdemo:validate>
  
  <tr:store-debug pipeline-step="trdemo/trdemo-validate">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
	
	<trdemo:hub2html name="trdemo-hub2html">
		<p:input port="source">
		  <p:pipe port="result" step="trdemo-hub2dbk"/>
		</p:input>
		<p:input port="paths">
			<p:pipe port="result" step="trdemo-paths"/>
		</p:input>
		<p:with-option name="debug" select="$debug"/>
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/> 
	  <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</trdemo:hub2html>
	
	<p:delete match="@srcpath" name="strip-srcpath-from-html"/>
  
  <trdemo:epub-convert name="trdemo-epub-convert">
    <p:input port="paths">
      <p:pipe port="result" step="trdemo-paths"/>
    </p:input>
    <!-- construct default srcpath from 1st element containing a scrpath attribute -->
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </trdemo:epub-convert>
	
	<tr:patch-svrl name="htmlreport">
		<p:input port="source">
			<p:pipe port="result" step="trdemo-hub2html"/>
		</p:input>
		<p:input port="reports">
		  <p:pipe port="report" step="trdemo-convert-input"/>
			<p:pipe port="report" step="trdemo-validate"/>
		  <p:pipe port="report" step="trdemo-epub-convert"/>
		</p:input>
		<p:input port="params">
			<p:pipe port="result" step="trdemo-paths"/>
		</p:input>
		<p:with-option name="severity-default-name" select="'warning'"/>    
		<p:with-option name="report-title" select="/c:param-set/c:param[@name eq 'work-basename']/@value">
			<p:pipe port="result" step="trdemo-paths"/>
		</p:with-option>
		<p:with-option name="debug" select="$debug"/>
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
	  <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</tr:patch-svrl>
	
</p:declare-step>