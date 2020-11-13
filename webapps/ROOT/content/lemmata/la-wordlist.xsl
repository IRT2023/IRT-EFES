<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:t="http://www.tei-c.org/ns/1.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <!-- ============== run against all_inscriptions.xml ============== -->
    
    <xsl:template name="ignore" match="//t:sic | //t:orig | //t:am | //t:surplus | //t:del[@rend='corrected']"></xsl:template>
    
    <xsl:template match="/">
        <body>
            <xsl:variable name="lemmata">
                <xsl:for-each select="//t:list/t:item">
                    <xsl:variable name="filename">
                        <xsl:text>../xml/epidoc/</xsl:text>
                        <xsl:value-of select="@n"/>
                    </xsl:variable>
                    <xsl:for-each
                        select="document($filename)//t:div[@type='edition']//t:w[ancestor::t:*[@xml:lang][1][@xml:lang='la'] and not(@part=('F','I','M'))]">
                        <xsl:element name="w">
                            <xsl:if test="string(@lemma)">
                                <xsl:attribute name="lemma">
                                    <xsl:value-of select="@lemma"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:apply-templates select="."/>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:variable>
            <xsl:for-each-group select="$lemmata//w"
                group-by="translate(normalize-space(.), ' ', '')">
                <xsl:sort select="translate(normalize-space(lower-case(.)), ' ', '')"/>
                <word><xsl:value-of select="translate(normalize-space(.), ' ', '')"/></word>
            </xsl:for-each-group>
        </body>
    </xsl:template>

</xsl:stylesheet>
