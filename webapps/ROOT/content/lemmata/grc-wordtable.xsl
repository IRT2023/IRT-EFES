<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:t="http://www.tei-c.org/ns/1.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <!-- ============== run against all_inscriptions.xml ============== -->

    <xsl:template match="/">
        <body>
            <xsl:variable name="lemmata">
                <xsl:for-each select="//t:list/t:item">
                <xsl:variable name="filename">
                    <xsl:text>../webapps/ROOT/content/xml/epidoc/</xsl:text>
                    <xsl:value-of select="@n"/>
                </xsl:variable>
                    <xsl:for-each
                        select="document($filename)//t:div[@type='edition']//t:w[ancestor::t:*[@xml:lang][1][@xml:lang='grc'] and not(@part=('F','I','M','Y'))]">
                        <xsl:element name="w">
                            <xsl:if test="string(@lemma)">
                                <xsl:attribute name="lemma">
                                    <xsl:value-of select="@lemma"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:choose>    
                                <xsl:when test="descendant::t:reg"><xsl:value-of select=".//t:reg"/></xsl:when>
                                <xsl:when test="descendant::t:corr"><xsl:value-of select=".//t:corr"/></xsl:when>
                                <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:for-each-group select="$lemmata//w"
                group-by="translate(normalize-space(.), ' ', '')">
                <xsl:sort select="translate(normalize-space(lower-case(.)), ' ', '')"/>
                <word xml:lang="grc">
                    <token>
                        <xsl:value-of select="translate(normalize-space(.), ' ', '')"/>
                    </token>
                    <lemma>
                        <xsl:value-of select="@lemma"/>
                    </lemma>
                    <alllemmata>
                        <xsl:for-each-group
                            select="$lemmata//w[translate(normalize-space(.), ' ', '')=translate(normalize-space(current()), ' ', '')]"
                            group-by="concat(translate(normalize-space(.), ' ', ''),@lemma)">
                            <xsl:value-of select="@lemma"/>
                            <xsl:text> </xsl:text>
                        </xsl:for-each-group>
                    </alllemmata>
                </word>
            </xsl:for-each-group>
        </body>
    </xsl:template>

</xsl:stylesheet>
