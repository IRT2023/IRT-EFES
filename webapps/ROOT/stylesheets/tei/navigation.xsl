<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
  xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:template name="inscriptionnav">
    <xsl:param name="next_inscr"/>
    <xsl:param name="prev_inscr"/>
    
    <xsl:variable name="filename">
      <xsl:value-of select="//tei:idno[@type='filename']"/>
    </xsl:variable>
    
    <xsl:variable name="prev" select="/aggregation/response/result/doc[str[@name = 'file_path' and text() = $filename]]/preceding-sibling::doc[1]/str[@name = 'file_path']"/>
    <xsl:variable name="next" select="/aggregation/response/result/doc[str[@name = 'file_path' and text() = $filename]]/following-sibling::doc[1]/str[@name = 'file_path']"/>
    
    <!--  
      possible @select values (?):
        
      ./preceding-sibling::doc[1]//tei:idno[@name='filename']
      ./following-sibling::doc[1]//tei:idno[@name='filename']
      
      /aggregation/response/result/doc[str[@name = 'file_path' and text() = $filename]]/preceding-sibling::doc[1]/str[@name='file_path']
      /aggregation/response/result/doc[str[@name = 'file_path' and text() = $filename]]/following-sibling::doc[1]/str[@name='file_path']
      
      IOSPE:
      /aggregation/order//result/doc[str[@name = 'tei-id' and text() = $filename]]/preceding-sibling::doc[1]/str/text()
      /aggregation/order//result/doc[str[@name = 'tei-id' and text() = $filename]]/following-sibling::doc[1]/str/text()
    -->
    
    <div class="row">
      <div class="large-12 columns">
        <ul class="pagination right">
          <li class="arrow">
            <xsl:attribute name="class">
              <xsl:text>arrow</xsl:text>
              <xsl:if test="not($prev)">
                <xsl:text> unavailable</xsl:text>
              </xsl:if>
            </xsl:attribute>
            <a>
              <xsl:attribute name="href">
                <xsl:if test="$prev">
                  <xsl:text>./</xsl:text>
                  <xsl:value-of select="$prev"/>
                  <xsl:text>.html</xsl:text>
                </xsl:if>
              </xsl:attribute>
              <xsl:text>&#171;</xsl:text>
              <i18n:text>Previous</i18n:text>
            </a>
          </li>
          
          <li class="arrow">
            <xsl:attribute name="class">
              <xsl:text>arrow</xsl:text>
              <xsl:if test="not($next)">
                <xsl:text> unavailable</xsl:text>
              </xsl:if>
            </xsl:attribute>
            <a>
              <xsl:attribute name="href">
                <xsl:if test="$next">
                  <xsl:text>./</xsl:text>
                  <xsl:value-of select="$next"/>
                  <xsl:text>.html</xsl:text>
                </xsl:if>
              </xsl:attribute>
              <i18n:text>Next</i18n:text>
              <xsl:text>&#187;</xsl:text>
            </a>
          </li>
        </ul>
      </div>
    </div>
  </xsl:template>

</xsl:stylesheet>
