<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="../../kiln/stylesheets/solr/tei-to-solr.xsl" />

  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Oct 18, 2010</xd:p>
      <xd:p><xd:b>Author:</xd:b> jvieira</xd:p>
      <xd:p>This stylesheet converts a TEI document into a Solr index document. It expects the parameter file-path,
      which is the path of the file being indexed.</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:template match="/">
    <add>
      <xsl:apply-imports />
    </add>
  </xsl:template>
  
  <xsl:template match="tei:rs[@type='textType']/text()" mode="facet_text_type">
    <field name="text_type">
      <xsl:value-of select="upper-case(substring(normalize-space(.), 1, 1))" />
      <xsl:value-of select="substring(normalize-space(.), 2)" />
    </field>
  </xsl:template>
  
  <xsl:template match="tei:div[@xml:lang!='en']|tei:ab[@xml:lang!='en']|tei:foreign[@xml:lang!='en']" mode="facet_language">
    <field name="language">
      <xsl:choose>
        <xsl:when test="@xml:lang='la'"><xsl:text>Latin</xsl:text></xsl:when>
        <xsl:when test="@xml:lang='grc'"><xsl:text>Ancient Greek</xsl:text></xsl:when>
        <xsl:when test="@xml:lang='grc-Latn'">Transliterated Greek</xsl:when>
        <xsl:when test="@xml:lang='ber-Latn'">Latino-Punic</xsl:when>
        <xsl:when test="@xml:lang='xpu' or @xml:lang='xpu-Latn'">Neo-Punic</xsl:when>
        <xsl:otherwise><xsl:value-of select="@xml:lang" /></xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  
  <xsl:template match="tei:rs[@type='execution']" mode="facet_execution_technique">
    <field name="execution_technique">
      <xsl:variable name="id">
        <xsl:choose>
          <xsl:when test="@ref">
            <xsl:value-of select="translate(@ref,' #', '')"/>
          </xsl:when>
          <xsl:when test="@key and not(@ref)">
            <xsl:value-of select="translate(@key,' #', '')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="translate(.,' #', '')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="execution-al" select="'../../content/xml/authority/execution.xml'"/>
      <xsl:choose>
        <xsl:when test="doc-available($execution-al) = fn:true() and document($execution-al)//tei:item[@xml:id=$id]">
          <xsl:value-of select="normalize-space(translate(translate(document($execution-al)//tei:item[@xml:id=$id]/tei:term[@xml:lang='en'], '/', '／'), '_', ' '))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="upper-case(substring(normalize-space(translate(translate($id, '_', ' '), '/', '／')), 1, 1))" />
          <xsl:value-of select="substring(normalize-space(translate(translate($id, '_', ' '), '/', '／')), 2)" />
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:idno[@type='filename']" mode="facet_ordered_id">
    <field name="ordered_id">
      <xsl:variable name="filename-letter" select="substring-before(., '.')"/>
      <xsl:variable name="filename-no" select="substring-after(., '.')"/>
      <xsl:variable name="filename-number">
        <xsl:choose>
          <xsl:when test="string-length($filename-no)=1"><xsl:value-of select="concat('00',$filename-no)"/></xsl:when>
          <xsl:when test="string-length($filename-no)=2"><xsl:value-of select="concat('0',$filename-no)"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="$filename-no"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="concat($filename-letter,'.',$filename-number)"/>
    </field>
  </xsl:template>

  <xsl:template match="tei:repository[text()]|tei:provenance[@type='observed' or @type='not-observed']//tei:placeName[text()]" mode="facet_last_recorded_location">
    <field name="last_recorded_location">
      <xsl:value-of select="." />
    </field>
  </xsl:template>
  
  <xsl:template match="tei:div[@type='edition']" mode="facet_direction_of_the_text">
    <field name="direction_of_the_text">
      <xsl:choose>
        <xsl:when test="descendant::tei:lb[@rend='left-to-right'] and descendant::tei:lb[@rend='right-to-left']">Boustrophedon</xsl:when>
        <xsl:when test="descendant::tei:lb[@rend='right-to-left'] and not(descendant::tei:lb[@rend='left-to-right'])">Right-to-left</xsl:when>
        <xsl:when test="descendant::tei:lb[@rend='left-to-right'] and not(descendant::tei:lb[@rend='right-to-left'])">Left-to-right</xsl:when>
        <xsl:otherwise>Left-to-right</xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:lg|tei:l[@met]" mode="facet_verse_line">
    <field name="verse_line">
      <xsl:choose>
        <xsl:when test="@met">
          <xsl:value-of select="upper-case(substring(normalize-space(@met), 1, 1))" />
          <xsl:value-of select="substring(normalize-space(@met), 2)" />
        </xsl:when>
        <xsl:otherwise><xsl:text>Other</xsl:text></xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:div[@type='bibliography']//tei:p" mode="facet_previously_unpublished">
    <field name="previously_unpublished">
      <xsl:choose>
        <xsl:when test="contains(lower-case(.), 'not previously published')"><xsl:text>Yes</xsl:text></xsl:when>
        <xsl:otherwise><xsl:text>No</xsl:text></xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>

  <!-- This template is called by the Kiln tei-to-solr.xsl as part of
       the main doc for the indexed file. Put any code to generate
       additional Solr field data (such as new facets) here. -->
  <xsl:template name="extra_fields">
    <xsl:call-template name="field_text_type"/>
    <xsl:call-template name="field_language"/>
    <xsl:call-template name="field_ordered_id"/>
    <xsl:call-template name="field_last_recorded_location"/>
    <xsl:call-template name="field_execution_technique"/>
    <xsl:call-template name="field_direction_of_the_text"/>
    <xsl:call-template name="field_verse_line"/>
  <xsl:call-template name="field_previously_unpublished"/>
  </xsl:template>
  
  <xsl:template name="field_text_type">
    <xsl:apply-templates mode="facet_text_type" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:rs[@type='textType']"/>
  </xsl:template>
  
  <xsl:template name="field_language">
    <xsl:apply-templates mode="facet_language" select="//tei:text/tei:body/tei:div[@type='edition']"/>
  </xsl:template>
  
  <xsl:template name="field_ordered_id">
    <xsl:apply-templates mode="facet_ordered_id" select="//tei:publicationStmt//tei:idno[@type='filename']"/>
  </xsl:template>
  
  <xsl:template name="field_last_recorded_location">
    <xsl:apply-templates mode="facet_last_recorded_location" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc"/>
  </xsl:template>
  
  <xsl:template name="field_execution_technique">
    <xsl:apply-templates mode="facet_execution_technique" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout"/>
  </xsl:template>
  
  <xsl:template name="field_direction_of_the_text">
    <xsl:apply-templates mode="facet_direction_of_the_text" select="/tei:TEI/tei:text/tei:body/tei:div[@type='edition']"/>
  </xsl:template>
  
  <xsl:template name="field_verse_line">
    <xsl:apply-templates mode="facet_verse_line" select="/tei:TEI/tei:text/tei:body/tei:div[@type='edition']"/>
  </xsl:template>

<xsl:template name="field_previously_unpublished">
    <xsl:apply-templates mode="facet_previously_unpublished" select="/tei:TEI/tei:text/tei:body/tei:div[@type='bibliography']"/>
  </xsl:template>

</xsl:stylesheet>
