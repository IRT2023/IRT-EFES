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
            <xsl:for-each-group select="//tei:rs[@type='month'][ancestor::tei:div/@type='edition'][@ref]|//tei:rs[@type='month'][ancestor::tei:div/@type='edition'][@key][not(@ref)]" group-by="concat(translate(@ref, '#', ''), '-', translate(@key, '#', ''))">
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
                <xsl:variable name="idno" select="document('../../content/xml/authority/months.xml')//tei:item[@xml:id=$id]"/>
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
                                <xsl:value-of select="$idno/tei:term[1]" />
                                <xsl:if test="$idno/tei:term[2]">
                                    <xsl:text> / </xsl:text>
                                    <xsl:value-of select="$idno/tei:term[2]" />
                                </xsl:if>
                                <xsl:if test="$idno/tei:date"><xsl:text> (</xsl:text><xsl:value-of select="$idno/tei:date" /><xsl:text>)</xsl:text></xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$id" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </field>
                    <field name="index_attested_form">
                        <xsl:choose>
                            <xsl:when test="@nymRef"><xsl:value-of select="translate(normalize-unicode(@nymRef), '#', '')" /></xsl:when>
                            <xsl:when test="descendant::tei:w[@lemma]"><xsl:value-of select="normalize-unicode(string-join(descendant::tei:w/@lemma, ' '))"/></xsl:when>
                        </xsl:choose>
                    </field>
                    <field name="index_item_sort_name">
                        <xsl:value-of select="$idno/@n" />
                    </field>
                    <field name="index_external_resource">
                        <xsl:value-of select="$idno/tei:idno" />
                    </field>
                    <xsl:apply-templates select="current-group()" />
                </doc>
            </xsl:for-each-group>
        </add>
    </xsl:template>

    <xsl:template match="tei:rs[@type='month']">
        <xsl:call-template name="field_index_instance_location" />
    </xsl:template>

</xsl:stylesheet>
