<?xml version="1.0"?>

<!-- XSLT to normalize unicode -->

<!-- |||||||||||||||  run against files inside webapps/ROOT/content/xml/epidoc |||||||||||||| -->
<!--  ||||||||||||||  NB do it without an internet connection, otherwise some unwanted attributes will be added, among which @default="false", @part="N",  @instant="false", @status="draft", @full="yes", @org="uniform", @sample="complete" |||||||||||||| -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:date="http://exslt.org/dates-and-times" >
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
    
    <!-- ||||||||||||||||||||||  copy all existing elements, comments  |||||||||||||||| -->
    
    <xsl:template match="t:*">
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="//comment()">
        <xsl:copy>
            <xsl:value-of select="."/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="//processing-instruction()">
        <xsl:text>
</xsl:text>
        <xsl:copy>
            <xsl:value-of select="."/>
        </xsl:copy>
    </xsl:template>    
    
    <xsl:template match="t:TEI">
        <xsl:text>
</xsl:text>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- ||||||||||||||||||||||   normalize-unicode  ||||||||||||||||||||||||| -->
    
    <xsl:template match="t:div[@type='edition']//text()">
        <xsl:value-of select="normalize-unicode(.)"/>
    </xsl:template>
    
    <xsl:template match="@lemma|@nymRef">
        <xsl:copy>
            <xsl:value-of select="normalize-unicode(.)"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
