<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
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
            <xsl:for-each-group select="//tei:expan[ancestor::tei:div/@type='edition'][not(parent::tei:abbr)]" 
                group-by="concat(upper-case(normalize-unicode(translate(translate(normalize-space(string-join(.//tei:abbr//text(), '')), 'Ϲ', 'Σ'),'&#x300;&#x0301;&#x0313;&#x0314;&#x0342;',''),'NFD')),'-',lower-case(normalize-unicode(replace(translate(normalize-space(string-join(.//text(),'')), 'Ϲϲ', 'Σσ'), 'σ([:punct:]{1}|[:blank:]{1}|$)', 'ς$1'),'NFD')))"> <!-- added //text(), normalize-unicode(), normalize-space(), upper-case(), lower-case(), string-join(), translate()x2 -->
                <!--<xsl:sort order="ascending"
                    select="translate(normalize-unicode(current-grouping-key(),'NFD'),'&#x0301;&#x0313;&#x0314;&#x0342;','')"/>-->
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
                            <xsl:when test="descendant::tei:g">
                                <xsl:value-of select="concat(normalize-unicode(normalize-space(substring-after(descendant::tei:g/@ref,'#')),'NFD'), 'QQQQQ')" /> <!-- added normalize-unicode(), normalize-space(), lower-case(); substring-after(descendant::tei:g/@ref,'#') instead of $base-uri, descendant::tei:g/@ref -->
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="upper-case(translate(normalize-unicode(translate(normalize-space(string-join(.//tei:abbr//text(), '')), 'Ϲϲ', 'Σσ'),'NFD'),'&#x300;&#x0301;&#x0313;&#x0314;&#x0342;',''))" /> <!-- added //text(), normalize-unicode(), normalize-space(), upper-case(), translate()x2 -->
                            </xsl:otherwise>
                        </xsl:choose>
                    </field>
                    <field name="index_item_sort_name">
                        <xsl:choose>
                            <xsl:when test="descendant::tei:g">
                                <xsl:value-of select="lower-case(translate(normalize-unicode(normalize-space(concat(substring-after(descendant::tei:g/@ref,'#'), 'QQQQQ')),'NFD'),'&#x300;&#x0301;&#x0313;&#x0314;&#x0342;',''))" /> <!-- substring-after(descendant::tei:g/@ref,'#') instead of $base-uri, descendant::tei:g/@ref; added normalize-space() -->
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="upper-case(translate(normalize-unicode(normalize-space(string-join(.//tei:abbr//text(), '')),'NFD'),'&#x300;&#x0301;&#x0313;&#x0314;&#x0342;',''))" /> <!-- added //text(), normalize-space(), translate(), upper-case() -->
                            </xsl:otherwise>
                        </xsl:choose>
                    </field>
                    <field name="language_code">
                        <xsl:value-of select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
                    </field>
                    <field name="index_abbreviation_expansion">
                        <xsl:value-of select="normalize-unicode(replace(translate(normalize-space(string-join(.//text()[not(ancestor::tei:am)], '')), 'Ϲϲ', 'Σσ'), 'σ([:punct:]{1}|[:blank:]{1}|$)', 'ς$1'), 'NFD')"/>  <!-- .//text()[not(ancestor::tei:am)] -->
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
