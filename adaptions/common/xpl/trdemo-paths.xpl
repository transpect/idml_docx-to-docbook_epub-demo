<?xml version="1.0" encoding="utf-8"?>
<p:declare-step
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:transpect="http://www.le-tex.de/namespace/transpect"
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:trdemo="http://www.le-tex.de/namespace/transpect-demo"
  version="1.0"
  name="trdemo-paths"
  type="trdemo:paths">
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <h1>trdemo:paths</h1>
    <p>The paths step evaluates dynamically publisher, book series, work name and paths 
      by the input filename. It provides a c:param-set document for subsequent steps.</p>
  </p:documentation>

  <p:input port="conf" primary="true"/>
  
  <p:input port="report-in">
    <p:inline>
    	<c:reports pipeline="trdemo-paths"/>
    </p:inline>
  </p:input>

  <p:output port="result" primary="true"/>
	
  <p:output port="report" primary="false">
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
  
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/paths.xpl"/>
	<p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/simple-progress-msg.xpl"/>
  <p:import href="http://transpect.le-tex.de/calabash-extensions/ltx-lib.xpl"/>
  <p:import href="http://transpect.le-tex.de/xproc-util/file-uri/file-uri.xpl"/>
  
  <!--  *
        * normalize the file URI. The unzip step takes the output of this step.
        * -->
  <transpect:file-uri name="file-uri">
    <p:with-option name="filename" select="$file"/>
  </transpect:file-uri>

  <p:choose>
    <!--  *
          * Check if the file is a Zip archive. Otherwise simply clone the input.
          * -->
    <p:when test="matches($file, '^.+\.zip$', 'i')">
      <!--  *
            * Unzip the file and generate URI with existing DOCX or IDML files.
            * -->
      <letex:unzip name="unzip">
        <p:with-option name="zip" select="/c:result/@os-path" />
        <p:with-option name="dest-dir" select="concat(/c:result/@os-path, '.tmp')"/>
        <p:with-option name="overwrite" select="'yes'" />
      </letex:unzip>
      <!--  *
            * normalize the URI of the first IDML or DOCX file found in the 
            * uncompressed archive
            * -->
      <transpect:file-uri>
        <p:with-option name="filename" select="concat(/c:files/@xml:base,
          //c:file[matches(@name, '^.+\.(idml|docx)$', 'i')][1]/@name)"/>
      </transpect:file-uri>
      
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
    
  <letex:simple-progress-msg file="trdemo-paths.txt">
		<p:input port="msgs">
			<p:inline>
				<c:messages>
					<c:message xml:lang="en">Generating File Paths</c:message>
					<c:message xml:lang="de">Generiere Dateisystempfade</c:message>
				</c:messages>
			</p:inline>
		</p:input>
		<p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</letex:simple-progress-msg>
  <!--  *
        * import XSLT library including various functions to calculate a set of 
        * parameters for subsequent XProc steps. The parameters are the URLs of the 
        * directories where the transpect looks for customized settings Its variables 
        * are overwritten with the transpect:paths step below.
        * -->
  <p:load name="import-paths-xsl">
    <p:with-option name="href" select="resolve-uri('../xsl/trdemo-paths.xsl')"/>
  </p:load>
  <!--  *
        * The transpect:paths step takes the imported Stylesheet as primary and the 
        * configuration file as secondary input.
        * -->  
  <transpect:paths name="paths" determine-transpect-project-version="yes">
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
  </transpect:paths>
  
</p:declare-step>