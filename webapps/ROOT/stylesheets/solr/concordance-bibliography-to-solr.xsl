<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fn="http://www.w3.org/2005/xpath-functions">

  <!-- Index references to bibliographic items. -->

  <xsl:param name="file-path" />

  <xsl:template match="/">
    <add>
      <xsl:for-each-group select="//tei:body/tei:div[@type='bibliography']//tei:bibl/tei:ptr" group-by="@target">
        <xsl:variable name="target" select="translate(@target, '#', '')" />
        <xsl:for-each-group select="current-group()" group-by="../tei:citedRange">
          <doc>
            <field name="document_type">
              <xsl:text>concordance_bibliography</xsl:text>
            </field>
            <field name="file_path">
              <xsl:value-of select="$file-path" />
            </field>
            <field name="concordance_bibliography_ref">
              <xsl:value-of select="$target" />
            </field>
            <field name="concordance_bibliography_date">
                <xsl:variable name="bibliography-al" select="concat('file:',system-property('user.dir'),'/webapps/ROOT/content/xml/authority/bibliography.xml')"/>
                <xsl:if test="doc-available($bibliography-al) = fn:true()">
                  <xsl:value-of select="document($bibliography-al)//tei:bibl[not(@sameAs)][@xml:id=$target]//tei:date[1]" />
                </xsl:if>
            </field>
            <field name="concordance_bibliography_cited_range">
              <xsl:value-of select="../tei:citedRange" />
            </field>
            <field name="concordance_bibliography_type">
              <xsl:variable name="bibl" select="document(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/xml/authority/bibliography.xml'))//tei:bibl[@xml:id=$target][not(@sameAs)]"/>
              <xsl:choose>
                <xsl:when test="$bibl[ancestor::tei:div[@xml:id='authored_editions']]">authored_editions</xsl:when>
                <xsl:when test="$bibl[ancestor::tei:div[@xml:id='series_collections']]">series_collections</xsl:when>
              </xsl:choose>
            </field>
            <xsl:apply-templates select="current-group()/../tei:citedRange" />
          </doc>
        </xsl:for-each-group>
      </xsl:for-each-group>
    </add>
  </xsl:template>

  <xsl:template match="tei:citedRange">
    <field name="concordance_bibliography_item">
      <xsl:value-of select="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='filename']" />
    </field>
  </xsl:template>

</xsl:stylesheet>
