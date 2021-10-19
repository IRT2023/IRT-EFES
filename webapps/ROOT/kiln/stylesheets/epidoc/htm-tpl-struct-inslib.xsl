<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id$ -->
<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:t="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="t"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                version="2.0">
  <!-- Contains named templates for InsLib file structure (aka "metadata" aka "supporting data") -->

   <!-- Called from htm-tpl-structure.xsl -->

   <xsl:template name="inslib-body-structure">
     <xsl:call-template name="navigation"/>

     <p>
       <xsl:if test="//t:support">
         <b><i18n:text i18n:key="epidoc-xslt-inslib-description">Description</i18n:text>: </b>
     <xsl:choose>
       <xsl:when test="//t:support/t:p/node()">
         <xsl:apply-templates select="//t:support/t:p" mode="inslib-dimensions"/>
       </xsl:when>
       <xsl:when test="//t:support//node()">
         <xsl:apply-templates select="//t:support" mode="inslib-dimensions"/>
       </xsl:when>
       <xsl:otherwise><i18n:text i18n:key="epidoc-xslt-inslib-unknown">Unknown</i18n:text></xsl:otherwise>
     </xsl:choose>
       </xsl:if>

       <xsl:if test="//t:layoutDesc">
         <br />
     <b><i18n:text i18n:key="epidoc-xslt-inslib-text">Text</i18n:text>: </b>
     <xsl:choose>
       <xsl:when test="//t:layoutDesc/t:layout//node()">
         <xsl:apply-templates select="//t:layoutDesc/t:layout" mode="inslib-dimensions"/>
       </xsl:when>
       <xsl:otherwise><i18n:text i18n:key="epidoc-xslt-inslib-unknown">Unknown</i18n:text>.</xsl:otherwise>
     </xsl:choose>
       </xsl:if>
       
       <xsl:if test="//t:handDesc">
     <br />
     <b><i18n:text i18n:key="epidoc-xslt-inslib-letters">Letters</i18n:text>: </b>
     <xsl:if test="//t:handDesc/t:handNote/node()">
       <xsl:apply-templates select="//t:handDesc/t:handNote"/>
     </xsl:if>
       </xsl:if>
     </p>

     <xsl:if test="//t:origDate">
       <p><b><i18n:text i18n:key="epidoc-xslt-inslib-date">Date</i18n:text>: </b>
     <xsl:choose>
       <xsl:when test="//t:origin/t:origDate/node()">
         <xsl:apply-templates select="//t:origin/t:origDate"/>
         <xsl:if test="//t:origin/t:origDate[@evidence]">
           <xsl:text> (</xsl:text>
           <xsl:for-each select="tokenize(//t:origin/t:origDate/@evidence,' ')">
             <xsl:value-of select="translate(translate(.,'-',' '),',','')"/>
             <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
           </xsl:for-each>
           <xsl:text>)</xsl:text>
         </xsl:if>
       </xsl:when>
       <xsl:otherwise><i18n:text i18n:key="epidoc-xslt-inslib-unknown">Unknown</i18n:text>.</xsl:otherwise>
     </xsl:choose>
     </p>
     </xsl:if>

     <p>
       <xsl:if test="//t:provenance">
       <b><i18n:text i18n:key="epidoc-xslt-inslib-findspot">Findspot</i18n:text>: </b>
     <xsl:choose>
       <xsl:when test="//t:provenance[@type='found'][string(translate(normalize-space(.),' ',''))]">
         <xsl:apply-templates select="//t:provenance[@type='found']" mode="inslib-placename"/>
       </xsl:when>
       <xsl:otherwise><i18n:text i18n:key="epidoc-xslt-inslib-unknown">Unknown</i18n:text></xsl:otherwise>
     </xsl:choose>
       </xsl:if>
       <xsl:if test="//t:origPlace">
     <br/>
     <b><i18n:text i18n:key="epidoc-xslt-inslib-original-location">Original location</i18n:text>: </b>
     <xsl:choose>
       <xsl:when test="//t:origin/t:origPlace/node()">
         <xsl:apply-templates select="//t:origin/t:origPlace" mode="inslib-placename"/>
       </xsl:when>
       <xsl:otherwise><i18n:text i18n:key="epidoc-xslt-inslib-unknown">Unknown</i18n:text></xsl:otherwise>
     </xsl:choose>
       </xsl:if>
       <xsl:if test="//t:provenance or //t:repository">
     <br/>
     <b><i18n:text i18n:key="epidoc-xslt-inslib-last-recorded-location">Last recorded location</i18n:text>: </b>
     <xsl:choose>
       <xsl:when test="//t:provenance[@type='observed'][string(translate(normalize-space(.),' ',''))]">
         <xsl:apply-templates select="//t:provenance[@type='observed']" mode="inslib-placename"/>
         <!-- Named template found below. -->
         <xsl:call-template name="inslib-invno"/>
       </xsl:when>
       <xsl:otherwise>
         <xsl:choose>
         <xsl:when test="//t:msIdentifier//t:repository[@ref][string(translate(normalize-space(.),' ',''))]">
         <xsl:value-of select="//t:msIdentifier//t:repository[@ref][1]"/>
         <!-- Named template found below. -->
         <xsl:call-template name="inslib-invno"/>
       </xsl:when>
           <xsl:otherwise><i18n:text i18n:key="epidoc-xslt-inslib-unknown">Unknown</i18n:text></xsl:otherwise>
         </xsl:choose>
       </xsl:otherwise>
     </xsl:choose>
       </xsl:if>
     </p>

     <xsl:if test="//t:div[@type='edition']">
       <div class="section-container tabs" data-section="tabs">
       <section>
         <p class="title" data-section-title="data-section-title"><a href="#"><i18n:text i18n:key="epidoc-xslt-inslib-edition">Interpretive</i18n:text></a></p>
         <div class="content" id="edition" data-section-content="data-section-content">
           <!-- Edited text output -->
           <xsl:variable name="edtxt">
             <xsl:apply-templates select="//t:div[@type='edition']">
               <xsl:with-param name="parm-edition-type" select="'interpretive'" tunnel="yes"/>
             </xsl:apply-templates>
           </xsl:variable>
           <!-- Moded templates found in htm-tpl-sqbrackets.xsl -->
           <xsl:apply-templates select="$edtxt" mode="sqbrackets"/>
         </div>
       </section>
       <section>
         <p class="title" data-section-title="data-section-title"><a href="#"><i18n:text i18n:key="epidoc-xslt-inslib-diplomatic">Diplomatic</i18n:text></a></p>
         <div class="content" id="diplomatic" data-section-content="data-section-content">
           <!-- Edited text output -->
           <xsl:variable name="edtxt">
             <xsl:apply-templates select="//t:div[@type='edition']">
               <xsl:with-param name="parm-edition-type" select="'diplomatic'" tunnel="yes"/>
             </xsl:apply-templates>
           </xsl:variable>
           <!-- Moded templates found in htm-tpl-sqbrackets.xsl -->
           <xsl:apply-templates select="$edtxt" mode="sqbrackets"/>
         </div>
       </section>
     </div>
     </xsl:if>

     <xsl:if test="//t:div[@type='apparatus']">
       <div id="apparatus">
       <!-- Apparatus text output -->
       <xsl:variable name="apptxt">
         <xsl:apply-templates select="//t:div[@type='apparatus']"/>
       </xsl:variable>
       <!-- Moded templates found in htm-tpl-sqbrackets.xsl -->
       <xsl:apply-templates select="$apptxt" mode="sqbrackets"/>
     </div>
     </xsl:if>

     <xsl:if test="//t:div[@type='translation']//t:p//node()">
       <div id="translation">
         <xsl:variable name="editor" select="//t:teiHeader/t:fileDesc/t:titleStmt/t:editor"/>
         <xsl:for-each select="//t:div[@type='translation'][@xml:lang]">
           <xsl:if test="@xml:lang"><h3><xsl:choose>
             <xsl:when test="@xml:lang='en'"><xsl:text>English </xsl:text></xsl:when>
             <xsl:when test="@xml:lang='fr'"><xsl:text>French </xsl:text></xsl:when>
             <xsl:when test="@xml:lang='it'"><xsl:text>Italian </xsl:text></xsl:when>
             <xsl:when test="@xml:lang='de'"><xsl:text>German </xsl:text></xsl:when>
             <xsl:when test="@xml:lang='la'"><xsl:text>Latin </xsl:text></xsl:when>
             <xsl:when test="@xml:lang='ar'"><xsl:text>Arabic </xsl:text></xsl:when>
             <xsl:otherwise><xsl:value-of select="@xml:lang"/> </xsl:otherwise>
           </xsl:choose>
             <i18n:text i18n:key="epidoc-xslt-inslib-translation">translation</i18n:text></h3></xsl:if>
           <xsl:if test="@source">
             <xsl:variable name="source-id" select="substring-after(@source, '#')"/>
             <p><xsl:text>Translation source: </xsl:text> 
               <xsl:choose>
                 <xsl:when test="doc-available(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/xml/authority/bibliography.xml')) = fn:true()">
                   <xsl:variable name="source" select="document(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/xml/authority/bibliography.xml'))//t:bibl[@xml:id=$source-id][not(@sameAs)]"/>
                   <xsl:if test="$source">
                     <a>
                       <xsl:attribute name="href">
                         <xsl:text>../concordance/bibliography/</xsl:text>
                         <xsl:value-of select="$source-id"/>
                         <xsl:text>.html</xsl:text>
                       </xsl:attribute>
                       <xsl:attribute name="target"><xsl:text>_blank</xsl:text></xsl:attribute>
                       <xsl:choose>
                         <xsl:when test="$source//t:bibl[@type='abbrev']">
                           <xsl:apply-templates select="$source//t:bibl[@type='abbrev'][1]"/>
                         </xsl:when>
                         <xsl:otherwise>
                           <xsl:apply-templates select="$source"/>
                         </xsl:otherwise>
                       </xsl:choose>
                     </a>
                   </xsl:if>
                 </xsl:when>
                 <xsl:otherwise>
                   <xsl:value-of select="$source-id"/>
                 </xsl:otherwise>
               </xsl:choose></p>
           </xsl:if>
           <xsl:if test="@resp">
             <xsl:variable name="resp-id" select="substring-after(@resp, '#')"/>
             <xsl:variable name="resp" select="$editor[@xml:id=$resp-id]"/>
             <p><xsl:text>Translation by: </xsl:text> <xsl:value-of select="$resp"/></p>
           </xsl:if>
           <!-- Translation text output -->
           <xsl:variable name="transtxt">
             <xsl:for-each select=".//t:p">
               <xsl:choose>
               <xsl:when test="ancestor::t:div[@xml:lang='ar']">
                 <p class="arabic"><xsl:apply-templates select="node()"/></p>
               </xsl:when>
               <xsl:otherwise>
                 <p><xsl:apply-templates select="node()"/></p>
               </xsl:otherwise>
               </xsl:choose>
             </xsl:for-each>
           </xsl:variable>
           <!-- Moded templates found in htm-tpl-sqbrackets.xsl -->
           <xsl:apply-templates select="$transtxt" mode="sqbrackets"/>
         </xsl:for-each>
     </div>
     </xsl:if>

     <xsl:if test="//t:div[@type='commentary']//t:p//node() and not(contains(//t:div[@type='commentary'][1]/t:p[1], 'No comment'))">
       <div id="commentary">
         <h3><i18n:text i18n:key="epidoc-xslt-inslib-commentary">Commentary</i18n:text></h3>
         <!-- Commentary text output -->
         <xsl:variable name="commtxt">
           <xsl:apply-templates select="//t:div[@type='commentary']//t:p"/>
         </xsl:variable>
             <!-- Moded templates found in htm-tpl-sqbrackets.xsl -->
             <xsl:apply-templates select="$commtxt" mode="sqbrackets"/>
       </div>
     </xsl:if>
     
     <!-- Old code for printing 'No comment' in texts without commentary:
       <xsl:if test="//t:div[@type='commentary']">
       <div id="commentary">
       <h3><i18n:text i18n:key="epidoc-xslt-inslib-commentary">Commentary</i18n:text></h3>
       <!-\- Commentary text output -\->
       <xsl:variable name="commtxt">
         <xsl:apply-templates select="//t:div[@type='commentary']//t:p"/>
       </xsl:variable>
       <xsl:choose>
         <xsl:when test="//t:div[@type='commentary']//t:p//node()">
           <!-\- Moded templates found in htm-tpl-sqbrackets.xsl -\->
           <xsl:apply-templates select="$commtxt" mode="sqbrackets"/>
         </xsl:when>
         <xsl:otherwise><p>No comment.</p></xsl:otherwise>
       </xsl:choose>
     </div>
     </xsl:if>-->

     <xsl:if test="//t:div[@type='bibliography']">
       <p><b><i18n:text i18n:key="epidoc-xslt-inslib-bibliography">Bibliography</i18n:text>: </b>
     <xsl:apply-templates select="//t:div[@type='bibliography']/t:p/node()"/>
     <!--<br/><b><i18n:text i18n:key="epidoc-xslt-inslib-constituted-from">Text constituted from</i18n:text>: </b>
     <xsl:apply-templates select="//t:creation"/>-->
     </p>
     </xsl:if>

     <xsl:if test="//t:facsimile">
     <div id="images">
       <h3>Images</h3>
       <xsl:choose>
         <xsl:when test="//t:facsimile//t:graphic">
           <xsl:for-each select="//t:facsimile//t:graphic">
             <span>&#160;</span>
             <xsl:choose>
               <xsl:when test="contains(@url,'http')">
                 <div id="external_image">
                   <a target="_blank"><xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute><iframe style="height:200px; border: 0;"><xsl:attribute name="src"><xsl:value-of select="@url"/></xsl:attribute></iframe></a>
                 </div>
               </xsl:when>
               <xsl:otherwise>
                 <!--<xsl:number value="position()" format="1" /><xsl:text>. </xsl:text>-->
                 <xsl:apply-templates select="." /><xsl:text> </xsl:text><span>&#160;</span>
                 <strong><xsl:text>Fig. </xsl:text><xsl:number value="position()" format="1" /></strong><xsl:if test="t:desc"><xsl:text>. </xsl:text><xsl:apply-templates select="t:desc" /></xsl:if>
                 <br/><br/>
               </xsl:otherwise>
             </xsl:choose>
           </xsl:for-each>
           
           <!--<p>
             <xsl:for-each select="//t:facsimile//t:graphic//t:desc">
               <br/><xsl:number value="position()" format="1" /><xsl:text>. </xsl:text><xsl:apply-templates select="." />
           </xsl:for-each>
           </p>-->
           
         </xsl:when>
         <xsl:otherwise>
           <xsl:for-each select="//t:facsimile[not(//t:graphic)]">
             <p>
               <xsl:choose>
                 <xsl:when test="starts-with(//t:publicationStmt/t:idno[@type='filename']/text(), 'IRT')">
                   <xsl:text>None available (2021).</xsl:text>
                 </xsl:when>
                 <xsl:otherwise>
                   <xsl:text>None available (2020).</xsl:text>
                 </xsl:otherwise>
               </xsl:choose>
               </p>
           </xsl:for-each>
         </xsl:otherwise>
       </xsl:choose>
     </div>
     </xsl:if>
   </xsl:template>

   <xsl:template name="inslib-structure">
      <xsl:variable name="title">
         <xsl:call-template name="inslib-title" />
      </xsl:variable>

      <html>
         <head>
            <title>
               <xsl:value-of select="$title"/>
            </title>
            <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
            <!-- Found in htm-tpl-cssandscripts.xsl -->
            <xsl:call-template name="css-script"/>
         </head>
         <body>
            <h1>
               <xsl:value-of select="$title"/>
            </h1>
            <xsl:call-template name="inslib-body-structure" />
         </body>
      </html>
   </xsl:template>

   <xsl:template match="t:dimensions" mode="inslib-dimensions">
      <xsl:if test="//text()">
         <xsl:if test="t:width/text()">w:
            <xsl:value-of select="t:width"/>
           <xsl:if test="t:height/text() | t:depth/text() | t:dim[@type='diameter']/text()">
               <xsl:text> x </xsl:text>
            </xsl:if>
         </xsl:if>
         <xsl:if test="t:height/text()">h:
            <xsl:value-of select="t:height"/>
           <xsl:if test="t:depth/text() | t:dim[@type='diameter']/text()">
             <xsl:text> x </xsl:text>
           </xsl:if>
         </xsl:if>
         <xsl:if test="t:depth/text()">d:
            <xsl:value-of select="t:depth"/>
           <xsl:if test="t:dim[@type='diameter']/text()">
             <xsl:text> x </xsl:text>
           </xsl:if>
         </xsl:if>
         <xsl:if test="t:dim[@type='diameter']/text()">diam.:
            <xsl:value-of select="t:dim[@type='diameter']"/>
         </xsl:if>
      </xsl:if>
   </xsl:template>

  <xsl:template match="t:placeName|t:rs|t:repository" mode="inslib-placename"> <!-- remove rs? -->
    <xsl:variable name="museum-ref" select="substring-after(@ref, '#')"/>
      <xsl:choose>
        <xsl:when test="contains(@ref,'pleiades.stoa.org') or contains(@ref,'geonames.org') or contains(@ref,'slsgazetteer.org') or contains(@ref,'ror.org') or contains(@ref,'wikidata.org')">
            <a>
               <xsl:attribute name="href">
                  <xsl:value-of select="@ref"/>
               </xsl:attribute>
              <xsl:attribute name="target">_blank</xsl:attribute>
               <xsl:apply-templates/>
            </a>
      </xsl:when>
        <xsl:when test="doc-available(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/xml/authority/institution.xml')) = fn:true() and starts-with(@ref,'institution.xml') and document(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/xml/authority/institution.xml'))//t:place[@xml:id=$museum-ref]//t:idno[1]">
          <a>
            <xsl:attribute name="href"><xsl:value-of select="document(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/xml/authority/institution.xml'))//t:place[@xml:id=$museum-ref]//t:idno[1]"/></xsl:attribute>
            <xsl:attribute name="target"><xsl:text>_blank</xsl:text></xsl:attribute>
            <xsl:apply-templates/>
          </a>
        </xsl:when>
         <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="inslib-invno">
      <xsl:if test="//t:idno[@type='invNo'][string(translate(normalize-space(.),' ',''))]">
         <xsl:text> (Inv. no. </xsl:text>
         <xsl:for-each select="//t:idno[@type='invNo'][string(translate(normalize-space(.),' ',''))]">
            <xsl:value-of select="."/>
            <xsl:if test="position()!=last()">
               <xsl:text>, </xsl:text>
            </xsl:if>
         </xsl:for-each>
         <xsl:text>)</xsl:text>
      </xsl:if>
   </xsl:template>

   <xsl:template name="inslib-title">
     <xsl:choose>
       <xsl:when test="//t:titleStmt/t:title and starts-with(//t:publicationStmt/t:idno[@type='filename']/text(), 'IRT')">
         <xsl:value-of select="substring(//t:publicationStmt/t:idno[@type='filename']/text(),4,7)"/>
         <xsl:text>. </xsl:text>
         <xsl:apply-templates select="//t:titleStmt/t:title"/>
       </xsl:when>
       <xsl:when test="//t:titleStmt/t:title and number(substring(//t:publicationStmt/t:idno[@type='filename']/text(),2,5))">
         <xsl:value-of select="//t:publicationStmt/t:idno[@type='filename']/text()"/>
         <xsl:text>. </xsl:text>
         <xsl:apply-templates select="//t:titleStmt/t:title"/>
       </xsl:when>
       <xsl:when test="//t:titleStmt/t:title">
         <xsl:apply-templates select="//t:titleStmt/t:title"/>
       </xsl:when>
       <xsl:when test="//t:sourceDesc//t:bibl/node()">
         <xsl:value-of select="//t:sourceDesc//t:bibl"/>
       </xsl:when>
       <xsl:when test="//t:idno[@type='filename']/text()">
         <xsl:value-of select="//t:idno[@type='filename']"/>
       </xsl:when>
       <xsl:otherwise>
         <xsl:text>EpiDoc example output, InsLib style</xsl:text>
       </xsl:otherwise>
     </xsl:choose>
   </xsl:template>

  <xsl:template match="t:ptr[@target]">
    <xsl:choose>
      <xsl:when test="doc-available(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/xml/authority/bibliography.xml')) = fn:true()">
        <xsl:variable name="bibl-ref" select="@target"/>
        <xsl:variable name="bibl" select="document(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/xml/authority/bibliography.xml'))//t:bibl[@xml:id=$bibl-ref][not(@sameAs)]"/>
        <a>
          <xsl:attribute name="href">
            <xsl:text>../concordance/bibliography/</xsl:text>
            <xsl:value-of select="$bibl-ref"/>
            <xsl:text>.html</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="target"><xsl:text>_blank</xsl:text></xsl:attribute>
          <xsl:choose>
            <xsl:when test="$bibl//t:bibl[@type='abbrev']">
              <xsl:apply-templates select="$bibl//t:bibl[@type='abbrev'][1]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="$bibl"/>
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@target"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="t:title[not(ancestor::t:titleStmt)]">
    <i><xsl:apply-templates/></i>
  </xsl:template>

  <!-- there should be an easier way to make the links work everywhere -->
  <xsl:template priority="1" match="t:ref[not(@type='inscription')][@target][not(ancestor::t:origPlace|ancestor::t:provenance|ancestor::t:support)]">
    <a><xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute><xsl:attribute name="target">_blank</xsl:attribute><xsl:apply-templates/></a>
  </xsl:template>
  
  <xsl:template priority="1" match="t:ref[not(@type='inscription')][@target][ancestor::t:origPlace|ancestor::t:provenance]" mode="inslib-placename">
    <a><xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute><xsl:attribute name="target">_blank</xsl:attribute><xsl:apply-templates/></a>
  </xsl:template>
  
  <xsl:template priority="1" match="t:ref[not(@type='inscription')][@target][ancestor::t:support]" mode="inslib-dimensions">
    <a><xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute><xsl:attribute name="target">_blank</xsl:attribute><xsl:apply-templates/></a>
  </xsl:template>
  
  
  <xsl:template priority="1" match="t:ref[@n][@type='inscription'][not(ancestor::t:origPlace|ancestor::t:provenance|ancestor::t:support)]">
    <a><xsl:attribute name="href"><xsl:value-of select="concat('./',@n,'.html')"/></xsl:attribute><xsl:attribute name="target"><xsl:value-of select="'_blank'"/></xsl:attribute><xsl:apply-templates/></a></xsl:template>
  
  <xsl:template priority="1" match="t:ref[@n][@type='inscription'][ancestor::t:origPlace|ancestor::t:provenance]" mode="inslib-placename">
    <a><xsl:attribute name="href"><xsl:value-of select="concat('./',@n,'.html')"/></xsl:attribute><xsl:attribute name="target"><xsl:value-of select="'_blank'"/></xsl:attribute><xsl:apply-templates/></a></xsl:template>
  
  <xsl:template priority="1" match="t:ref[@n][@type='inscription'][ancestor::t:support]" mode="inslib-dimensions">
    <a><xsl:attribute name="href"><xsl:value-of select="concat('./',@n,'.html')"/></xsl:attribute><xsl:attribute name="target"><xsl:value-of select="'_blank'"/></xsl:attribute><xsl:apply-templates/></a></xsl:template>
  
  
  <xsl:template name="navigation">
    <xsl:if test="doc-available(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/lists/all_inscriptions.xml')) = fn:true()">
    <xsl:variable name="filename"><xsl:value-of select="//t:idno[@type='filename']"/></xsl:variable>
    <xsl:variable name="list" select="document(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/lists/all_inscriptions.xml'))//t:list"/>
    <xsl:variable name="prev" select="$list/t:item[substring-before(@n,'.xml')=$filename]/preceding-sibling::t:item[1]/substring-before(@n,'.xml')"/>
    <xsl:variable name="next" select="$list/t:item[substring-before(@n,'.xml')=$filename]/following-sibling::t:item[1]/substring-before(@n,'.xml')"/>
    
    <div class="row">
      <div class="large-12 columns">
        <ul class="pagination right">
          <xsl:if test="$prev">
            <li class="arrow">
            <a>
              <xsl:attribute name="href">
                  <xsl:text>./</xsl:text>
                  <xsl:value-of select="$prev"/>
                  <xsl:text>.html</xsl:text>
              </xsl:attribute>
              <xsl:text>&#171;</xsl:text>
              <i18n:text>Previous: </i18n:text>
              <xsl:choose>
                <xsl:when test="starts-with($filename, 'IRT')"><xsl:value-of select="substring($prev,4)"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$prev"/></xsl:otherwise>
              </xsl:choose>
            </a>
          </li>
          </xsl:if>
          
          <xsl:if test="$next">
            <li class="arrow">
            <a>
              <xsl:attribute name="href">
                  <xsl:text>./</xsl:text>
                  <xsl:value-of select="$next"/>
                  <xsl:text>.html</xsl:text>
              </xsl:attribute>
              <i18n:text>Next: </i18n:text>
              <xsl:choose>
                <xsl:when test="starts-with($filename, 'IRT')"><xsl:value-of select="substring($next,4)"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$next"/></xsl:otherwise>
              </xsl:choose>
              <xsl:text>&#187;</xsl:text>
            </a>
          </li>
          </xsl:if>
        </ul>
      </div>
    </div>
    </xsl:if>
  </xsl:template>

  <!--  old code for inscription numbers now in <idno type="ircyr2012">:
    <xsl:template name="inslib-title">
     <xsl:choose>
       <xsl:when test="//t:titleStmt/t:title/text() and number(substring(//t:publicationStmt/t:idno[@type='filename']/text(),2,5))">
         <xsl:value-of select="substring(//t:publicationStmt/t:idno[@type='filename'],1,1)"/>
         <xsl:text>. </xsl:text>
         <xsl:value-of select="number(substring(//t:publicationStmt/t:idno[@type='filename'],2,5)) div 100"/>
         <xsl:text>. </xsl:text>
         <xsl:value-of select="//t:titleStmt/t:title"/>
       </xsl:when>
       <xsl:when test="//t:titleStmt/t:title/text()">
         <xsl:value-of select="//t:titleStmt/t:title"/>
       </xsl:when>
       <xsl:when test="//t:sourceDesc//t:bibl/text()">
         <xsl:value-of select="//t:sourceDesc//t:bibl"/>
       </xsl:when>
       <xsl:when test="//t:idno[@type='filename']/text()">
         <xsl:value-of select="//t:idno[@type='filename']"/>
       </xsl:when>
       <xsl:otherwise>
         <xsl:text>EpiDoc example output, InsLib style</xsl:text>
       </xsl:otherwise>
     </xsl:choose>
   </xsl:template> -->

 </xsl:stylesheet>
