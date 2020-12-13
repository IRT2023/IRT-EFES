<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Project-specific XSLT for transforming EpiDoc TEI to
       HTML. Customisations here override those in the core
       start-edition.xsl (which should not be changed). -->

  <xsl:import href="../../kiln/stylesheets/epidoc/start-edition.xsl" />
     
     
     <!-- remove 'apparatus' heading (htm-teidivapparatus.xsl) as inslib has its own 'Apparatus' heading -->
     <xsl:template match="tei:div[@type='apparatus']" priority="1">
          <xsl:param name="parm-external-app-style" tunnel="yes" required="no"/>
          <div id="apparatus">
               <p>
                    <xsl:apply-templates/>
               </p>
          </div>
     </xsl:template>

</xsl:stylesheet>
