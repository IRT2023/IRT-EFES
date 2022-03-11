<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
  version="2.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of divinities in those
       documents. -->
  
  <xsl:import href="epidoc-index-utils.xsl" />
  
  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />
  
  <xsl:template match="/">
    <add>
      <xsl:for-each-group select="//tei:persName[@type='divine'][@ref or @key]" group-by="normalize-unicode(translate(concat(@ref, '-', @key, '-', string-join(descendant::tei:addName/@nymRef, ' '), '-', string-join(descendant::tei:rs[@type='epithet']/@key, ' '), '-', string-join(descendant::tei:name/@nymRef, ' ')), '#', ''))">
        <xsl:variable name="self" select="."/>
        <xsl:variable name="id">
          <xsl:choose>
            <xsl:when test="@ref">
              <xsl:value-of select="translate(normalize-unicode(@ref), '#', '')"/>
            </xsl:when>
            <xsl:when test="@key and not(@ref)">
              <xsl:value-of select="translate(normalize-unicode(@key), '#', '')"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="divineAL" select="'../../content/xml/authority/divine.xml'"/>
        <xsl:variable name="idno" select="document($divineAL)//tei:person[@xml:id=$id]"/>
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
              <xsl:when test="doc-available($divineAL) = fn:true() and $idno">
                <xsl:value-of select="$idno/tei:persName[1]" />
                <xsl:if test="$idno/tei:persName[2]">
                  <xsl:text> / </xsl:text>
                  <xsl:value-of select="$idno/tei:persName[2]" />
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$id" />
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_epithet">
            <xsl:for-each select="descendant::tei:addName[@nymRef][not(ancestor::tei:persName[ancestor::tei:persName=$self])]|descendant::tei:rs[@type='epithet'][@key]">
              <xsl:choose>
                <xsl:when test="@nymRef">
                  <xsl:value-of select="normalize-unicode(translate(translate(@nymRef, '_', '-'), '#', ''))" />
                </xsl:when>
                <xsl:when test="@key">
                  <xsl:value-of select="normalize-unicode(translate(translate(@key, '_', '-'), '#', ''))" />
                </xsl:when>
              </xsl:choose>  
              <xsl:if test="position()!=last()">, </xsl:if>
            </xsl:for-each>
          </field>
          <field name="index_attested_form">
            <xsl:choose>
              <xsl:when test="descendant::tei:name[@nymRef]">
                <xsl:for-each select="descendant::tei:name[@nymRef]">
                  <xsl:value-of select="translate(translate(normalize-space(normalize-unicode(@nymRef)), '_', '-'), '#', '')" />
                  <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
                </xsl:for-each>
              </xsl:when>
            </xsl:choose>
          </field>
          <field name="index_external_resource">
            <xsl:if test="doc-available($divineAL) = fn:true() and $idno">
              <xsl:value-of select="$idno/tei:idno" />
            </xsl:if>
          </field>
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>
  
  <xsl:template match="tei:persName">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>
  
</xsl:stylesheet>
