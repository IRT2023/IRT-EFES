<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of emperors in those
       documents. -->

  <xsl:import href="epidoc-index-utils.xsl" />

  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />
  
  <xsl:template match="/">
    <add>
      <xsl:for-each-group select="//tei:persName[@type='ruler'][@key]|//tei:persName[@type='emperor'][@key]" group-by="concat(normalize-unicode(normalize-space(@key)), '-', normalize-unicode(string-join(descendant::tei:rs[@type='epithet']/@key, ' ')), '-', normalize-unicode(string-join(descendant::tei:name/@nymRef, ' ')))">
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <xsl:value-of select="normalize-unicode(normalize-space(@key))" />
          </field>
          <field name="index_item_type">
            <xsl:value-of select="normalize-unicode(@type)" />
          </field>
          <field name="index_epithet">
            <xsl:for-each select="descendant::tei:rs[@type='epithet'][@key]">
              <xsl:value-of select="@key" />
              <xsl:if test="position()!=last()">, </xsl:if>
            </xsl:for-each>
          </field>
          <field name="index_attested_form">
            <xsl:choose>
              <xsl:when test="descendant::tei:name[@nymRef]"> <!-- or descendant::tei:w[@lemma] -->
                <!-- <xsl:value-of select="translate(normalize-unicode(string-join(descendant::tei:name/@nymRef, ' ')), '#', '')"/> -->
                <xsl:for-each select="descendant::tei:name[@nymRef]"> <!-- |descendant::tei:w[@lemma] -->
              <!--<xsl:choose>
                <xsl:when test="@nymRef">-->
                  <xsl:value-of select="translate(normalize-space(normalize-unicode(@nymRef)), '#', '')" />
                <!--</xsl:when>
                <xsl:when test="@lemma">
                  <xsl:value-of select="translate(normalize-space(normalize-unicode(@lemma)), '#', '')" />
                </xsl:when>
              </xsl:choose>-->
              <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
            </xsl:for-each>
              </xsl:when>
              <!--<xsl:otherwise>
                <xsl:value-of select="normalize-unicode(string-join(., ''))"/>
              </xsl:otherwise>-->
            </xsl:choose>
          </field>
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>
  
  

  <xsl:template match="tei:persName[@type='ruler']|tei:persName[@type='emperor']">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>
