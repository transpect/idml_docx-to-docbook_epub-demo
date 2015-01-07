<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:docx2hub="http://www.le-tex.de/namespace/docx2hub"
	xmlns:hub2htm="http://www.le-tex.de/namespace/hub2htm"
	xmlns:transpect="http://www.le-tex.de/namespace/transpect"
	xmlns:letex="http://www.le-tex.de/namespace"
	xmlns:trdemo="http://www.le-tex.de/namespace/transpect-demo"
	name="trdemo-main"
	type="trdemo:main"
	version="1.0">
	
	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		This ist the initial pipeline for the transpect demo.
	</p:documentation>
	
	<!-- input port declarations -->
	
	<p:input port="conf" primary="true">
	  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	    <p>The 'conf' port expects the Transpect configuration file. Please see <a href="https://subversion.le-tex.de/common/transpect-demo/content/le-tex/setup-manual/en/out/xhtml/transpect-setup.xhtml#sec-cascade">here</a> for further information.</p> 
		</p:documentation>
		<p:document href="http://customers.le-tex.de/generic/book-conversion/conf/conf.xml"/>
	</p:input>
	
	<p:input port="schema" primary="false">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">Excepts the Docbook 5.0 RNG schema</p:documentation>
		<p:document href="http://www.le-tex.de/resource/schema/docbook/5.0/docbook.rng"/>
	</p:input>
	
	<!-- output port declarations -->

	<p:output port="result" primary="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			The 'result' output port provides the xml file.
		</p:documentation>
	</p:output>
	
	<p:output port="docbook" primary="false">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			The 'docbook' output port provides Docbook-flavoured XML.
		</p:documentation>
		<p:pipe port="result" step="strip-srcpath-from-dbk"/>
	</p:output>
	
	<p:output port="html" primary="false">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			The 'html' output port provides a HTML file 
		</p:documentation>
		<p:pipe port="result" step="strip-srcpath-from-html"/>
	</p:output>

	<!-- output port serialization -->
	
  <p:serialization port="result" method="xhtml" media-type="application/xhtml+xml"/>
  <p:serialization port="html" method="xhtml" media-type="application/xhtml+xml" indent="true"/>
  <p:serialization port="docbook" omit-xml-declaration="false"/>
	
	<!-- options -->
	
	<p:option name="file" required="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			The path to the input file.
		</p:documentation>
	</p:option>
	
	<p:option name="hub-version" select="'1.1'">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			The version of the HUB XML Format. See https://github.com/le-tex/Hub for the RelaxNG schema. 
		</p:documentation>
	</p:option>
	
	<p:option name="publisher" select="''">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			Used to set the publisher statically. If this option is not set, the 
			step named "paths" will determine the publisher name by the input filename.
		</p:documentation>
	</p:option>
	
	<p:option name="series" select="''">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			Used to set the book series statically. If this option is not set, the 
			step named "paths" will determine the series name by the input filename.
		</p:documentation>
	</p:option>
	
	<p:option name="work" select="''">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			Used to set the work statically. If this option is not set, the 
			step named "paths" will determine the work name by the input filename.
		</p:documentation>
	</p:option>
	
	<p:option name="debug" select="'yes'">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			Used to switch debug mode on or off. Pass 'yes' to enable debug mode.
		</p:documentation>
	</p:option> 
	
	<p:option name="debug-dir-uri" select="'debug'">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			Expects a file URI of the directory that should be used to store debug information. 
		</p:documentation>
	</p:option>
	
	<p:option name="status-dir-uri" select="'status'">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			Expects URI where the text files containing the progress information are stored.
		</p:documentation>
	</p:option>
		
	<!-- import external modules -->
	
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />  
	<p:import href="http://transpect.le-tex.de/xproc-util/store-debug/store-debug.xpl" />
	<p:import href="http://transpect.le-tex.de/hub2html/xpl/hub2html.xpl"/>
	<p:import href="http://transpect.le-tex.de/htmlreports/xpl/patch-svrl.xpl"/>
	
	<!-- import local modules -->
	
	<p:import href="trdemo-paths.xpl"/>
	<p:import href="trdemo-convert-input.xpl"/>
	<p:import href="trdemo-validate.xpl"/>
	<p:import href="trdemo-hub2dbk.xpl"/>
	<p:import href="trdemo-epub-convert.xpl"/>

	<trdemo:paths name="trdemo-paths">
		<p:input port="conf">
			<p:pipe port="conf" step="trdemo-main"/> 
		</p:input>
		<p:with-option name="file" select="$file"/> 
		<p:with-option name="debug" select="$debug"/> 
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
	  <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</trdemo:paths>
	
	<trdemo:convert-input name="trdemo-convert-input">
		<p:with-option name="debug" select="$debug"/> 
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
	  <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</trdemo:convert-input>
	
	<trdemo:hub2dbk name="hub2dbk">
	  <p:input port="paths">
	    <p:pipe port="result" step="trdemo-paths"/> 
	  </p:input>
		<p:with-option name="debug" select="$debug"/> 
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
	  <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</trdemo:hub2dbk>
	
	<p:delete match="@srcpath" name="strip-srcpath-from-dbk"/>
	
	<letex:store-debug pipeline-step="trdemo/trdemo-hub2dbk">
		<p:with-option name="active" select="$debug"/>
		<p:with-option name="base-uri" select="$debug-dir-uri"/>
	</letex:store-debug>
	
	<p:sink/>
	
	<trdemo:validate name="trdemo-validate">
		<p:input port="source">
			<p:pipe port="result" step="hub2dbk"/>
		</p:input>
		<p:input port="paths">
			<p:pipe port="result" step="trdemo-paths"/> 
		</p:input>
		<p:with-option name="debug" select="$debug"/> 
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
	  <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</trdemo:validate>
  
  <letex:store-debug pipeline-step="trdemo/trdemo-validate">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </letex:store-debug>
	
	<hub2htm:convert name="hub2htm-convert">
		<p:input port="source">
		  <p:pipe port="result" step="trdemo-convert-input"/>
		</p:input>
		<p:input port="paths">
			<p:pipe port="result" step="trdemo-paths"/>
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
	  <p:with-param name="html-title" select="/c:param-set/c:param[@name eq 'basename']/@value">
			<p:pipe port="result" step="trdemo-paths"/>
		</p:with-param>
		<p:with-option name="debug" select="$debug"/>
		<p:with-option name="debug-dir-uri" select="$debug-dir-uri"/> 
	  <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</hub2htm:convert>
	
	<p:delete match="@srcpath" name="strip-srcpath-from-html"/>
  
  <trdemo:epub-convert name="trdemo-epub-convert">
    <p:input port="source">
      <p:pipe port="result" step="strip-srcpath-from-html"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="result" step="trdemo-paths"/>
    </p:input>
    <!-- construct default srcpath from 1st element containing a scrpath attribute -->
    <p:with-option name="svrl-srcpath" select="concat(
      /*:hub/*:info/*:keywordset[@role eq 'hub']/*:keyword[@role eq 'source-dir-uri'],
      (/*:hub//*[@srcpath])[1]/@srcpath
      )">
      <p:pipe port="result" step="trdemo-convert-input"/>
    </p:with-option>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </trdemo:epub-convert>
	
	<transpect:patch-svrl name="htmlreport">
		<p:input port="source">
			<p:pipe port="result" step="hub2htm-convert"/>
		</p:input>
		<p:input port="reports">
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
	</transpect:patch-svrl>
	
</p:declare-step>