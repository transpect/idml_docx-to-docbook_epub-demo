<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:bc="http://transpect.le-tex.de/book-conversion"
  version="2.0">
  
  <xsl:import href="http://transpect.le-tex.de/book-conversion/converter/xsl/paths.xsl"/>
  
  <xsl:variable name="file-regex" select="'^([-a-zA-Z0-9\.]+)_([-a-zA-Z0-9\.]+)_([-a-zA-Z0-9\.]+)(_[-a-zA-Z0-9\.]+)?'" as="xs:string"/>
  <!-- for example publishername_seriesname_workname_whatever -->
  
  <!-- example configuration for word input from campus -->
  <xsl:variable name="campus-file-regex" as="xs:string"
    select="'^(as)_(\d+)$'" />

  <xsl:function name="bc:components-from-filename" as="xs:string+">
    <xsl:param name="filename" as="xs:string"/>
    <xsl:param name="conf" as="element(publisher-conf)"/>
    
    <xsl:variable name="work-basename" select="bc:work-basename-from-filename($filename)"/>
    
    <xsl:choose>
      <xsl:when test="matches($work-basename, '^transpect_wp_')">
        <xsl:sequence select="('letex', 'wp', $work-basename)"/>
      </xsl:when>
      <xsl:when test="matches($work-basename, $campus-file-regex)">
        <xsl:analyze-string select="$work-basename" regex="{$campus-file-regex}">
          <xsl:matching-substring>
            <xsl:sequence select="'campus'"/>
            <xsl:sequence select="regex-group(1)"/>
            <xsl:sequence select="regex-group(2)"/>
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:when>
      <xsl:when test="matches($work-basename, $file-regex)">
        <xsl:analyze-string select="$work-basename" regex="{$file-regex}">
          <xsl:matching-substring>
            <xsl:sequence select="(regex-group(1), 'letex')[1]"/>
            <xsl:sequence select="(regex-group(2), 'legacy')[1]"/>
            <xsl:sequence select="(regex-group(3), $work-basename)[1]"/>
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="('letex', 'legacy', $work-basename)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>