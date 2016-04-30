<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns="http://docbook.org/ns/docbook"
  xpath-default-namespace="http://docbook.org/ns/docbook"
  version="2.0">
  
  <!--  *
        * normalize file references of images. The files are copied in the XProc step in "trdemo-patch-and-copy-filerefs.xpl".
        * -->
  
  <xsl:param name="assets-dirname" select="'assets'" as="xs:string"/>
  
  <xsl:template match="imageobject/imagedata/@fileref">
    
    <xsl:analyze-string select="." regex="^.+/(.+)\.(.+)$">
      <xsl:matching-substring>
        <xsl:variable name="filebasename" select="regex-group(1)" as="xs:string"/>
        <xsl:variable name="fileextension" select="regex-group(2)" as="xs:string"/>
        <xsl:variable name="assets-path" select="if(string-length($assets-dirname) gt 0) then concat($assets-dirname, '/') else ''" as="xs:string"/>
        <xsl:variable name="fileref" select="concat($assets-path, $filebasename, '.', $fileextension)" as="xs:string"/>
        <xsl:attribute name="fileref" select="$fileref"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
    
  </xsl:template>
  
  <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>