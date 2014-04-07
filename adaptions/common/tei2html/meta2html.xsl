<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:uv="http://unionsverlag.com/namespace" 
  xmlns="http://www.w3.org/1999/xhtml"  
  exclude-result-prefixes="css xs uv"
  version="2.0">
  
  <xsl:key name="title-by-work-id" match="title_dump/title_record" use="title_id"/>
  
  <xsl:param name="work" as="xs:string"/>

  <!-- A master title is the first in a series of editions. For a given title id, this key gives
       the master title for that title. If a title is its own master title, its mastertitle_id is '0'. -->
  <xsl:key name="master-title-for-id" match="title_dump/title_record" 
    use="../title_record[mastertitle_id = current()/title_id]/title_id, 
         if (mastertitle_id = '0') then title_id else ()"/>

  <xsl:key name="webtitle-by-id" match="title_dump/title_record" use="format-number(number(title_id), '00000')"/>
  <xsl:key name="webtitle-by-isbn-fragment" match="title_dump/title_record"
    use="for $s in (replace(isbn_13, '-', '')[string-length(.) eq 13], replace(isbn, '-', '')[string-length(.) eq 10])[1] return substring($s, string-length($s) - 5, 5)"/>
  <xsl:key name="quote-by-title-id" match="quote_dump/quote_record" use="title_id"/>
 
  <!-- metadata is the second document in the default collection (need to use XProc) -->  
  <xsl:variable name="metadata" select="collection()[2]" as="document-node(element(meta))"/>
  <xsl:variable name="boilerplate" select="collection()[3]" as="document-node(element(html:html))"/>

  <xsl:key name="by-id" match="*[@id | @xml:id]" use="@id | @xml:id"/>

  <xsl:param name="max-quotes-book" as="xs:string" select="(key('by-id', 'max-quotes-book', $boilerplate)/@value, '2')[1]"/>
  <xsl:param name="max-other-quotes-book" as="xs:string" select="(key('by-id', 'max-other-quotes-book', $boilerplate)/@value, '3')[1]"/>   
  <xsl:param name="max-quotes-author" as="xs:string" select="(key('by-id', 'max-quotes-author', $boilerplate)/@value, '3')[1]"/>  
  <xsl:param name="max-titles-by-author" as="xs:string" select="(key('by-id', 'max-titles-by-author', $boilerplate)/@value, '3')[1]"/>  
  

  <xsl:variable name="webtitle-by-isbn-fragment" as="element(title_record)?" 
    select="key('webtitle-by-isbn-fragment', $work, $metadata)"/>
  <xsl:variable name="webtitle-by-id" as="element(title_record)?" 
    select="key('webtitle-by-id', $work, $metadata)"/>
  <xsl:variable name="webtitle" as="element(title_record)?" 
    select="($webtitle-by-id, $webtitle-by-isbn-fragment)[1]"/>
  <xsl:variable name="mastertitle" as="element(title_record)?"
    select="key('master-title-for-id', $webtitle/title_id, $metadata)"/>
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
  <xsl:variable name="quote-random" as="xs:integer*">
    <xsl:sequence select="xs:integer(format-time(current-time(), '[s01]'))*6 mod
      xs:integer($max-quotes-author) + 1"></xsl:sequence>
  </xsl:variable>  

  <!-- this is this stylesheet’s main template -->
  <xsl:template name="title-page">
    <xsl:if test="not($webtitle)">
      <xsl:variable name="msg" as="text()+">Could not look up webtitle by id or by ISBN fragment for <xsl:value-of select="$work"/> in <xsl:value-of select="base-uri(collection()[2]/*)"/>  
      </xsl:variable>
      <xsl:message select="$msg"/>
      <div class="title-page prelim">
        <xsl:sequence select="$msg"/>
      </div>
    </xsl:if>
    <xsl:apply-templates select="$webtitle" mode="title-page">
      <xsl:with-param name="context" select="." tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template name="meta">
    <xsl:apply-templates select="$webtitle/first_edition" mode="meta"/>
    <xsl:apply-templates select="tei:teiHeader/tei:profileDesc/tei:textClass/tei:keywords" mode="#current"/>
    <xsl:apply-templates select="tei:teiHeader/tei:profileDesc/tei:langUsage/tei:language" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="first_edition" mode="meta">
    <meta name="DC.date" content="{.}"/>
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

  <xsl:template match="title_dump/title_record" mode="title-page">
    <xsl:param name="context" as="element(tei:TEI)" tunnel="yes"/>
    <!-- This div has to be removed after the img/@src has been added to the /epub-config/cover/@href 
         It will be reconstructed within epubtools -->
    <xsl:variable name="cover-image-url" as="element(*)?"
      select="($webtitle/e_cover_url_big, $webtitle/printcover_url_big, $mastertitle/e_cover_url_big, $mastertitle/printcover_url_big)[not(. = '?')][1]"/>
    <xsl:choose>
      <xsl:when test="not($cover-image-url)">
        <p class="prelim">[Kein Cover gefunden!]</p>
        <div class="epub-cover-image-container"/>
      </xsl:when>
      <xsl:otherwise>
        <div class="epub-cover-image-container">
          <img src="{string($cover-image-url)}" alt="Cover"/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
    
    <xsl:variable name="authors" select="$people[matches(role_record/role_name, 'Autor')]" as="element(person_record)*"/>
    <xsl:variable name="editors" select="$people[matches(role_record/role_name, 'Herausgeber')]" as="element(person_record)*"/>
    <xsl:variable name="translators" select="$people[matches(role_record/role_name, 'Übersetzung')]" as="element(person_record)*"/>  
    <xsl:variable name="illustrators" select="$people[matches(role_record/role_name, 'Illustration')]" as="element(person_record)*"/>  
    
    <div class="title-page{if ($no-dedicated-info) then ' prelim' else ''}">
      <xsl:if test="$authors and $editors">
        <xsl:message terminate="yes">Titel <xsl:value-of select="$webtitle/title_id"/> (Werk <xsl:value-of select="$work"/>) hat
          sowohl Autoren als auch Herausgeber.</xsl:message>
      </xsl:if>
      <xsl:if test="not($authors) and not($editors)">
        <xsl:message terminate="yes">Titel <xsl:value-of select="$webtitle/title_id"/> (Werk <xsl:value-of select="$work"/>) hat
          weder Autoren noch Herausgeber.</xsl:message>
      </xsl:if>
      <p class="author_ed">
        <xsl:apply-templates select="$authors, $editors" mode="title-page">
          <!--          <xsl:sort select="ja wonach eigentlich? Momentan in Dokumentreihenfolge der roles"/>-->
        </xsl:apply-templates>
        <xsl:if test="$editors">&#xa0;(Hrsg.)</xsl:if>
      </p>
      <xsl:apply-templates select="title, subtitle, translation_title" mode="title-page"/>
        <xsl:apply-templates select="publisher" mode="title-page"/>
    </div>
    <div class="about{if ($no-dedicated-info) then ' prelim' else ''}">
      <!-- about the book -->
      <xsl:apply-templates select="key('by-id', 'about_book_heading', $boilerplate)" mode="#current"/>
      <xsl:apply-templates
        select="(
        $webtitle/info_body[not(matches(., '^\s*$'))], 
        $mastertitle/info_body[not(matches(., '^\s*$'))]
        )[1]"
        mode="title-page"/>
      <!-- more information about the book link --> 
      <p>
        <xsl:attribute name="class" select="concat('title_link', if ($no-dedicated-info) then ' prelim' else '')"/>
        <a href="http://www.unionsverlag.com/info/title.asp?title_id={$webtitle/title_id}">
          <xsl:apply-templates select="key('by-id', 'more_about_book_link', $boilerplate)" mode="#current"/>
        </a> 
      </p>
      <div class="quotes">
        <xsl:message select="$max-quotes-book" terminate="no"/>
        <xsl:apply-templates select="if ($webtitle-quotes) then $webtitle-quotes[position() = (1 to xs:integer($max-quotes-book))] 
          else $mastertitle-quotes[position() = (1 to xs:integer($max-quotes-book))]" mode="#current"/>
      </div>
      <xsl:variable name="editions" as="element(title_record)*">
        <xsl:if test="mastertitle_id = '0'">
          <xsl:sequence select="$metadata/*/title_dump/title_record[current()/mastertitle_id = $webtitle/title_id and not(edition_type_id = ('6', '7'))]"/>         
        </xsl:if>
        <xsl:if test="mastertitle_id != '0'">
          <xsl:sequence select="$metadata/*/title_dump/title_record
                                                      [((title_id = $webtitle/mastertitle_id) or
                                                       (mastertitle_id = $webtitle/mastertitle_id)) and 
                                                        not(edition_type_id = ('6', '7'))]"/>          
        </xsl:if>
      </xsl:variable>
      
      <xsl:variable name="available-editions" as="element(title_record)*">
        <xsl:sequence select="$editions[availability_id = $metadata/*/availability_dump/availability_record
                                       [xs:integer(availability_code) gt 0]/availability_id]"/> 
      </xsl:variable>
      
      <div class="editions">
        <xsl:if test="$available-editions">
          
          <p class="editions">Dieses Buch ist auch erschienen als: </p> 
          <ul class="no-margin">
            <xsl:for-each select="$available-editions/edition_type_id">
              <li>
                <!-- Wo sind denn die Unterschiede zu Broschur/Taschenbuch -->
                <xsl:value-of select="$metadata/*/edition_type_dump/edition_type_record[edition_type_id = current()]/edition_type"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="current()/../binding"/>
                <xsl:text>, Ersterscheinungsdatum </xsl:text>
                <!-- Warum sollte hier die First Edition rein? Wäre nicht die letzte besser? -->
                <xsl:value-of select="replace(current()/../first_edition, '^(\d{4})-.*', '$1')"/>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:if>
        
        <p>
          <xsl:attribute name="class" select="concat('title_link', if ($no-dedicated-info) then ' prelim' else '')"/>
          <a href="http://www.unionsverlag.com/info/title.asp?title_id={$webtitle/title_id}">Überblick der aktuell lieferbaren Ausgaben</a>
        </p>  
      </div>   
    </div>
    <div class="author">
    <div class="short-bio">
    
      <xsl:variable name="about-string" as="element(html:span)">
        <xsl:apply-templates select="key('by-id', 'about_author_heading', $boilerplate)" mode="#current"/>
      </xsl:variable>
      
        <xsl:if test="$editors">
          <h4><xsl:sequence select="uv:person-role($about-string/text(), 'Herausgeber', $editors)"/></h4>
          <xsl:call-template name="persons">
            <xsl:with-param name="person" select="$editors"/>
          </xsl:call-template>      
        </xsl:if>
         <xsl:if test="$authors">
           <h4><xsl:sequence select="uv:person-role($about-string/text(), 'Autor', $authors)"/></h4>
          <xsl:call-template name="persons">
            <xsl:with-param name="person" select="$authors"/>
          </xsl:call-template>      
        </xsl:if>
        <xsl:if test="$translators">
          <h4><xsl:sequence select="uv:person-role($about-string/text(), 'Übersetzer', $translators)"/></h4>
          <xsl:call-template name="persons">
            <xsl:with-param name="person" select="$translators"/>
          </xsl:call-template>      
        </xsl:if>
        <xsl:if test="$illustrators">
          <h4><xsl:sequence select="uv:person-role($about-string/text(), 'Illustrator', $illustrators)"/></h4>
          <xsl:call-template name="persons">
            <xsl:with-param name="person" select="$illustrators"/>
          </xsl:call-template>      
        </xsl:if>      
    
    </div>
    </div>
    <div class="event">
      <!-- Veranstaltungen: Nur wo angebracht - wie steuern? In Web DB? , Geschlechter? -->
      <h4 class="prelim">Mehr Informationen und Angebote für Veranstaltungen</h4>
      <p class="noindent">Möchten Sie mehr über dieses Buch, den Autor und seine anderen Bücher erfahren?</p>
      <p class="noindent">Suchen Sie Unterlagen zur Diskussion oder zum Studium?</p>
      <p class="noindent">Materialien finden Sie auf den <a
         href="http://www.unionsverlag.com/info/title.asp?title_id={$webtitle/title_id}">Webseiten des Unionsverlags</a>.</p>
      <p class="noindent">Möchten Sie eine Lesung oder Veranstaltung mit oder zu
        <xsl:for-each select="$people">
        <!-- TO DO: Formatieren nach Muster A oder B / A, B oder C - etc. --> 
<!--          <xsl:apply-templates select="current()/first_name"/>
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="current()/last_name"/>-->
          <xsl:value-of select="concat(' ', current()/first_name, ' ', current()/last_name)" separator="', '"></xsl:value-of>
        </xsl:for-each> veranstalten? Wir helfen Ihnen gerne weiter. Schreiben Sie an <a href="mailto:ebook@unionsverlag.ch">ebook@unionsverlag.ch</a></p>
    </div> 
    
    <div class="offer prelim">
      <xsl:apply-templates select="key('by-id', 'offer_heading', $boilerplate)" mode="#current"/>
      <xsl:apply-templates select="key('by-id', 'offer_information', $boilerplate)" mode="#current"/>
      <p>xxxx</p>
      <p>yyyy</p>
    </div> 

    <xsl:apply-templates select="key('by-id', 'uvUsage', $boilerplate)" mode="#current"/>
    
    <div class="imprint prelim">
      <xsl:if test="$no-dedicated-info">
        <p class="prelim">[Titelbild: <xsl:value-of select="$cover-image-url/name()"/> von <xsl:value-of
            select="format-number($cover-image-url/../title_id, '00000')"/>]</p>
      </xsl:if>
      <h3>Impressum</h3>
      <xsl:variable name="prelim" as="node()*">
        <xsl:apply-templates select="$context/tei:text/tei:front/tei:div[@type eq 'imprint']" mode="tei2html"/>  
      </xsl:variable>
      <xsl:sequence select="$prelim"/>
    </div>
  </xsl:template>

  <xsl:template match="html:span[@id = 'calc_keywords']" mode="title-page">
    <xsl:variable name="prelim" as="element(html:span)">
      <xsl:copy>
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
      </xsl:copy>
    </xsl:variable>
    <xsl:apply-templates select="$prelim" mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="title-page" priority="2"
    match="html:span[@class = 'and-enum'][. is (../html:span[@class = 'and-enum'])[last()]]">
    <xsl:text xml:space="preserve"> und </xsl:text>
  </xsl:template>

  <xsl:template match="html:span[@class = 'and-enum']" mode="title-page">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="*[@id = 'if_keywords']" mode="title-page">
    <xsl:if test="matches($webtitle/keywords, '\S')">
      <xsl:apply-templates mode="#current"/>
    </xsl:if>
  </xsl:template>
  

  <xsl:template name="backmatter">
    
    <div class="bookExtended">
      <xsl:apply-templates select="key('by-id', 'more_about_book_heading', $boilerplate)" mode="#current"/>
      <!-- Falls ausführlicher Text in Web DB -->
      <xsl:apply-templates
        select="(
        $webtitle/info_additional[not(matches(., '^\s*$'))], 
        $mastertitle/info_additional[not(matches(., '^\s*$'))]
        )[1]"
        mode="title-page"/>
      
      <div class="bookQuotesExtended">
        <!-- Quotes, die noch nicht in front kamen. -->
        <xsl:apply-templates select="if ($webtitle-quotes) then $webtitle-quotes[position() = xs:integer($max-quotes-book)+1 to
          xs:integer($max-other-quotes-book)] 
          else $mastertitle-quotes[position() = xs:integer($max-quotes-book)+1 to xs:integer($max-other-quotes-book)]"  mode="title-page"/>
        <div class="additional_information_about_author">
          <xsl:for-each select="$people">
            <xsl:sort select="last_name" order="ascending"/>
            <xsl:sort select="first_name" order="ascending"/>
            
            <xsl:variable name="author-quotes" as="element(quote_record)*">
              <xsl:perform-sort select="$metadata/*/quote_dump/quote_record[xs:string(pers_id) = xs:string(current()/pers_id)][position() = (1 to xs:integer($max-quotes-author))]">
                <xsl:sort select="number(sort)"/>
              </xsl:perform-sort>
            </xsl:variable> 
            
            <h3>
              <xsl:if test="not(additional_text/node() or (count($author-quotes[position() != $quote-random]) gt 1))">
                <xsl:attribute name="class" select="'prelim'"/>
              </xsl:if>Mehr über<xsl:value-of select="concat(' ', first_name, ' ', last_name)"/></h3>
            
            <!-- long biography -->
            <xsl:if test="additional_text/node()">
              <p class="long_bio"><xsl:apply-templates select="additional_text"/></p>
            </xsl:if>
            
            <!-- quotes about author without the one occuring in the front matter -->
            <xsl:apply-templates select="$author-quotes[position() != $quote-random]" mode="title-page"/>
            
          </xsl:for-each> 
        </div>   
      </div>
      <div class="uvOtherBooks">
        <xsl:for-each select="$people">
          <xsl:sort select="last_name" order="ascending"/>
          <xsl:sort select="first_name" order="ascending"/>
          
          <xsl:variable name="otherBooks" as="element(title_record)*">
            <xsl:sequence select="$metadata/*/title_dump/title_record[title_id =
              $metadata/*/role_dump/role_record[pers_id = current()/pers_id]/title_id]"/>
          </xsl:variable>
          
          <xsl:variable name="otherAvailableBooks" as="element(title_record)*">
            <xsl:sequence select="$otherBooks[status_id = '1']
              [availability_id = $metadata/*/availability_dump/availability_record
              [xs:integer(availability_code) gt 0]/availability_id
              ]"/>
            <!--sortieren nach Verkaufzahlen, Buchname/Datum-->
          </xsl:variable>
          <xsl:if test="$otherAvailableBooks">
            <h3>
              <xsl:apply-templates select="key('by-id', 'other_books_heading', $boilerplate)" mode="#current"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="concat(' ', first_name, ' ', last_name)"/></h3>
            <ul>
              <xsl:for-each select="distinct-values($otherAvailableBooks[position() = 1 to
                xs:integer($max-titles-by-author)]/title)">
                <!-- welche weiteren Infos? Cover, Link, Text-Micro/Mini usw. -->
                <li><xsl:value-of select="."/></li>
              </xsl:for-each>
            </ul>
          </xsl:if>
        </xsl:for-each>
        
      </div>      
    </div>
    <div class="uvBookPlaces">
      <h3 class="prelim">Die Schauplätze</h3>
      <h4 class="prelim">Die Schauplätze des Buches</h4>
      <ul>
        <li>### Aus den geo-Tags des Buches die Schauplätze sammeln</li>
      </ul>
      
      <h4 class="prelim">Die Schauplätze der Autoren</h4>
      <ul>
        <li>### Aus den geo-Tags der Personen (Autor/Übersetzer/etc.) die Schauplätze sammeln</li>
      </ul>
    </div>
    
    <!-- Book Radar-->
    <xsl:apply-templates select="key('by-id', 'uvBookRadar', $boilerplate)" mode="#current"/>
  </xsl:template>

  <xsl:template name="persons"> 
    <xsl:param name="person" as="element(person_record)+"/>
    <xsl:for-each select="$person">
      <xsl:sort order="ascending" select="last_name"/>
      <xsl:sort order="ascending" select="first_name"/>      
      <!-- Abfangen, wenn es kein Bild gibt/die Seite leer ist, kann trotz nicht-leeren pircture_fields vorkommen --> 
      <xsl:if test="picture_field/child::node()">
        <div class="author-pic">
          <img> 
            <xsl:attribute name="src" select="string(current()/picture_url_normal)"/>
            <xsl:attribute name="alt" select="concat(current()/first_name, ' ', current()/last_name)"/>
          </img>
          <xsl:if test="current()/picture_caption/node()">
            <p class="caption"><small><xsl:value-of select="current()/picture_caption"/></small></p>
          </xsl:if>
        </div>
      </xsl:if>
      <xsl:apply-templates select="current()/bio" mode="title-page">
        <!-- <xsl:sort select="ja wonach eigentlich? Momentan in Dokumentreihenfolge der roles"/>-->
        <!-- Eventuell muss sich die Überschrift dann auch dynamisch anpassen, wenn mehrere oder nur Herausgeber? Gibt es
          manchmal Autoren UND Herausgeber? 
          Oder Überschrift über jeden einzelnen? -->
      </xsl:apply-templates>
      
      <xsl:variable name="author-quotes" as="element(quote_record)*">
        <xsl:perform-sort select="$metadata/*/quote_dump/quote_record[xs:string(pers_id) = xs:string(current()/pers_id)][position() = (1 to xs:integer($max-quotes-author))]">
          <xsl:sort select="number(sort)"/>
        </xsl:perform-sort>
      </xsl:variable> 

      
      <xsl:apply-templates select="$author-quotes[position() = $quote-random]" mode="#current"/>
           
     
      <p class="title_link">
        <a href="http://www.unionsverlag.com/info/person.asp?pers_id={current()/pers_id}">Mehr zu
          <xsl:value-of select="current()/first_name"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="current()/last_name"/>
        </a> auf der Website des Unionsverlags.
      </p>
      
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="quote_record" mode="title-page">
    <div class="quote">
      <xsl:apply-templates select="description" mode="#current"/>
      <p class="byline">
        <xsl:value-of select="string-join((
          string-join((quote_author_first_name, quote_author_last_name), ' '),
          media_name, media_location, publication_date
          )[not(matches(., '^\s*$'))], ', ')"></xsl:value-of>
      </p>
    </div>
  </xsl:template>
  
  <xsl:template match="description | bio" mode="title-page">
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

  <xsl:template match="info_header" mode="title-page">
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

  <xsl:template match="info_body[matches(., '^\s*$')]" mode="title-page"/>

  <xsl:template match="info_body[not(matches(., '^\s*$'))]" mode="title-page">
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
<!--    <xsl:apply-templates select="following-sibling::info_additional" mode="#current"/>-->
  </xsl:template>

  <xsl:template match="info_additional[matches(., '^\s*$')]" mode="title-page"/>

  <xsl:template match="info_additional[not(matches(., '^\s*$'))]" mode="title-page">
    <div class="additional-info">
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
    </div>
    <xsl:apply-templates select="following-sibling::info_additional" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="html:p[position() = 1]" mode="title-page">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="class" select="string-join(('noindent', @class), ' ')"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="person_record" mode="title-page">
    <!-- non-western name order? -->
    <xsl:value-of select="first_name"/>
    <xsl:text xml:space="preserve"> </xsl:text>
    <xsl:value-of select="last_name"/>
    <xsl:if test="position() ne last()">
      <xsl:text xml:space="preserve">, </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="title" mode="title-page">
    <h1>
      <xsl:apply-templates mode="#current"/>
    </h1>
  </xsl:template>
    
  <xsl:template match="*[name() = ('subtitle', 'subtitle_2', 'translation_title')][matches(., '^\s*$')]" mode="title-page"/>
    
  <xsl:template match="subtitle[matches(., '\S')]" mode="title-page">
    <div class="subtitles">
      <p class="{name()}">
        <xsl:apply-templates mode="#current"/>
      </p>
      <xsl:apply-templates select="../subtitle_2[matches(., '\S')]" mode="#current"/>
    </div>
  </xsl:template>
    
  <xsl:template match="*[name() = ('translation_title', 'subtitle_2', 'publisher')][matches(., '\S')]" mode="title-page">
    <p class="{name()}">
      <xsl:apply-templates mode="#current"/>
    </p>
  </xsl:template>
  
  <xsl:function name="uv:person-role">
    <xsl:param name="about_string" as="xs:string"/>
    <xsl:param name="role" as="xs:string"/>
    <xsl:param name="persons" as="element(person_record)+"/>
    <xsl:if test="$persons[2]">
      <xsl:choose>
        <xsl:when test="every $a in $persons/gender_type satisfies $a = 'F'">
          <xsl:value-of select="concat($about_string, ' die ', $role, 'innen')"/>          
        </xsl:when>
        <xsl:when test="$persons/role_record[role_name = 'Übersetzung']">
          <xsl:value-of select="concat($about_string, 'die ', $role)"/>          
        </xsl:when>        
        <xsl:otherwise>
          <xsl:value-of select="concat($about_string, 'die ', $role, 'en')"/>          
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="not($persons[2])">
      <xsl:choose>
        <xsl:when test="$persons[gender_type = 'F']">
          <xsl:value-of select="concat($about_string, 'die ', $role, 'in')"/>          
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($about_string, 'den ', $role)"/>           
        </xsl:otherwise>
      </xsl:choose>        
    </xsl:if>    
  </xsl:function>
  
</xsl:stylesheet>