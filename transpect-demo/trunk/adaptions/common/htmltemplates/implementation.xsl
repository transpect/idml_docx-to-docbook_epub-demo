<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:html="http://www.w3.org/1999/xhtml" 
  xmlns:uv="http://unionsverlag.com/namespace" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="xs uv" 
  version="2.0">

  <xsl:variable name="metadata" as="document-node()" select="collection()[1]"/>
  <xsl:variable name="htmlinput" as="document-node(element(html:html))+" select="collection()[position() gt 1]"/>
  <xsl:param name="work" as="xs:string"/>

  <!-- Resolving Work to title id -->
  <xsl:key name="title-by-work-id" match="title_dump/title_record" use="title_id"/>

  <!-- A master title is the first in a series of editions. For a given title id, this key gives
       the master title for that title. If a title is its own master title, its mastertitle_id is '0'. -->
  <xsl:key name="master-title-for-id" match="title_dump/title_record" use="../title_record[mastertitle_id = current()/title_id]/title_id, 
    if (mastertitle_id = '0') then title_id else ()"/>

  <xsl:key name="webtitle-by-id" match="title_dump/title_record" use="format-number(number(title_id), '00000')"/>
  <xsl:key name="webtitle-by-isbn-fragment" match="title_dump/title_record" use="for $s in (replace(isbn_13, '-', '')[string-length(.) eq 13], replace(isbn, '-', '')[string-length(.) eq 10])[1] return substring($s, string-length($s) - 5, 5)"/>
  <xsl:key name="quote-by-title-id" match="quote_dump/quote_record" use="title_id"/>

  <xsl:key name="by-id" match="*[@id | @xml:id]" use="@id | @xml:id"/>

  <xsl:variable name="webtitle-by-isbn-fragment" as="element(title_record)?" select="key('webtitle-by-isbn-fragment', $work, $metadata)"/>
  <xsl:variable name="webtitle-by-id" as="element(title_record)?" select="key('webtitle-by-id', $work, $metadata)"/>
  <xsl:variable name="webtitle" as="element(title_record)?" select="($webtitle-by-id, $webtitle-by-isbn-fragment)[1]"/>
  <xsl:variable name="mastertitle" as="element(title_record)?" select="key('master-title-for-id', $webtitle/title_id, $metadata)"/>
  <!-- Whether no e-title-specific metadata could be found: -->
  <xsl:variable name="no-dedicated-info" as="xs:boolean" select="not($webtitle-by-id)"/>
  <xsl:variable name="webtitle-quotes" as="element(quote_record)*">
    <xsl:perform-sort select="key('quote-by-title-id', $webtitle/title_id, $metadata)">
      <xsl:sort select="number(sort)"/>
    </xsl:perform-sort>
  </xsl:variable>
  <xsl:variable name="mastertitle-quotes" as="element(quote_record)*">
    <xsl:perform-sort select="key('quote-by-title-id', $mastertitle/title_id, $metadata)">
      <xsl:sort select="number(sort)"/>
    </xsl:perform-sort>
  </xsl:variable>
  <xsl:variable name="editions" as="element(title_record)*">
    <xsl:if test="$webtitle-by-id/mastertitle_id = '0'">
      <xsl:sequence select="$metadata/*/title_dump/title_record[current()/mastertitle_id = $webtitle/title_id and not(edition_type_id = ('6', '7'))]"/>
    </xsl:if>
    <xsl:if test="$webtitle-by-id/mastertitle_id != '0'">
      <xsl:sequence select="$metadata/*/title_dump/title_record
        [((title_id = $webtitle/mastertitle_id) or
        (mastertitle_id = $webtitle/mastertitle_id)) and 
        not(edition_type_id = ('6', '7'))]"/>
    </xsl:if>
  </xsl:variable>


  <xsl:template name="main">
    <html>
      <head>
        <xsl:call-template name="htmltitle"/>
        <xsl:apply-templates select="$htmlinput[1]/html:html/html:head/node() except $htmlinput[1]/html:html/html:head/html:title"/>
        <xsl:apply-templates select="($webtitle, $mastertitle)[1]/first_edition" mode="meta"/>
      </head>
      <!-- will be generated: -->
      <xsl:call-template name="body"/>
    </html>
  </xsl:template>

  <!-- title of the html document-->
  <xsl:template name="htmltitle" as="element(html:title)">
    <title>
      <xsl:value-of select="($webtitle, $mastertitle)[1]/title"/>
    </title>
  </xsl:template>
  
  <xsl:template match="html:meta[@name = 'source-basename']">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="name" select="'identifier'"/>
      <xsl:attribute name="content" select="replace(@content, '^(UV_)?(\d+)(_\d+)?_.*$', '$1$2$3')"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- date of the epub. Could be the first edition date or the current year. Choose via commenting in or out -->  
  <xsl:template match="first_edition" mode="meta">
<!--    <meta name="DC.date" content="{replace(., '^(\d+)-.*$', '$1')}"/>-->
    <meta name="DC.date" content="{format-date(current-date(), '[Y1]')}"/>
  </xsl:template>

  <xsl:variable name="first-heading" select="($htmlinput[1]/html:html/html:body//html:h2[not(preceding-sibling::*[local-name() = 'p'])]
    [matches(@class, '(section|chapter)')][1], 
    $htmlinput[1]/html:html/html:body//html:h2[@class = 'part'][1])[1]" as="element(html:h2)?"/>
  
  <xsl:template name="htmlinput-body">
    <xsl:apply-templates select="$htmlinput[1]/html:html/html:body/node() except ($htmlinput[1]/html:html/html:body/html:div[@class = 'toc'])"/>
    <xsl:apply-templates select="$htmlinput[1]/html:html/html:body/html:div[@class = 'toc']" mode="discard-toc"/>
  </xsl:template>

  <!-- merge-info is a mode that, while processing a meta-titles/webtitle element, pulls in information
       from the meta-roles and meta-persons tables -->
  <xsl:template match="* | @*" mode="merge-info title-page">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>


  
   <xsl:variable name="people" as="element(person_record)*">
     <xsl:for-each-group select="$metadata/*/role_dump/role_record[title_id = $webtitle/title_id]" group-by="pers_id">
       <xsl:apply-templates select="$metadata/*/person_dump/person_record[pers_id = current-grouping-key()]" mode="merge-info">
         <xsl:with-param name="roles" select="current-group()"/>
       </xsl:apply-templates>
     </xsl:for-each-group>
   </xsl:variable>
  

  <xsl:template match="person_dump/person_record" mode="merge-info">
    <xsl:param name="roles" as="element(role_record)+"/>
    <xsl:copy>
      <xsl:apply-templates select="@*, node(), $roles" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:variable name="authors" select="$people[matches(role_record/role_name, 'Autor')]" as="element(person_record)*"/>
  <xsl:variable name="editors" select="$people[matches(role_record/role_name, 'Herausgeber')]" as="element(person_record)*"/>
  <xsl:variable name="translators" select="$people[matches(role_record/role_name, 'Übersetzung')]" as="element(person_record)*"/>
  <xsl:variable name="illustrators" select="$people[matches(role_record/role_name, 'Illustration')]" as="element(person_record)*"/>



  <xsl:function name="uv:contribs-for-role">
    <xsl:param name="all-contribs" as="element(person_record)*"/>
    <xsl:param name="role-name" as="xs:string"/>
    <xsl:sequence select="$all-contribs[matches(role_record/role_name, $role-name)]"/>
  </xsl:function>

  
  <xsl:template name="keywords">
    <xsl:param name="_content" as="item()*"/>
    <p class="keywords">
      <xsl:value-of select="$_content"/>
      <xsl:apply-templates select="$webtitle/keywords" mode="#current" />
    </p>  
  </xsl:template>
  
  <xsl:template match="keywords">
      <span class="keywords">
        <xsl:analyze-string select="$webtitle/keywords" regex=",\s*">
          <xsl:matching-substring>
            <span class="and-enum">
              <xsl:text xml:space="preserve">, </xsl:text>
            </span>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <i>
              <xsl:value-of select="."/>
            </i>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </span>
   </xsl:template>
  

  <xsl:template name="toc">
    <xsl:param name="_content"/>
    <xsl:param name="depth" tunnel="yes"/>
    <xsl:apply-templates select="$htmlinput[1]/html:html/html:body/html:div[@class = 'toc']">
      <xsl:with-param name="heading" select="$_content"/>
      <xsl:with-param name="depth" select="$depth"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="html:div[@class = 'toc']">
    <xsl:param name="heading"/>
    <xsl:param name="depth" tunnel="yes"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="matches($heading, '^\s*$')"/>
        <xsl:otherwise>
          <xsl:sequence select="$heading"/>
          <xsl:apply-templates select="*[matches(./local-name(), '^h\d')]" mode="discard-toc"/>
        </xsl:otherwise>
      </xsl:choose>
          <xsl:apply-templates select="html:p[xs:integer(replace(@class, '^toc', '')) le xs:integer($depth)]"/>
          <xsl:apply-templates select="html:p[xs:integer(replace(@class, '^toc', '')) le xs:integer($depth)]" mode="discard-toc"/>         
     </xsl:copy>
  </xsl:template>
  
  <!-- change class of first headline, so it will not be split-->
  <xsl:template match="*:h2[. = $first-heading]" priority="2">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="class" select="replace(@class, '(section|part|chapter)', '$1-1')"/>
      <xsl:apply-templates select="@* except @class, node()"/>
    </xsl:copy>
  </xsl:template>
 
  <xsl:template name="impress">
    <xsl:param name="_content"/>
    <xsl:variable name="impress-data" select="($webtitle, $mastertitle)[1]/impress[not(matches(., '^\s*$'))]"/>
    <xsl:if test="$impress-data">
      <xsl:call-template name="_heading">
        <xsl:with-param name="content" select="$_content"/>
        <xsl:with-param name="class" select="'impress'"/>
        <xsl:with-param name="prelim" select="$no-dedicated-info"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="$impress-data"/>
  </xsl:template>
  
  <xsl:template match="*[matches(./local-name(), '^h\d')]" mode="discard-toc"/>
  <xsl:template match="html:p[matches(@class, 'toc')]" mode="discard-toc"/>  
  <xsl:template match="html:div[@class = 'toc']" mode="discard-toc"/>
   
  <xsl:template name="title-page">
    <xsl:param name="_content"/>
    <div class="title-page{if ($no-dedicated-info) then ' prelim' else ''}">
      <xsl:call-template name="_heading">
        <xsl:with-param name="content" select="$_content"/>
        <xsl:with-param name="class" select="'contrib-group'"/>
        <xsl:with-param name="prelim" select="$no-dedicated-info"/>
      </xsl:call-template>
      <xsl:if test="$authors and $editors">
        <xsl:message terminate="yes">Titel <xsl:value-of select="$webtitle/title_id"/> (Werk <xsl:value-of select="$work"/>) hat sowohl Autoren als auch Herausgeber.</xsl:message>
      </xsl:if>
      <xsl:if test="not($authors) and not($editors)">
        <xsl:message terminate="yes">Titel <xsl:value-of select="$webtitle/title_id"/> (Werk <xsl:value-of select="$work"/>) hat weder Autoren noch Herausgeber.</xsl:message>
      </xsl:if>
      <p class="author_ed">
        <xsl:apply-templates select="($webtitle, $mastertitle)[1]/$authors, ($webtitle, $mastertitle)[1]/$editors"/>
        <xsl:if test="$editors">&#xa0;(Hrsg.)</xsl:if>
      </p>
      <xsl:apply-templates select="($webtitle, $mastertitle)[1]/title, ($webtitle, $mastertitle)[1]/subtitle, ($webtitle, $mastertitle)[1]/translation_title"/>
      <xsl:apply-templates select="($webtitle, $mastertitle)[1]/publisher"/>
    </div>
  </xsl:template>

  <xsl:template match="person_record" as="xs:string">
    <xsl:variable name="seq" as="xs:string*">
      <xsl:value-of select="first_name"/>
      <xsl:if test="normalize-space(first_name) and normalize-space(last_name)">
        <xsl:text xml:space="preserve"> </xsl:text>  
      </xsl:if>
      <xsl:value-of select="last_name"/>
      <xsl:if test="position() ne last()">
        <xsl:text xml:space="preserve">, </xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:sequence select="string-join($seq, '')"/>
  </xsl:template>

  <xsl:template name="about-book-text">
    <xsl:param name="_content"/>
    <!-- Check whether the document order really selects the webtitle first -->
    <xsl:variable name="info-body" select="(($webtitle, $mastertitle)/info_body[not(matches(., '^\s*$'))])[1]"/>
    <xsl:if test="$info-body">
      <xsl:call-template name="_heading">
        <xsl:with-param name="content" select="$_content"/>
        <xsl:with-param name="class" select="'about'"/>
        <xsl:with-param name="prelim" select="$no-dedicated-info"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="$info-body"/>
  </xsl:template>

  <xsl:template name="_heading">
    <xsl:param name="content" as="item()*"/>
    <xsl:param name="class" as="xs:string?"/>
    <xsl:param name="prelim" as="xs:boolean"/>
    <xsl:apply-templates select="$content[matches(*[1]/local-name(), '^h\d')] except @class">
      <xsl:with-param name="class" select="string-join(($class, if ($prelim) then 'prelim' else '', if ($content/@class) then $content/@class else ''), ' ')"/>
    </xsl:apply-templates>
  </xsl:template>



<!--  
  <xsl:variable name="quote-random" as="xs:integer*">
    <xsl:sequence select="xs:integer(format-time(current-time(), '[s01]'))*6 mod
      xs:integer($max-quotes-author) + 1"></xsl:sequence>
  </xsl:variable>  -->
  
    
  <xsl:template match="info_body | impress">
    <xsl:choose>
      <xsl:when test="*:p">
        <xsl:apply-templates select="*" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <p class="noindent">
          <xsl:apply-templates mode="#current"/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="p[position() = 1]" mode="title-page">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="class" select="string-join(('noindent', @class), ' ')"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="weburl-title">
    <xsl:param name="_content"/>
    <a href="http://www.unionsverlag.com/info/title.asp?title_id={$webtitle/title_id}">
      <xsl:sequence select="$_content"/>
    </a>
  </xsl:template>


  <xsl:template match="quote_record">
    <div class="quote">
      <xsl:apply-templates select="description" mode="#current"/>
      <p class="byline">
        <xsl:value-of select="string-join((
          string-join((quote_author_first_name, quote_author_last_name), ' '),
          media_name, media_location, publication_date
          )[not(matches(., '^\s*$'))], ', ')"/>
      </p>
    </div>
  </xsl:template>

  <xsl:template match="description | bio">
    <xsl:choose>
      <xsl:when test="html:p">
        <xsl:apply-templates select="*" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <p class="noindent">
          <xsl:apply-templates mode="#current"/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="html:*[1][parent::description | parent::bio]">
    <xsl:copy>
      <xsl:attribute name="class" select="'noindent'"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="info_header">
    <p class="info-header">
      <xsl:choose>
        <xsl:when test="html:p">
          <xsl:apply-templates select="html:p/node()" mode="#current"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="#current"/>
        </xsl:otherwise>
      </xsl:choose>
    </p>
    <xsl:apply-templates select="following-sibling::info_body" mode="#current"/>
  </xsl:template>
  
  <xsl:template name="additional-content">
    <xsl:param name="_content"/>
    <xsl:variable name="extras" select="$metadata/*/doc_dump/doc_record[pers_id = $metadata/*/role_dump/role_record[title_id = ($webtitle, $mastertitle)[1]/title_id]/pers_id]" as="element(doc_record)*"/>
    <xsl:if test="not(matches($extras, '^\s*$'))">
      <div class="additional-content">
        <xsl:for-each select="$extras">
            <xsl:if test="not(matches($_content, '^\s*$'))">
              <xsl:apply-templates select="$_content[matches(*[1]/local-name(), '^h\d')]">
                <xsl:with-param name="class" select="'additional-content'"/>
              </xsl:apply-templates>
            </xsl:if>
          <xsl:if test="not(matches($extras/subtitle, '^\s*$'))">
            <xsl:apply-templates select="$extras/subtitle" mode="extras"/>
          </xsl:if>
            <xsl:choose>
              <xsl:when test="$extras/text[*:p]">
                <xsl:apply-templates select="$extras/text"/>
              </xsl:when>
              <xsl:otherwise>
                <p class="noindent">
                  <xsl:apply-templates select="$extras/text" mode="extras"/>
                </p>
              </xsl:otherwise>
            </xsl:choose>
          <xsl:if test="not(matches($extras/quote_author_last_name, '^\s*$'))">
            <xsl:apply-templates select="$extras/quote_author_last_name" mode="extras"/>
          </xsl:if>
        </xsl:for-each>
     </div>     
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="subtitle" mode="extras">
    <xsl:element name="p">
      <xsl:attribute name="class" select="local-name()"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="*:text">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*:text | *:title" mode="extras">
      <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="quote_author_last_name" mode="extras">
    <xsl:element name="p">
      <xsl:attribute name="class" select="'autor-zitat'"/>
      <xsl:sequence select="string-join((../quote_author_first_name, .), ' ')"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="info_additional[not(matches(., '^\s*$'))]">
    <!-- eventuell leere Absaetze entsorgen -->
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="info_additional[matches(., '^\s*$')]"/>

  <xsl:template name="title">
    <xsl:param name="_content"/>
    <h1>
      <xsl:attribute name="title" select="if (matches($_content, '^\s*$')) then (($webtitle, $mastertitle)[1]/title) else ($_content)"/>
      <xsl:attribute name="class" select="'split'"/>
    </h1>
  </xsl:template>

 <xsl:template match="*[name() = ('subtitle', 'subtitle_2', 'translation_title')][matches(., '^\s*$')]"/>

  <xsl:template match="subtitle[matches(., '\S')]">
    <div class="subtitles">
      <p class="{name()}">
        <xsl:apply-templates/>
      </p>
      <xsl:apply-templates select="../subtitle_2[matches(., '\S')]"/>
    </div>
  </xsl:template>

  <xsl:template match="*[name() = ('title', 'translation_title', 'subtitle_2', 'publisher')][matches(., '\S')]">
    <p class="{name()}">
      <xsl:apply-templates mode="#current"/>
    </p>
  </xsl:template>

  <xsl:template match="*:br/@clear" mode="#all"/>
    
  <xsl:template match="@* | *">
    <xsl:param name="class" as="xs:string?"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="$class">
        <xsl:attribute name="class" select="string-join((@class, $class), ' ')"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
