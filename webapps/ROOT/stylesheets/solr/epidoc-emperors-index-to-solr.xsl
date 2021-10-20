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
    
    <xsl:variable name="id-values">
      <xsl:for-each select="//tei:persName[@type='emperor'][@ref]/@ref|//tei:persName[@type='emperor'][@key][not(@ref)]/@key">
        <xsl:value-of select="normalize-space(translate(., '#', ''))" />
        <xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="ids"
      select="distinct-values(tokenize(normalize-space($id-values), '\s+'))" />
    <add>
      <xsl:for-each select="$ids">
        <xsl:variable name="id" select="." />
        <xsl:variable name="idno" select="document('../../content/xml/authority/emperors.xml')//tei:person[@xml:id=$id]"/>
        <xsl:variable name="emperor" select="$root//tei:persName[@type='emperor'][contains(concat(' ', translate(@ref, '#', ''), ' '), $id) or contains(concat(' ', translate(@key, '#', ''), ' '), $id)]" />
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
              <xsl:when test="$idno">
                <!--<xsl:value-of select="$idno/@n" />
                <xsl:text>. </xsl:text>-->
                <xsl:value-of select="$idno/tei:persName" />
                <xsl:if test="$idno/tei:floruit"><xsl:text> (</xsl:text><xsl:value-of select="$idno/tei:floruit" /><xsl:text>)</xsl:text></xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$id" />
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_item_sort_name">
            <xsl:value-of select="$idno/@n" />
          </field>
          <field name="index_external_resource">
            <xsl:value-of select="$idno/tei:idno" />
          </field>
          <xsl:apply-templates select="$emperor" />
        </doc>
      </xsl:for-each>
    </add>
  </xsl:template>
  
  <xsl:template match="tei:persName">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>
  
</xsl:stylesheet>
