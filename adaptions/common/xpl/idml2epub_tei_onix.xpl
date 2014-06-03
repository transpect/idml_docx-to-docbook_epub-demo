<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:bc="http://transpect.le-tex.de/book-conversion"
  xmlns:docx2hub="http://www.le-tex.de/namespace/docx2hub"
  xmlns:hub2htm="http://www.le-tex.de/namespace/hub2htm"
  xmlns:hub2tei="http://www.le-tex.de/namespace/hub2tei"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:trdemo="http://www.le-tex.de/namespace/trdemo"
  xmlns:tei2html="http://www.le-tex.de/namespace/tei2html"
  xmlns:transpect="http://www.le-tex.de/namespace/transpect"
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:idml2xml  = "http://www.le-tex.de/namespace/idml2xml"
  xmlns:html="http://www.w3.org/1999/xhtml" 
  xmlns:epub="http://transpect.le-tex.de/epubtools"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  name="idml2epub_tei_onix"
  type="transpect:idml2epub_tei_onix"
  version="1.0">
  
  <p:input port="conf" primary="true">
    <p:document href="http://customers.le-tex.de/generic/book-conversion/conf/conf.xml"/>
  </p:input>

<!--  <p:input port="conf">
    <p:documentation>Either a configuration document or a paths document has to be supplied.
      The conf port needs to be non-empty if this is the top-level pipeline.</p:documentation>
    <p:inline>
      <nodoc/>
    </p:inline>
  </p:input>-->

  <p:input port="schema" primary="false">
    <p:documentation>Excepts the Hub RelaxNG XML schema</p:documentation>
    <p:document href="http://www.le-tex.de/resource/schema/hub/1.1/hub.rng"/>
  </p:input>

  <p:output port="hub" primary="false">
    <p:pipe port="result" step="idml2xml"/>
  </p:output>
<!--  <p:serialization port="hub" omit-xml-declaration="false"/>-->

  <p:output port="hubevolved" primary="false">
    <p:pipe port="result" step="delete-srcpath-inhierarchized-hub"/>
  </p:output>
  <p:serialization port="hubevolved" omit-xml-declaration="false"/>

  <p:output port="html" primary="false">
    <p:pipe port="result" step="remove-srcpath-from-html"/>
  </p:output>

  <p:output port="schematron" primary="false">
    <p:pipe port="result" step="errorPI2svrl"/>
  </p:output>
  
  <p:output port="htmlreport" primary="false">
    <p:pipe port="result" step="htmlreport"/>
  </p:output>

  <p:output port="tei" primary="false">
    <p:pipe port="result" step="hub2tei"/>
  </p:output>

  <p:output port="result" primary="true">
    <p:pipe port="result" step="epub-convert"/>
  </p:output>
   
  <p:option name="idmlfile" required="true"/>
  <p:option name="hub-version" select="'1.1'"/>
  
  <p:option name="series" select="'idml2epub_tei_onix'" required="false"/> 
  <p:option name="work" select="''" required="false"/> 
  <p:option name="publisher" select="'le-tex'" required="false"/>
  
  <p:option name="debug" select="'yes'"/> 
  <p:option name="debug-dir-uri" select="'debug'"/>
  
  <p:option name="progress" required="false" select="'yes'"/>
  <p:option name="check" required="false" select="'yes'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.le-tex.de/idml2xml/xpl/idml2hub.xpl"/>
  <p:import href="http://transpect.le-tex.de/hub2html/xpl/hub2html.xpl"/> 
  <p:import href="http://transpect.le-tex.de/hub2tei/xpl/hub2tei.xpl"/>
  <p:import href="http://transpect.le-tex.de/tei2html/xpl/tei2html.xpl"/>
  <p:import href="http://transpect.le-tex.de/htmltemplates/xpl/htmltemplates.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/evolve-hub.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/empty-report.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/validate-with-schematron.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/load-cascaded.xpl"/>
  <p:import href="http://transpect.le-tex.de/epubtools/epub-convert.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/check-styles.xpl"/>
  <p:import href="http://transpect.le-tex.de/xproc-util/store-debug/store-debug.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/errorPI2svrl.xpl"/>
  <p:import href="http://transpect.le-tex.de/calabash-extensions/ltx-validate-with-rng/rng-validate-to-PI.xpl"/>
 
  <p:import href="paths.xpl"/>
  <p:import href="epub.xpl"/>
      
  <trdemo:paths name="paths"> 
    <p:with-option name="pipeline" select="'idml2epub_tei_onix.xpl'"/> 
    <p:with-option name="publisher" select="$publisher"/> 
    <p:with-option name="series" select="$series"/> 
    <p:with-option name="work" select="$work"/> 
    <p:with-option name="file" select="$idmlfile"/> 
    <p:with-option name="debug" select="$debug"/> 
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/> 
    <p:with-option name="progress" select="$progress"/> 
    <p:input port="conf"> 
      <p:pipe port="conf" step="idml2epub_tei_onix"/> 
    </p:input>
  </trdemo:paths>

  <idml2xml:hub name="idml2xml">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="idmlfile" select="/c:param-set/c:param[@name eq 'file']/@value"/>
    <p:with-option name="hub-version" select="$hub-version"/>
    <p:with-option name="srcpaths" select="'yes'"/>
  </idml2xml:hub>

  <bc:evolve-hub name="evolve-hub-dyn" srcpaths="yes">
    <p:input port="source">
      <p:pipe port="result" step="idml2xml"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </bc:evolve-hub>

 <p:delete match="@srcpath" name="delete-srcpath-inhierarchized-hub"/>

  <p:sink/>
  
  <bc:empty-report name="create-empty-report">
    <p:with-option name="pipeline" select="'idml2epub_tei_onix'"/>
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

  <letex:validate-with-rng-PI name="rng2pi">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:input port="schema">
      <p:pipe port="schema" step="idml2epub_tei_onix"/>
    </p:input>
    <p:input port="source">
      <p:pipe port="result" step="evolve-hub-dyn"/>
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
      <p:pipe port="result" step="errorPI2svrl"/>
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

  <hub2tei:hub2tei name="hub2tei">
    <p:input port="source">
      <p:pipe port="result" step="evolve-hub-dyn"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </hub2tei:hub2tei>

  <tei2html:tei2html name="tei2html">
    <p:input port="source">
      <p:pipe port="result" step="hub2tei"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tei2html:tei2html>
  
  <p:sink/>
  
  <p:load name="meta">
    <p:with-option name="href" select="concat(/c:param-set/c:param[@name eq 'publisher-path']/@value, 'idml2epub_tei_onix/metadata/meta.xml')">
      <p:pipe port="result" step="paths"/>
    </p:with-option>
  </p:load>
  
  <p:sink/>
  
  <bc:load-whole-cascade name="all-templates" filename="htmltemplates/template.xhtml">
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
  </bc:load-whole-cascade>
  
  <html:consolidate-templates name="consolidate-templates">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </html:consolidate-templates>
    
  <p:sink/>
  
  <bc:load-cascaded name="htmltemplates-implementation" filename="htmltemplates/implementation.xsl">
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </bc:load-cascaded>
  
  <html:generate-xsl-from-html-template name="generate-xsl-from-html-template">
    <p:input port="implementing-xsl">
      <p:pipe port="result" step="htmltemplates-implementation"/>
    </p:input>
    <p:input port="source">
      <p:pipe port="result" step="consolidate-templates"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </html:generate-xsl-from-html-template>
  
  <p:sink/>
  
  <html:apply-generated-xsl name="apply-generated">
    <p:input port="source">
      <p:pipe port="result" step="remove-srcpath-from-html"/>
    </p:input>
    <p:input port="metadata">
      <p:pipe port="result" step="meta"/>
    </p:input>
    <p:input port="stylesheet-from-htmltemplate">
      <p:pipe port="result" step="generate-xsl-from-html-template"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </html:apply-generated-xsl>
  
  <p:add-attribute name="add-base-uri" match="/*" attribute-name="xml:base">
    <p:with-option name="attribute-value"
      select="replace(
      replace(
      /c:param-set/c:param[@name eq 'file-uri']/@value,
      '/(idml|tei|hub|docx)/([^/]+)$',
      '/epub/$2'
      ),
      '(idml|xml|docx)$',
      'html'
      )">
      <p:pipe port="result" step="paths"/>
    </p:with-option>
    <p:input port="source">
      <p:pipe port="result" step="apply-generated"/>
    </p:input>
  </p:add-attribute>
  
  <letex:store-debug pipeline-step="idml2epub_tei_onix/add-base-uri">
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </letex:store-debug>
   
  <p:sink/>
 
  <p:template name="epub-config">
    <p:input port="template">
      <p:inline>
        <epub-config>
          <opf>
            <packageid>placeholder</packageid>
            <metadata>
              <dc:identifier>{string(//html:head/html:meta[@name eq 'identifier']/@content)}</dc:identifier>
              <dc:title>{string(//html:head/html:title)}</dc:title>
              <dc:creator>{string-join(//html:p[contains(@class, 'author_ed')], '; ')}</dc:creator>
              <dc:publisher>{string(//html:p[contains(@class, 'publisher')])}</dc:publisher>
              <dc:date>{string(//html:meta[@name eq 'DC.date']/@content)}</dc:date>
              <dc:language>{string(//html:meta[@name eq 'lang']/@content)}</dc:language>
            </metadata>
          </opf>
        </epub-config>
      </p:inline>
    </p:input>
    <p:input port="source">
      <p:pipe step="add-base-uri" port="result"/>
    </p:input>
    <p:input port="parameters">
      <p:pipe port="result" step="paths"/>
    </p:input>
  </p:template>
  
  <letex:store-debug pipeline-step="idml2epub_tei_onix/epub-config">
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </letex:store-debug>
  
  <p:uuid match="//packageid/text()" name="uuid"/>
   
  <letex:store-debug pipeline-step="idml2epub_tei_onix/meta">
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </letex:store-debug>
  
  <p:sink/>
   
  <bc:load-cascaded name="load-epub-heading-conf" filename="epubtools/heading-conf.xml">
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </bc:load-cascaded>
  
  <p:sink/>
 
  <epub:convert name="epub-convert">
    <p:input port="conf">
      <p:pipe port="result" step="load-epub-heading-conf"/>
    </p:input>
    <p:input port="source">
      <p:pipe port="result" step="add-base-uri"/>
    </p:input>
    <p:input port="meta">
      <p:pipe port="result" step="uuid"/>
    </p:input>
    <p:input port="report-in">
      <p:pipe port="result" step="create-empty-report"/>
    </p:input>
    <p:with-option name="terminate-on-error" select="'no'"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </epub:convert>
  
</p:declare-step>

