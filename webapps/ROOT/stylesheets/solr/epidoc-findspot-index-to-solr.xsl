<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of findspots. -->

  <xsl:import href="epidoc-index-utils.xsl" />

  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />

  <xsl:template match="/">
    <add>
      <xsl:for-each-group select="//tei:provenance[@type='found']//tei:placeName[@type='ancientFindspot'][1]" group-by="concat(@ref,'-',following-sibling::tei:placeName[not(@type)][1]/@ref,'-',string-join(following-sibling::tei:*[@type='monuList']/@ref, ' '))">
        <xsl:variable name="place" select="normalize-space(string-join(., ''))"/>
        <xsl:variable name="placesAL" select="'../../content/xml/authority/places.xml'"/>
        <xsl:variable name="place-n" select="document($placesAL)//tei:listPlace[descendant::tei:head=$place]/@n"/>
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <!-- upper level -->
            <xsl:value-of select="normalize-space(.)" />
            
            <!-- intermediate level -->
              <xsl:if test="following-sibling::tei:placeName[not(@type)]">
                <xsl:text>. </xsl:text>
                <xsl:value-of select="normalize-space(following-sibling::tei:placeName[not(@type)][1])"/>
              </xsl:if>
            
            <!-- lower level -->
              <xsl:if test="following-sibling::tei:*[@type='monuList']">
                <xsl:text>. </xsl:text>
                <xsl:for-each select="following-sibling::tei:*[@type='monuList']">
                  <xsl:value-of select="normalize-space(.)" />
                  <xsl:if test="position()!=last()"><xsl:text>; </xsl:text></xsl:if>
                </xsl:for-each>
              </xsl:if>
          </field>
          
          <xsl:if test="doc-available($placesAL) = fn:true() and $place-n">
            <field name="index_item_sort_name">
              <xsl:value-of select="concat($place-n, following-sibling::tei:placeName[not(@type)][1], following-sibling::tei:*[@type='monuList'][1])" />
           </field>
          </xsl:if>
          
          <field name="index_external_resource">
            <xsl:for-each select="following-sibling::tei:*[@type='monuList']/@ref|following-sibling::tei:placeName[not(@type)][1]/@ref|@ref">
              <xsl:value-of select="." />
              <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
            </xsl:for-each>
          </field>
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>

  <xsl:template match="tei:placeName[ancestor::tei:provenance[@type='found']]">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>
