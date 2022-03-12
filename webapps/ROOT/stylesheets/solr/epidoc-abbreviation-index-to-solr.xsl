<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of abbreviations in those
       documents. -->

    <xsl:import href="epidoc-index-utils.xsl" />

    <xsl:param name="index_type" />
    <xsl:param name="subdirectory" />
    
    <xsl:template match="/">
        <add>
            <xsl:for-each-group select="//tei:expan[ancestor::tei:div/@type='edition']" 
                group-by="normalize-unicode(translate(translate(concat(string-join(descendant::tei:abbr//text()|descendant::tei:g/@ref, ''), '-', string-join(.//text()[not(ancestor::tei:am or ancestor::tei:g)], '')), 'Ϲϲ', 'Σσ'), ' ', ''),'NFD')">
                <doc>
                    <field name="document_type">
                        <xsl:value-of select="$subdirectory" />
                        <xsl:text>_</xsl:text>
                        <xsl:value-of select="$index_type" />
                        <xsl:text>_index</xsl:text>
                    </field>
                    <xsl:call-template name="field_file_path" />
                    <field name="index_item_name">
                        <xsl:variable name="abbr">
                            <xsl:for-each select="descendant::tei:abbr//node()[self::text()[not(ancestor::tei:g)] or self::tei:g//text() or self::tei:g/@ref]">
                                <xsl:choose>
                                    <xsl:when test="self::tei:g//text() or self::tei:g/@ref">
                                        <xsl:variable name="g">
                                            <xsl:choose>
                                                <xsl:when test="contains(string-join(self::tei:g//text()|self::tei:g/@ref, ''), '#')">
                                                    <xsl:value-of select="substring-after(string-join(self::tei:g//text()|self::tei:g/@ref, ''), '#')"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="string-join(self::tei:g//text()|self::tei:g/@ref, '')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <xsl:variable name="symbolsAL" select="'../../content/xml/authority/symbols.xml'"/>
                                        <xsl:variable name="glyph" select="document($symbolsAL)//tei:glyph[@xml:id=$g]"/> 
                                        <xsl:choose>
                                            <xsl:when test="doc-available($symbolsAL) = fn:true() and $glyph/tei:charProp[descendant::tei:localName='glyph-display']/tei:value/text()!=''">
                                                <xsl:value-of select="$glyph/tei:charProp[descendant::tei:localName='glyph-display']/tei:value" />
                                            </xsl:when>
                                            <xsl:when test="string-join(self::tei:g//text(), '')">
                                                <xsl:value-of select="upper-case($g)"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>(</xsl:text>
                                                <xsl:value-of select="upper-case($g)"/>
                                                <xsl:text>)</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="upper-case(.)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:value-of select="translate(translate(translate(normalize-unicode(normalize-space(string-join($abbr, '')),'NFD'), 'Ϲϲ', 'Σσ'),'&#x300;&#x0301;&#x0313;&#x0314;&#x0342;&#xfe26;&#772;',''), ' ', '')" />
                    </field>
                    <field name="index_abbreviation_expansion">
                        <xsl:value-of select="normalize-unicode(normalize-space(replace(translate(string-join(.//text()[not(ancestor::tei:am or ancestor::tei:g)], ''), 'Ϲϲ', 'Σσ'), 'σ([:punct:]{1}|[:blank:]{1}|$)', 'ς$1')), 'NFD')"/>
                    </field>
                    <xsl:apply-templates select="current-group()" />
                </doc>
            </xsl:for-each-group>
        </add>
    </xsl:template>

    <xsl:template match="tei:expan">
        <xsl:call-template name="field_index_instance_location" />
    </xsl:template>
    
</xsl:stylesheet>
