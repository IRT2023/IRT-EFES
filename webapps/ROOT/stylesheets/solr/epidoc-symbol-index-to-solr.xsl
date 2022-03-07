<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of symbols in those
       documents. -->

  <xsl:import href="epidoc-index-utils.xsl" />

  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />

  <xsl:template match="/">
    <add>
      <xsl:for-each-group select="//tei:g[@ref][ancestor::tei:div/@type='edition']" group-by="normalize-unicode(@ref)">
        <xsl:variable name="ref-id" select="substring-after(@ref,'#')"/>
        <xsl:variable name="ref" select="document('../../content/xml/authority/symbols.xml')//tei:glyph[@xml:id=$ref-id]"/>
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <xsl:choose>
              <xsl:when test="$ref">
            <xsl:value-of select="$ref//tei:value[preceding-sibling::tei:localName[text()='text-display']]" />
            <xsl:if test="$ref//tei:localName[text()='glyph-display'][following-sibling::tei:value/text()]">
              <xsl:text> (</xsl:text>
              <xsl:value-of select="$ref//tei:value[preceding-sibling::tei:localName[text()='glyph-display']]" />
              <xsl:text>)</xsl:text>
            </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@ref"/>
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>

  <xsl:template match="tei:g">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>
