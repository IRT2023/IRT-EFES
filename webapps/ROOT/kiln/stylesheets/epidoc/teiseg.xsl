<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id$ -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:t="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="t" 
                version="2.0">
  <!-- seg[@type='autopsy'] span added in htm-teiseg.xsl -->
  
  <xsl:template match="t:seg | t:w">
      <xsl:param name="parm-edition-type" tunnel="yes" required="no"></xsl:param>
      <xsl:param name="parm-leiden-style" tunnel="yes" required="no"></xsl:param>
    <xsl:if test="($parm-leiden-style='london' or $parm-leiden-style='panciera') and (@part='M' or @part='F')
         and not(preceding::node()[1][self::t:gap])
         and not(ancestor::t:abbr[not(ancestor::t:expan)])
         and not($parm-edition-type='diplomatic')">
         <xsl:text>-</xsl:text>
      </xsl:if>
    
      <xsl:apply-templates/>
    
      <!-- Found in tpl-certlow.xsl -->
    <xsl:call-template name="cert-low"/>
    
    <xsl:if test="($parm-leiden-style='london' or $parm-leiden-style='panciera') and (@part='I' or @part='M')
         and not(following::node()[1][self::t:gap])
         and not(descendant::ex[last()])
         and not(ancestor::t:abbr[not(ancestor::t:expan)])
         and not($parm-edition-type='diplomatic')">
         <xsl:text>-</xsl:text>
      </xsl:if>
  </xsl:template>
  
 

</xsl:stylesheet>