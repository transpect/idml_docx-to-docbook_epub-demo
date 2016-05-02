<?xml version="1.0" encoding="utf-8"?>
<p:declare-step
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:tr="http://transpect.io"
  xmlns:trdemo="http://transpect.io/demo"
  version="1.0"
  name="trdemo-paths"
  type="trdemo:paths">
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <h1>trdemo:paths</h1>
    <p>The paths step evaluates dynamically publisher, book series, work name and paths 
      by the input filename. It provides a c:param-set document for subsequent steps.</p>
  </p:documentation>

  <p:input port="conf" primary="true"/>
  
  <p:output port="result" primary="true"/>
	
  <p:output port="report" sequence="true">
    <p:pipe port="report" step="paths"/>
  </p:output>
	
  <p:option name="file" required="false" select="''"/>
  <p:option name="pipeline" select="'unknown'"/>
  
  <p:option name="debug" select="'yes'"/> 
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="progress" select="'yes'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:option name="interface-language" select="'en'"/>
  <p:option name="clades" select="''"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/paths.xpl"/>
	<p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  <p:import href="http://transpect.io/calabash-extensions/transpect-lib.xpl"/>
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <!--  *
        * normalize the file URI. The unzip step takes the output of this step.
        * -->
  <tr:file-uri name="file-uri">
    <p:with-option name="filename" select="$file"/>
  </tr:file-uri>
  
  <tr:store-debug pipeline-step="trdemo/file-uri">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

  <p:choose>
    <!--  *
          * Check if the file is a Zip archive. Otherwise simply clone the input.
          * -->
    <p:when test="matches($file, '^.+\.zip$', 'i')">
      <!--  *
            * Unzip the file and generate URI with existing DOCX or IDML files.
            * -->
      <tr:unzip name="unzip">
        <p:with-option name="zip" select="/c:result/@os-path" />
        <p:with-option name="dest-dir" select="concat(/c:result/@os-path, '.tmp')"/>
        <p:with-option name="overwrite" select="'yes'" />
      </tr:unzip>
      
      <tr:store-debug pipeline-step="trdemo/unzip">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
      
      <p:group>
        <!--  *
              * use first docx or idml file in the directory
              * -->
        <p:variable name="filename" select="replace(//c:file[matches(@name, '^.+\.(idml|docx)$', 'i')][1]/@name, '^.+/(.+)$', '$1')"/>
        <p:variable name="target" select="concat(/c:files/@xml:base, '/../', $filename)"/>
        <!--  *
              * copy IDML file in main output directory
              * -->
        <cxf:copy name="copy" fail-on-error="true" cx:depends-on="unzip">
          <p:with-option name="href" select="concat(/c:files/@xml:base,
            //c:file[matches(@name, '^.+\.(idml|docx)$', 'i')][1]/@name)"/>
          <p:with-option name="target" select="$target"/>
        </cxf:copy>
        
        <!--  *
              * normalize the URI of the first IDML or DOCX file found in the 
              * uncompressed archive
              * -->
        <tr:file-uri cx:depends-on="copy">
          <p:with-option name="filename" select="$target">
            <p:pipe port="result" step="unzip"/>
          </p:with-option>
        </tr:file-uri>
      </p:group>
      
    </p:when>
    <p:otherwise>
      <!--  * 
            * clone the input from step file-uri above 
            * -->
      <p:identity>
        <p:input port="source">
          <p:pipe port="result" step="file-uri"/>
        </p:input>
      </p:identity>
      
    </p:otherwise>
  </p:choose>
  
  <p:identity name="identity-file-uri"/>
    
  <tr:simple-progress-msg file="trdemo-paths.txt">
		<p:input port="msgs">
			<p:inline>
				<c:messages>
					<c:message xml:lang="en">Generating File Paths</c:message>
					<c:message xml:lang="de">Generiere Dateisystempfade</c:message>
				</c:messages>
			</p:inline>
		</p:input>
		<p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</tr:simple-progress-msg>
  <!--  *
        * import XSLT library including various functions to calculate a set of 
        * parameters for subsequent XProc steps. The parameters are the URLs of the 
        * directories where the transpect looks for customized settings Its variables 
        * are overwritten with the tr:paths step below.
        * -->
  <p:load name="import-paths-xsl">
    <p:with-option name="href" select="resolve-uri('../xsl/trdemo-paths.xsl')"/>
  </p:load>
  <!--  *
        * The tr:paths step takes the imported Stylesheet as primary and the 
        * configuration file as secondary input.
        * -->  
  <tr:paths name="paths" determine-transpect-project-version="yes">
    <p:with-option name="pipeline" select="$pipeline"/>
    <p:with-option name="interface-language" select="$interface-language"/>
    <p:with-option name="clades" select="$clades"/>
    <p:with-option name="file" select="/c:result/@href">
      <p:pipe port="result" step="identity-file-uri"/>
    </p:with-option>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>  
    <p:with-option name="progress" select="$progress"/>
    <p:input port="conf">
      <p:pipe port="conf" step="trdemo-paths"/>
    </p:input>
  </tr:paths>
  
</p:declare-step>