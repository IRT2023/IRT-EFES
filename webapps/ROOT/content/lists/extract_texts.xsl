<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:t="http://www.tei-c.org/ns/1.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <!-- ============== run against all_inscriptions.xml ============== -->
    
    <xsl:template match="/">
        <body>
                <xsl:for-each select="//t:list/t:item">
                    <xsl:variable name="filename"><xsl:value-of select="@n"/></xsl:variable>
                <xsl:variable name="filepath"><xsl:text>../xml/epidoc/</xsl:text><xsl:value-of select="@n"/></xsl:variable>
                    <xsl:for-each select="document($filepath)//t:div[@type='edition']">
                        <xsl:text>
[REF:</xsl:text><xsl:value-of select="$filename"/><xsl:text>] </xsl:text>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:for-each>
                </xsl:for-each>
        </body>
    </xsl:template>

</xsl:stylesheet>
