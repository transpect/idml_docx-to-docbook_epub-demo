<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:transpect="http://www.le-tex.de/namespace/transpect" 
  version="2.0">
  <!--  *
        * This stylesheet is used to derive parameters for the transpect configuration cascade 
        * from the input filename. The parameter names can be configured in the transpect configuration file.
        * 
        * -->
  <xsl:import href="http://transpect.le-tex.de/book-conversion/converter/xsl/paths.xsl"/>
  <!--  *
        * The regex below is used to parse the file basename with the function "transpect:parse-file-name". 
        * According to this regex, the following example basenames are permitted:
        * 
        * le-tex_brochure_word_2929223
        * campus_blabla_word_22222
        * as_99911122233
        *
        * -->
  <xsl:variable name="regex" select="'^([-a-zA-Z0-9\.]+)_([-a-zA-Z0-9\.]+)_?([-a-zA-Z0-9\.]+)?_?([-a-zA-Z0-9\.]+)?$'" as="xs:string"/>

  <!--  *
        * Overwrite the behaviour of "transpect:parse-file-name" from paths.xsl which is imported above. 
        * The function is used to derive the appropriate regex-groups from the filename. The regex-groups 
        * must apply to your transpect configuration, which is the secondary input of the XProc step "transpect:paths".
        *
        * -->
  <xsl:function name="transpect:parse-file-name" as="attribute(*)*">
    <xsl:param name="filename" as="xs:string?"/>
    <xsl:variable name="base" select="transpect:basename($filename)" as="xs:string"/>
    <xsl:attribute name="base" select="$base"/>
    <xsl:variable name="ext" select="transpect:ext($filename)" as="xs:string"/>
    <xsl:attribute name="ext" select="$ext"/>
    <!--  * 
          * set vendor statically 
          * -->
    <xsl:attribute name="vendor" select="'trdemo'"/>
    <!--  *
          * analyze-string is used to parse the filename. The matching substring is decomposed to 
          * derive the appropriate values for the transpect configuration.
          * -->
    <xsl:analyze-string select="$base" regex="{$regex}">
      <xsl:matching-substring>
        <xsl:choose>
          <!--  *
                * this when-branch is specific for the campus extension of the transpect-demo
                *  -->
          <xsl:when test="matches($base, '^as_\d{13}$')">
            <xsl:attribute name="publisher" select="'campus'"/>
            <xsl:attribute name="series" select="'as'"/>
            <xsl:attribute name="production-line" select="if($ext eq 'docx') then 'word' 
              else if($ext eq 'idml') then 'indesign'
              else 'generic'"/>
            <xsl:attribute name="work" select="regex-group(2)"/>
          </xsl:when>
          <!--  *
                * default branch for any file basenames
                *  -->
          <xsl:otherwise>
            <xsl:attribute name="publisher" select="regex-group(1)"/>
            <xsl:attribute name="series" select="regex-group(2)"/>
            <xsl:attribute name="production-line" select="if($ext eq 'docx') then 'word' 
              else if($ext eq 'idml') then 'indesign'
              else 'generic'"/>
            <xsl:attribute name="work" select="if(regex-group(3)) then regex-group(3) else $base"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:matching-substring>
      <!--  *
            * if the regex does not apply, the attributes default values are used
            *  -->
      <xsl:non-matching-substring>
        <xsl:attribute name="publisher" select="regex-group(1)"/>
        <xsl:attribute name="series" select="regex-group(2)"/>
        <xsl:attribute name="production-line" select="if($ext eq 'docx') then 'word'
          else if($ext eq 'idml') then 'indesign'
          else 'generic'"/>
        <xsl:attribute name="work" select="$base"/>        
      </xsl:non-matching-substring>
    </xsl:analyze-string>
    
  </xsl:function>
  
</xsl:stylesheet>