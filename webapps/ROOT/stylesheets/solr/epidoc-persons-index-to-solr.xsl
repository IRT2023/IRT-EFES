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
      <xsl:for-each select="//tei:persName[@type='attested'][descendant::tei:name[@nymRef]][not(ancestor::tei:persName[@type='attested'])]">
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <xsl:value-of select=".//tei:name[@nymRef][ancestor::tei:persName[@type='attested'][1]][not(ancestor::tei:persName[@type='attested'][2])]/@nymRef"/>
            <xsl:if test="descendant::tei:persName[@type='attested']">
                <xsl:text> of </xsl:text>
              <xsl:value-of select=".//tei:name[@nymRef][ancestor::tei:persName[@type='attested'][2]][not(ancestor::tei:persName[@type='attested'][3])]/@nymRef"/>
              <xsl:if test="descendant::tei:persName[@type='attested'][descendant::tei:persName[@type='attested']]">
                <xsl:text> of </xsl:text>
                <xsl:value-of select=".//tei:name[@nymRef][ancestor::tei:persName[@type='attested'][3]][not(ancestor::tei:persName[@type='attested'][4])]/@nymRef"/>
                <xsl:if test="descendant::tei:persName[@type='attested'][descendant::tei:persName[@type='attested'][descendant::tei:persName[@type='attested']]]">
                  <xsl:text> of </xsl:text>
                  <xsl:value-of select=".//tei:name[@nymRef][ancestor::tei:persName[@type='attested'][4]][not(ancestor::tei:persName[@type='attested'][5])]/@nymRef"/>
                  <xsl:if test="descendant::tei:persName[@type='attested'][descendant::tei:persName[@type='attested'][descendant::tei:persName[@type='attested'][descendant::tei:persName[@type='attested']]]]">
                    <xsl:text> of </xsl:text>
                    <xsl:value-of select=".//tei:name[@nymRef][ancestor::tei:persName[@type='attested'][5]][not(ancestor::tei:persName[@type='attested'][6])]/@nymRef"/>
                    <xsl:if test="descendant::tei:persName[@type='attested'][descendant::tei:persName[@type='attested'][descendant::tei:persName[@type='attested'][descendant::tei:persName[@type='attested'][descendant::tei:persName[@type='attested']]]]]">
                      <xsl:text> of </xsl:text>
                      <xsl:value-of select=".//tei:name[@nymRef][ancestor::tei:persName[@type='attested'][6]][not(ancestor::tei:persName[@type='attested'][7])]/@nymRef"/>
                    </xsl:if>
                  </xsl:if>
                </xsl:if>
              </xsl:if>
            </xsl:if>
            <!-- not handling possible ethnics/provenance of patronymics -->
            <xsl:if test="descendant::tei:placeName[not(@type='ethnic')]">
              <xsl:text> from </xsl:text>
              <xsl:value-of select="tei:placeName[not(@type='ethnic')][1]"/>
              <xsl:if test="descendant::tei:placeName[not(@type='ethnic')][2]">
              <xsl:text> and </xsl:text>
                <xsl:value-of select="tei:placeName[not(@type='ethnic')][2]"/>
            </xsl:if>
            </xsl:if>
            <xsl:if test="descendant::tei:placeName[@type='ethnic']">
              <xsl:text> </xsl:text>
              <xsl:value-of select="tei:placeName[@type='ethnic']"/>
            </xsl:if>
          </field>
          <field name="index_external_resource">
            <xsl:value-of select="@key" />
          </field>
          <xsl:apply-templates select="." />
        </doc>
      </xsl:for-each>
    </add>
  </xsl:template>

  <xsl:template match="tei:persName">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>
