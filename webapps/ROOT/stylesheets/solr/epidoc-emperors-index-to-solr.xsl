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
    <xsl:variable name="root" select="." />
    
    <xsl:variable name="key-values">
      <xsl:for-each select="//tei:persName[@type='emperor'][@key]/@key">
        <xsl:value-of select="normalize-space(.)" />
        <xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="keys"
      select="distinct-values(tokenize(normalize-space($key-values), '\s+'))" />
    <add>
      <xsl:for-each select="$keys">
        <xsl:variable name="key-value" select="." />
        <xsl:variable name="key" select="document('../../content/xml/authority/emperors.xml')//tei:person[@xml:id=$key-value]"/>
        <xsl:variable name="emperor" select="$root//tei:persName[@type='emperor'][contains(concat(' ', @key, ' '), $key-value)]" />
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
              <xsl:when test="$key">
                <xsl:value-of select="$key/tei:persName" />
                <xsl:if test="$key/tei:floruit"><xsl:text> (</xsl:text><xsl:value-of select="$key/tei:floruit" /><xsl:text>)</xsl:text></xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$key-value" />
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_external_resource">
            <xsl:value-of select="$key/tei:idno" />
          </field>
          <xsl:apply-templates select="$emperor" />
        </doc>
      </xsl:for-each>
    </add>
  </xsl:template>
  
  <!-- Old code, without handling of keys with more values:
    <xsl:template match="/">
    <add>
      <xsl:for-each-group select="//tei:persName[@type='emperor'][@key]" group-by="@key">
        <xsl:variable name="key-id" select="@key"/>
        <xsl:variable name="key" select="document('../../content/xml/authority/emperors.xml')//tei:person[@xml:id=$key-id]"/>
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
              <xsl:when test="$key">
                <xsl:value-of select="$key/tei:persName" />
                <xsl:if test="$key/tei:floruit"><xsl:text> (</xsl:text><xsl:value-of select="$key/tei:floruit" /><xsl:text>)</xsl:text></xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@key" />
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_external_resource">
            <xsl:value-of select="$key/tei:idno" />
          </field>
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>-->

  <xsl:template match="tei:persName">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>
