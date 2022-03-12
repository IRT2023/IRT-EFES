<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of mentioned places in those
       documents. -->

  <xsl:import href="epidoc-index-utils.xsl" />

  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />

  <xsl:template match="/">
    <add>
      <xsl:for-each-group select="//tei:div[@type='edition']//tei:placeName[@nymRef or @ref]" group-by="concat(@ref,'-',normalize-unicode(@nymRef,'NFD'),'-',@type)">
        <xsl:variable name="ref-id">
            <xsl:choose>
              <xsl:when test="contains(@ref, '#')">
                <xsl:value-of select="normalize-unicode(substring-after(@ref, '#'),'NFD')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="normalize-unicode(@ref,'NFD')"/>
              </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="nymRef-id">
          <xsl:choose>
            <xsl:when test="contains(@nymRef, '#')">
              <xsl:value-of select="normalize-unicode(substring-after(@nymRef, '#'),'NFD')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-unicode(@nymRef,'NFD')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="placesAL" select="'../../content/xml/authority/places.xml'"/>
        <xsl:variable name="ref" select="document($placesAL)//tei:place[@xml:id=$ref-id]"/>
        <xsl:variable name="nymRef" select="document($placesAL)//tei:place//tei:placeName[.=$nymRef-id]"/>
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
              <xsl:when test="doc-available($placesAL) = fn:true() and $ref">
                <xsl:choose>
                  <xsl:when test="$ref//tei:placeName[@xml:lang='en']"><xsl:value-of select="$ref//tei:placeName[@xml:lang='en'][1]" /></xsl:when>
                  <xsl:otherwise>
                    <xsl:choose>
                    <xsl:when test="$ref//tei:placeName[@xml:lang='la']"><xsl:value-of select="$ref//tei:placeName[@xml:lang='la'][1]" /></xsl:when>
                  <xsl:otherwise><xsl:value-of select="$ref//tei:placeName[1]" /></xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$nymRef-id" />
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_attested_form">
            <xsl:choose>
              <xsl:when test="doc-available($placesAL) = fn:true() and $nymRef">
                <xsl:value-of select="$nymRef[1]" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$nymRef-id" />
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_ethnic">
            <xsl:choose>
              <xsl:when test="@type">
                <xsl:value-of select="@type"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>toponym</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_external_resource">
            <xsl:value-of select="$ref/tei:idno" />
          </field>
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>

  <xsl:template match="tei:placeName">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>
