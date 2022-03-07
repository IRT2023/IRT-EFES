<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
    version="2.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of months in those
       documents. -->

    <xsl:import href="epidoc-index-utils.xsl" />

    <xsl:param name="index_type" />
    <xsl:param name="subdirectory" />


    <xsl:template match="/">
        <add>
            <xsl:for-each-group select="//tei:name[@type='festival']" group-by="concat(normalize-unicode(@key), '-', normalize-unicode(@nymRef))">
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
                            <xsl:when test="@key"><xsl:value-of select="normalize-unicode(@key)"/></xsl:when>
                            <xsl:otherwise><xsl:text>-</xsl:text></xsl:otherwise>
                        </xsl:choose>
                    </field>
                    <field name="index_attested_form">
                        <xsl:choose>
                            <xsl:when test="@nymRef"><xsl:value-of select="translate(normalize-unicode(@nymRef), '#', '')" /></xsl:when>
                            <xsl:otherwise><xsl:text>-</xsl:text></xsl:otherwise>
                        </xsl:choose>
                    </field>
                    <xsl:apply-templates select="current-group()" />
                </doc>
            </xsl:for-each-group>
        </add>
    </xsl:template>

    <xsl:template match="tei:name[@type='festival']">
        <xsl:call-template name="field_index_instance_location" />
    </xsl:template>

</xsl:stylesheet>
