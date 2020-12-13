<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of symbols in those
       documents. -->

  <xsl:import href="epidoc-index-utils.xsl" />

  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />
  <xsl:param name="w3cdur"/>
  <xsl:param name="request"/>

  <xsl:template match="/">
    <add>
      <xsl:for-each-group select="//tei:date[@type='life-span'][ancestor::tei:div/@type='edition']" group-by="@dur">
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
           <xsl:analyze-string select="@dur" regex="^P(\d+)Y">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:text> year</xsl:text>
                <xsl:if test="xs:integer(regex-group(1)) > 1">s</xsl:if>
                <xsl:text> </xsl:text>
              </xsl:matching-substring>
            </xsl:analyze-string>
            <xsl:analyze-string select="@dur" regex="(\d+)M">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:text> month</xsl:text>
                <xsl:if test="xs:integer(regex-group(1)) > 1">s</xsl:if>
                <xsl:text> </xsl:text>
              </xsl:matching-substring>
            </xsl:analyze-string>
            <xsl:analyze-string select="@dur" regex="(\d+)D">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:text> day</xsl:text>
                <xsl:if test="xs:integer(regex-group(1)) > 1">s</xsl:if>
                <xsl:text> </xsl:text>
              </xsl:matching-substring>
            </xsl:analyze-string>
            <xsl:analyze-string select="@dur" regex="(\d+)H">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:text> hour</xsl:text>
                <xsl:if test="xs:integer(regex-group(1)) > 1">s</xsl:if>
                <xsl:text> </xsl:text>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </field>
          <!--<field name="index_item_sort_dur">
            <xsl:value-of select="substring(current-grouping-key(),2,4 )"/> !!! needs sorting
          </field>-->
          <xsl:apply-templates select="current-group()">
          </xsl:apply-templates>
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>

  <xsl:template match="tei:date[@type='life-span']">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>
