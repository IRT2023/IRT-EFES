<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a TEI document into a Solr index
       document. -->

  <!-- Path to the TEI file being indexed. -->
  <xsl:param name="file-path" />

  <xsl:variable name="document-metadata">
    <xsl:apply-templates mode="document-metadata" select="/*/tei:teiHeader" />
  </xsl:variable>

  <xsl:variable name="free-text">
    <xsl:apply-templates mode="free-text" select="/*/tei:text" />
  </xsl:variable>

  <xsl:template match="/">
    <!-- Entity mentions are restricted to the text of the document;
         entities keyed in the TEI header are document metadata. -->
    <xsl:apply-templates mode="entity-mention" select="/*/tei:text//tei:*[@key]" />

    <!-- Text content -->
    <xsl:if test="normalize-space($free-text)">
      <doc>
        <xsl:sequence select="$document-metadata" />
        <xsl:call-template name="field_document_type" />
        <xsl:call-template name="field_file_path" />
        <xsl:call-template name="field_document_id" />
        <xsl:call-template name="field_text" />
        <xsl:call-template name="field_lemmatised_text" />
        <!-- Facets. -->
        <xsl:call-template name="field_findspot_upper_level" />
        <xsl:call-template name="field_findspot_intermediate_level" />
        <xsl:call-template name="field_findspot_lower_level" />
        <xsl:call-template name="field_findspot" />
        <xsl:call-template name="field_mentioned_people" />
        <xsl:call-template name="field_mentioned_places" />
        <xsl:call-template name="field_place_of_origin" />
        <xsl:call-template name="field_source_repository"/>
        <xsl:call-template name="field_support_object_type" />
        <xsl:call-template name="field_support_material" />
        <xsl:call-template name="field_dating_criteria"/>
        <xsl:call-template name="extra_fields" />
      </doc>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:fileDesc/tei:titleStmt/tei:title" mode="document-metadata">
    <field name="document_title">
      <xsl:value-of select="normalize-space(.)" />
    </field>
  </xsl:template>

  <xsl:template match="tei:fileDesc/tei:titleStmt/tei:author" mode="document-metadata">
    <field name="author">
      <xsl:value-of select="normalize-space(.)" />
    </field>
  </xsl:template>

  <xsl:template match="tei:fileDesc/tei:titleStmt/tei:editor" mode="document-metadata">
    <field name="editor">
      <xsl:value-of select="normalize-space(.)" />
    </field>
  </xsl:template>

  <xsl:template match="tei:sourceDesc//tei:publicationStmt/tei:date[1]"
                mode="document-metadata">
    <xsl:if test="@when">
      <field name="publication_date">
        <xsl:value-of select="@when" />
      </field>
    </xsl:if>
  </xsl:template>

  <!-- For all origDates, use only the year. -->
  <xsl:template match="tei:origDate[@when]" mode="document-metadata">
    <xsl:variable name="year">
      <xsl:call-template name="get-year-from-date">
        <xsl:with-param name="date" select="@when" />
      </xsl:call-template>
    </xsl:variable>
    <field name="origin_date">
      <xsl:value-of select="$year" />
    </field>
  </xsl:template>
  
  <xsl:template match="tei:origDate[@notBefore][@notAfter]" mode="document-metadata">
    <xsl:variable name="start-year">
      <xsl:call-template name="get-year-from-date">
        <xsl:with-param name="date" select="@notBefore" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="end-year">
      <xsl:call-template name="get-year-from-date">
        <xsl:with-param name="date" select="@notAfter" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="($start-year to $end-year)">
      <field name="origin_date">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:origDate[@notBefore][not(@notAfter)]" mode="document-metadata">
    <xsl:variable name="start-year">
      <xsl:call-template name="get-year-from-date">
        <xsl:with-param name="date" select="@notBefore" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="end-year">
      <xsl:call-template name="get-year-from-date">
        <xsl:with-param name="date" select="'0700'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="($start-year to $end-year)">
      <field name="origin_date">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="tei:origDate[@notAfter][not(@notBefore)]" mode="document-metadata">
    <xsl:variable name="start-year">
      <xsl:call-template name="get-year-from-date">
        <xsl:with-param name="date" select="'-0800'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="end-year">
      <xsl:call-template name="get-year-from-date">
        <xsl:with-param name="date" select="@notAfter" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="($start-year to $end-year)">
      <field name="origin_date">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="text()" mode="document-metadata" />

  <xsl:template match="node()" mode="free-text">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="@lemma" mode="lemma">
    <xsl:value-of select="." />
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="@nymRef" mode="lemma">
    <!-- Only support local references; to add in external references
         would require determining what they are at an earlier step in
         the pipeline and XIncluding the referenced documents. This
         would be a significant change to the existing indexing
         pipeline and XSLT. -->
    <xsl:variable name="root" select="/" />
    <xsl:for-each select="tokenize(., '\s+')">
      <xsl:if test="starts-with(., '#')">
        <!-- Since we have no idea what markup is at the end of this
             reference, just take the text value. -->
        <xsl:value-of select="$root/id(substring-after(current(), '#'))" />
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="node()|@*" mode="lemma">
    <xsl:apply-templates mode="lemma" select="@*|node()" />
  </xsl:template>

  <xsl:template match="tei:*[@key]" mode="entity-mention">
    <doc>
      <xsl:sequence select="$document-metadata" />

      <xsl:call-template name="field_file_path" />
      <xsl:call-template name="field_document_id" />
      <field name="section_id">
        <xsl:value-of select="ancestor::tei:*[self::tei:div or self::tei:body or self::tei:front or self::tei:back or self::tei:group or self::tei:text][@xml:id][1]/@xml:id" />
      </field>
      <field name="entity_key">
        <xsl:value-of select="@key" />
      </field>
      <field name="entity_name">
        <xsl:value-of select="normalize-space(.)" />
      </field>
    </doc>
  </xsl:template>

  <xsl:template match="tei:repository[@ref]" mode="facet_source_repository">
    <xsl:variable name="id" select="substring-after(@ref,'#')"/>
    <xsl:variable name="institutions-al" select="'../../../content/xml/authority/institution.xml'"/>  
    <field name="source_repository">
      <xsl:choose>
        <xsl:when test="doc-available($institutions-al) = fn:true() and document($institutions-al)//tei:place[@xml:id=$id]//tei:placeName">
          <xsl:value-of select="document($institutions-al)//tei:place[@xml:id=$id]//tei:placeName"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$id"/>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>

  <xsl:template match="tei:material" mode="facet_support_material">
    <field name="support_material">
      <xsl:choose>
        <xsl:when test="text()">
          <xsl:value-of select="upper-case(substring(., 1, 1))" />
          <xsl:value-of select="substring(., 2)" />
        </xsl:when>
        <xsl:otherwise><xsl:text>-</xsl:text></xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>

  <xsl:template match="tei:origPlace" mode="facet_place_of_origin">
    <field name="place_of_origin">
      <xsl:choose>
        <xsl:when test="tei:placeName">
          <xsl:value-of select="tei:placeName" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(., '.', '')" />
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:origDate[@evidence]" mode="facet_dating_criteria">
    <xsl:for-each select="tokenize(@evidence, '\s+')">
      <field name="dating_criteria">
        <xsl:value-of select="upper-case(substring(normalize-space(.), 1, 1))" />
        <xsl:value-of select="substring(normalize-space(translate(., '-', ' ')), 2)" />
      </field>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:objectType" mode="facet_support_object_type">
    <field name="support_object_type">
      <xsl:value-of select="upper-case(substring(normalize-space(.), 1, 1))" />
      <xsl:value-of select="substring(normalize-space(.), 2)" />
    </field>
  </xsl:template>

  <xsl:template match="tei:persName[@ref]" mode="facet_mentioned_people">
    <field name="mentioned_people">
      <xsl:value-of select="@ref" />
    </field>
  </xsl:template>

  <xsl:template match="text()" mode="facet_mentioned_people" />
  
  <xsl:template match="tei:placeName[@type='ancientFindspot']" mode="facet_findspot">
    <field name="findspot">
      <xsl:value-of select=".[1]" />
    </field>
  </xsl:template>

  <xsl:template match="tei:provenance[@type='found']//tei:placeName[@type='ancientFindspot']" mode="facet_findspot_upper_level">
    <field name="findspot_upper_level">
      <!--<xsl:text>I. </xsl:text>--><xsl:value-of select="." />
    </field>
  </xsl:template>
  <xsl:template match="tei:provenance[@type='found']//tei:placeName[not(@type='ancientFindspot')][not(@type='monuList')]" mode="facet_findspot_intermediate_level">
    <field name="findspot_intermediate_level">
      <!--<xsl:text>II. </xsl:text>--><xsl:value-of select="." />
    </field>
  </xsl:template>
  <xsl:template match="tei:provenance[@type='found']//tei:placeName[@type='monuList']" mode="facet_findspot_lower_level">
    <field name="findspot_lower_level">
      <!--<xsl:text>III. </xsl:text>--><xsl:value-of select="." />
    </field>
  </xsl:template>

  <xsl:template match="tei:placeName[@ref] | tei:geogName[@ref]" mode="facet_mentioned_places">
    <field name="mentioned_places">
      <xsl:value-of select="@ref" />
    </field>
  </xsl:template>

  <xsl:template match="text()" mode="facet_mentioned_places" />

  <xsl:template name="field_document_id">
    <field name="document_id">
      <xsl:variable name="idno" select="/tei:*/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='filename']" />
      <xsl:choose>
        <xsl:when test="normalize-space($idno)">
          <xsl:value-of select="$idno" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="/tei:*/@xml:id" />
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>

  <xsl:template name="field_document_type">
    <field name="document_type">
      <xsl:value-of select="substring-before($file-path, '/')" />
    </field>
  </xsl:template>

  <xsl:template name="field_file_path">
    <field name="file_path">
      <xsl:value-of select="$file-path" />
    </field>
  </xsl:template>
  
  <xsl:template name="field_findspot">
    <xsl:apply-templates mode="facet_findspot" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:provenance[@type='found']//tei:placeName[@type='ancientFindspot'][1]" />
  </xsl:template>

  <xsl:template name="field_findspot_upper_level">
    <xsl:apply-templates mode="facet_findspot_upper_level" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:provenance[@type='found']//tei:placeName[@type='ancientFindspot']" />
  </xsl:template>
  <xsl:template name="field_findspot_intermediate_level">
    <xsl:apply-templates mode="facet_findspot_intermediate_level" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:provenance[@type='found']//tei:placeName[not(@type='ancientFindspot')][not(@type='monuList')]" />
  </xsl:template>
  <xsl:template name="field_findspot_lower_level">
    <xsl:apply-templates mode="facet_findspot_lower_level" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:provenance[@type='found']//tei:placeName[@type='monuList']" />
  </xsl:template>

  <xsl:template name="field_lemmatised_text">
    <field name="lemmatised_text">
      <xsl:apply-templates mode="lemma" select="//tei:text" />
    </field>
  </xsl:template>

  <xsl:template name="field_mentioned_people">
    <xsl:apply-templates mode="facet_mentioned_people" select="//tei:text/tei:body/tei:div[@type='edition']" />
  </xsl:template>

  <xsl:template name="field_mentioned_places">
    <xsl:apply-templates mode="facet_mentioned_places" select="//tei:text/tei:body/tei:div[@type='edition']" />
  </xsl:template>

  <xsl:template name="field_place_of_origin">
    <xsl:apply-templates mode="facet_place_of_origin" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origPlace" />
  </xsl:template>

  <xsl:template name="field_source_repository">
    <xsl:apply-templates mode="facet_source_repository" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:repository"/>
  </xsl:template>

  <xsl:template name="field_support_material">
    <xsl:apply-templates mode="facet_support_material" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support//tei:material" />
  </xsl:template>
  
  <xsl:template name="field_dating_criteria">
    <xsl:apply-templates mode="facet_dating_criteria" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate[@evidence]"/>
  </xsl:template>

  <xsl:template name="field_support_object_type">
    <xsl:apply-templates mode="facet_support_object_type" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support//tei:objectType" />
  </xsl:template>

  <xsl:template name="field_text">
    <field name="text">
      <xsl:value-of select="normalize-space($free-text)" />
    </field>
  </xsl:template>

  <!-- Return an integer year from a "date", that might be in one of a
       number of formats. Specifically, handles YYYY, YYYY-MM, and
       YYYY-MM-DD, with optional preceding "-". -->
  <xsl:template name="get-year-from-date">
    <xsl:param name="date" />
    <xsl:variable name="parts" select="tokenize(substring($date, 2), '-')" />
    <xsl:variable name="normalised-date">
      <xsl:value-of select="$date" />
      <xsl:choose>
        <xsl:when test="count($parts) = 1">
          <xsl:text>-01-01</xsl:text>
        </xsl:when>
        <xsl:when test="count($parts) = 2">
          <xsl:text>-01</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="year-from-date(xs:date($normalised-date))" />
  </xsl:template>

</xsl:stylesheet>
