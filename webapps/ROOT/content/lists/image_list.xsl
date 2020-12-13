<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:t="http://www.tei-c.org/ns/1.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <!-- ============== run against all_inscriptions.xml ============== -->
    
    <xsl:template match="/">
        <body>
            <xsl:variable name="images">
                <xsl:for-each select="//t:list/t:item">
                <xsl:variable name="filename">
                    <xsl:text>../xml/epidoc/</xsl:text>
                    <xsl:value-of select="@n"/>
                </xsl:variable>
                    <xsl:for-each select="document($filename)//t:facsimile//t:graphic">
                        <xsl:element name="image">
                                <xsl:attribute name="url">
                                    <xsl:value-of select="@url"/>
                                </xsl:attribute>
                            <xsl:attribute name="inscription">
                                <xsl:value-of select="ancestor::t:TEI//t:idno[@type='filename']"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="."/>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:for-each select="$images//image">
                <xsl:sort select="@inscription"/>
                <image>
                    <inscription>
                        <xsl:value-of select="@inscription"/>
                    </inscription>
                    <image_file>
                        <xsl:value-of select="@url"/>
                    </image_file>
                    <caption>
                        <xsl:apply-templates select="."/>
                    </caption>
                </image>
            </xsl:for-each>
        </body>
    </xsl:template>

</xsl:stylesheet>
