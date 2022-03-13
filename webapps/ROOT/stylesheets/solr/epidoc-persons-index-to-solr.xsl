<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of persons in those
       documents. -->

  <xsl:import href="epidoc-index-utils.xsl" />

  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />
  
  <xsl:template match="/">
    <add>
      <!-- 'first-level' <persName>s -->
      <xsl:for-each select="//tei:persName[ancestor::tei:div[@type='edition']][@type='attested' and not(@sameAs)][descendant::tei:name[@nymRef]][not(ancestor::tei:persName[@type='attested'])]">
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <!-- name(s) -->
            <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][1]][not(ancestor::tei:persName[@type='attested'][2])]">
              <xsl:if test="@type='patronymic'"><xsl:text>- child of </xsl:text></xsl:if>
              <xsl:choose>
                <xsl:when test="@nymRef">
                  <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>-</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
            </xsl:for-each>
            <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][1]][not(ancestor::tei:persName[@type='attested'][2])])">
              <xsl:text>-</xsl:text>
            </xsl:if>
            
            <!-- disjoint patronymic(s); THIS SHOULD HANDLE NOT ONLY THE DISJOINT PATRONYMIC BUT ALSO SEPARATE PARTS OF THE ONOMASTICS, RE-JOINED WITH @sameAs -->
            <xsl:if test="@xml:id">
              <xsl:variable name="id" select="@xml:id"/>
              <xsl:text> child of </xsl:text>
              <xsl:for-each select="ancestor::tei:div//tei:persName[translate(@sameAs,'#','')=$id]//tei:name[@type='patronymic'][ancestor::tei:persName[@type='attested'][2]][not(ancestor::tei:persName[@type='attested'][3])]">
                <xsl:choose>
                  <xsl:when test="@nymRef">
                    <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>-</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
              </xsl:for-each>
              <xsl:if test="not(ancestor::tei:div//tei:persName[translate(@sameAs,'#','')=$id]//tei:name[@type='patronymic'][ancestor::tei:persName[@type='attested'][2]][not(ancestor::tei:persName[@type='attested'][3])])">
                <xsl:text>-</xsl:text>
              </xsl:if>
            </xsl:if>
            
            <!-- patronymic(s) et sim. -->
            <xsl:if test="descendant::tei:persName[@type='attested'][1]">
              <xsl:choose>
                <xsl:when test="descendant::tei:w[@lemma='ἀπελεύθερος' or @lemma='libertus']"><xsl:text> freedman of </xsl:text></xsl:when>
                <xsl:when test="descendant::tei:w[@lemma='uxor']"><xsl:text> spouse of </xsl:text></xsl:when>
                <xsl:when test="descendant::tei:w[@lemma='ἀπελευθέρα' or @lemma='liberta']"><xsl:text> freedwoman of </xsl:text></xsl:when>
                <xsl:otherwise><xsl:text> child of </xsl:text></xsl:otherwise>
              </xsl:choose>
              <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][2]][not(ancestor::tei:persName[@type='attested'][3])]">
                <xsl:choose>
                  <xsl:when test="@nymRef">
                    <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>-</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
              </xsl:for-each>
              <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][2]][not(ancestor::tei:persName[@type='attested'][3])])">
                <xsl:text>-</xsl:text>
              </xsl:if>
              
              <!-- papponymic(s) etc. -->
              <xsl:if test="descendant::tei:persName[@type='attested'][2]">
                <xsl:text> child of </xsl:text>
                <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][3]][not(ancestor::tei:persName[@type='attested'][4])]">
                  <xsl:choose>
                    <xsl:when test="@nymRef">
                      <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>-</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
                </xsl:for-each>
                <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][3]][not(ancestor::tei:persName[@type='attested'][4])])">
                  <xsl:text>-</xsl:text>
                </xsl:if>
                
                <xsl:if test="descendant::tei:persName[@type='attested'][3]">
                  <xsl:text> child of </xsl:text>
                  <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][4]][not(ancestor::tei:persName[@type='attested'][5])]">
                    <xsl:choose>
                      <xsl:when test="@nymRef">
                        <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text>-</xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
                  </xsl:for-each>
                  <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][4]][not(ancestor::tei:persName[@type='attested'][5])])">
                    <xsl:text>-</xsl:text>
                  </xsl:if>
                  
                  <xsl:if test="descendant::tei:persName[@type='attested'][4]">
                    <xsl:text> child of </xsl:text>
                    <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][5]][not(ancestor::tei:persName[@type='attested'][6])]">
                      <xsl:choose>
                        <xsl:when test="@nymRef">
                          <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:text>-</xsl:text>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
                    </xsl:for-each>
                    <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][5]][not(ancestor::tei:persName[@type='attested'][6])])">
                      <xsl:text>-</xsl:text>
                    </xsl:if>
                    
                    <xsl:if test="descendant::tei:persName[@type='attested'][5]">
                      <xsl:text> child of </xsl:text>
                      <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][6]][not(ancestor::tei:persName[@type='attested'][7])]">
                        <xsl:choose>
                          <xsl:when test="@nymRef">
                            <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text>-</xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
                      </xsl:for-each>
                      <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][6]][not(ancestor::tei:persName[@type='attested'][7])])">
                        <xsl:text>-</xsl:text>
                      </xsl:if>
                    </xsl:if>
                  </xsl:if>
                </xsl:if>
            </xsl:if>
            </xsl:if>
            <!-- not handling possible ethnics/provenance of patronymics -->
            <xsl:if test="descendant::tei:placeName[not(@type='ethnic')][@nymRef]">
              <xsl:text> from </xsl:text>
              <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[not(@type='ethnic')][1]/@nymRef, ' '), '#', ''))"/>
              <xsl:if test="descendant::tei:placeName[not(@type='ethnic')][2]">
              <xsl:text> and </xsl:text>
                <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[not(@type='ethnic')][2]/@nymRef, ' '), '#', ''))"/>
            </xsl:if>
            </xsl:if>
            <xsl:if test="descendant::tei:placeName[@type='ethnic'][@nymRef]">
              <xsl:text> </xsl:text>
              <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[@type='ethnic']/@nymRef, ' '), '#', ''))"/>
            </xsl:if>
          </field>
          <field name="index_external_resource">
            <xsl:choose>
              <xsl:when test="@ref">
                <xsl:value-of select="@ref" />
              </xsl:when>
              <xsl:when test="@key and not(@ref)">
                <xsl:value-of select="@key" />
              </xsl:when>
            </xsl:choose>
          </field>
          <xsl:apply-templates select="." />
        </doc>
      </xsl:for-each>
      
      
       <!--'second-level' <persName>s, i.e. fathers of  'first-level' <persName>s-->
      <xsl:for-each select="//tei:persName[ancestor::tei:div[@type='edition']][@type='attested'][descendant::tei:name][ancestor::tei:persName[@type='attested' and not(@sameAs)][1][descendant::tei:name[@nymRef]]][not(ancestor::tei:persName[@type='attested'][2])]">
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <!-- name(s) -->
            <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][2]][not(ancestor::tei:persName[@type='attested'][3])]">
              <xsl:choose>
                <xsl:when test="@nymRef">
                  <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>-</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
            </xsl:for-each>
            <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][2]][not(ancestor::tei:persName[@type='attested'][3])])">
              <xsl:text>-</xsl:text>
            </xsl:if>
            
            <!-- patronymic(s) et sim. -->
            <xsl:if test="descendant::tei:persName[@type='attested'][1]">
                <xsl:text> child of </xsl:text>
              <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][3]][not(ancestor::tei:persName[@type='attested'][4])]">
                <xsl:choose>
                  <xsl:when test="@nymRef">
                    <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>-</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
              </xsl:for-each>
              <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][3]][not(ancestor::tei:persName[@type='attested'][4])])">
                <xsl:text>-</xsl:text>
              </xsl:if>
              
              <xsl:if test="descendant::tei:persName[@type='attested'][2]">
                <xsl:text> child of </xsl:text>
                <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][4]][not(ancestor::tei:persName[@type='attested'][5])]">
                  <xsl:choose>
                    <xsl:when test="@nymRef">
                      <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>-</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
                </xsl:for-each>
                <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][4]][not(ancestor::tei:persName[@type='attested'][5])])">
                  <xsl:text>-</xsl:text>
                </xsl:if>
                
                <xsl:if test="descendant::tei:persName[@type='attested'][3]">
                  <xsl:text> child of </xsl:text>
                  <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][5]][not(ancestor::tei:persName[@type='attested'][6])]">
                    <xsl:choose>
                      <xsl:when test="@nymRef">
                        <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text>-</xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
                  </xsl:for-each>
                  <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][5]][not(ancestor::tei:persName[@type='attested'][6])])">
                    <xsl:text>-</xsl:text>
                  </xsl:if>
                  
                  <xsl:if test="descendant::tei:persName[@type='attested'][4]">
                    <xsl:text> child of </xsl:text>
                    <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][6]][not(ancestor::tei:persName[@type='attested'][7])]">
                      <xsl:choose>
                        <xsl:when test="@nymRef">
                          <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:text>-</xsl:text>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
                    </xsl:for-each>
                    <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][6]][not(ancestor::tei:persName[@type='attested'][7])])">
                      <xsl:text>-</xsl:text>
                    </xsl:if>
                  </xsl:if>
                </xsl:if>
              </xsl:if>
            </xsl:if>
            
            <!-- child’s name(s) et sim. -->
            <xsl:choose>
              <xsl:when test="preceding-sibling::tei:w[@lemma='ἀπελεύθερος' or @lemma='libertus' or @lemma='ἀπελευθέρα' or @lemma='liberta']|following-sibling::tei:w[@lemma='ἀπελεύθερος' or @lemma='libertus' or @lemma='ἀπελευθέρα' or @lemma='liberta']"><xsl:text> former master of </xsl:text></xsl:when>
              <xsl:when test="preceding-sibling::tei:w[@lemma='uxor']|following-sibling::tei:w[@lemma='uxor']"><xsl:text> spouse of </xsl:text></xsl:when>
              <xsl:otherwise><xsl:text> parent of </xsl:text></xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="preceding-sibling::tei:name|following-sibling::tei:name">
              <xsl:choose>
                <xsl:when test="@nymRef">
                  <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>-</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
            </xsl:for-each>
            <xsl:if test="not(preceding-sibling::tei:name|following-sibling::tei:name)">
              <xsl:text>-</xsl:text>
            </xsl:if>
             
            <!-- not handling possible ethnics/provenance of patronymics -->
            <xsl:if test="descendant::tei:placeName[not(@type='ethnic')][@nymRef]">
              <xsl:text> from </xsl:text>
              <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[not(@type='ethnic')][1]/@nymRef, ' '), '#', ''))"/>
              <xsl:if test="descendant::tei:placeName[not(@type='ethnic')][2]">
                <xsl:text> and </xsl:text>
                <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[not(@type='ethnic')][2]/@nymRef, ' '), '#', ''))"/>
              </xsl:if>
            </xsl:if>
            <xsl:if test="descendant::tei:placeName[@type='ethnic'][@nymRef]">
              <xsl:text> </xsl:text>
              <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[@type='ethnic']/@nymRef, ' '), '#', ''))"/>
            </xsl:if>
          </field>
          <field name="index_external_resource">
            <xsl:choose>
              <xsl:when test="@ref">
                <xsl:value-of select="@ref" />
              </xsl:when>
              <xsl:when test="@key and not(@ref)">
                <xsl:value-of select="@key" />
              </xsl:when>
            </xsl:choose>
          </field>
          <xsl:apply-templates select="." />
        </doc>
      </xsl:for-each>
      
      <!-- b: parent joined to child with a @sameAs -->
      <xsl:for-each select="//tei:persName[ancestor::tei:div[@type='edition']][@type='attested'][descendant::tei:name][ancestor::tei:persName[@type='attested' and @sameAs][descendant::tei:name[@nymRef]]][not(ancestor::tei:persName[@type='attested'][2])]">
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <!-- name(s) -->
            <xsl:for-each select=".//tei:name">
              <xsl:choose>
                <xsl:when test="@nymRef">
                  <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>-</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
            </xsl:for-each>
            <xsl:if test="not(//tei:name)">
              <xsl:text>-</xsl:text>
            </xsl:if>
            
            <!-- disjoint child’s name(s) -->
            <xsl:choose>
              <xsl:when test="preceding-sibling::tei:w[@lemma='ἀπελεύθερος' or @lemma='libertus' or @lemma='ἀπελευθέρα' or @lemma='liberta']|following-sibling::tei:w[@lemma='ἀπελεύθερος' or @lemma='libertus' or @lemma='ἀπελευθέρα' or @lemma='liberta']"><xsl:text> former master of </xsl:text></xsl:when>
              <xsl:when test="preceding-sibling::tei:w[@lemma='uxor']|following-sibling::tei:w[@lemma='uxor']"><xsl:text> spouse of </xsl:text></xsl:when>
              <xsl:otherwise><xsl:text> parent of </xsl:text></xsl:otherwise>
            </xsl:choose>
            <xsl:variable name="id" select="translate(string-join(ancestor::tei:persName[@type='attested' and @sameAs]/@sameAs, ''),'#','')"/>
            <xsl:for-each select="ancestor::tei:div//tei:persName[@xml:id=$id]//tei:name">
              <xsl:choose>
                <xsl:when test="@nymRef">
                  <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>-</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
            </xsl:for-each>
            <xsl:if test="not(ancestor::tei:div//tei:persName[@xml:id=$id]//tei:name)">
              <xsl:text>-</xsl:text>
            </xsl:if>
            
            <!-- not handling possible ethnics/provenance of patronymics -->
            <xsl:if test="descendant::tei:placeName[not(@type='ethnic')][@nymRef]">
              <xsl:text> from </xsl:text>
              <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[not(@type='ethnic')][1]/@nymRef, ' '), '#', ''))"/>
              <xsl:if test="descendant::tei:placeName[not(@type='ethnic')][2]">
                <xsl:text> and </xsl:text>
                <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[not(@type='ethnic')][2]/@nymRef, ' '), '#', ''))"/>
              </xsl:if>
            </xsl:if>
            <xsl:if test="descendant::tei:placeName[@type='ethnic'][@nymRef]">
              <xsl:text> </xsl:text>
              <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[@type='ethnic']/@nymRef, ' '), '#', ''))"/>
            </xsl:if>
          </field>
          <field name="index_external_resource">
            <xsl:choose>
              <xsl:when test="@ref">
                <xsl:value-of select="@ref" />
              </xsl:when>
              <xsl:when test="@key and not(@ref)">
                <xsl:value-of select="@key" />
              </xsl:when>
            </xsl:choose>
          </field>
          <xsl:apply-templates select="." />
        </doc>
      </xsl:for-each>
      
      
      <!--'third-level' <persName>s, i.e. grandfathers of  'first-level' <persName>s-->
      <xsl:for-each select="//tei:persName[ancestor::tei:div[@type='edition']][@type='attested'][descendant::tei:name][ancestor::tei:persName[@type='attested'][2][descendant::tei:name[@nymRef]]][not(ancestor::tei:persName[@type='attested'][3])]">
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <!-- name(s) -->
            <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][3]][not(ancestor::tei:persName[@type='attested'][4])]">
              <xsl:choose>
                <xsl:when test="@nymRef">
                  <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>-</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
            </xsl:for-each>
            <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][3]][not(ancestor::tei:persName[@type='attested'][4])])">
              <xsl:text>-</xsl:text>
            </xsl:if>
            
            <!-- parents’s name(s) -->
            <xsl:if test="descendant::tei:persName[@type='attested'][1]">
                <xsl:text> child of </xsl:text>
              <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][4]][not(ancestor::tei:persName[@type='attested'][5])]">
                <xsl:choose>
                  <xsl:when test="@nymRef">
                    <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>-</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
              </xsl:for-each>
              <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][4]][not(ancestor::tei:persName[@type='attested'][5])])">
                <xsl:text>-</xsl:text>
              </xsl:if>
               
              <xsl:if test="descendant::tei:persName[@type='attested'][2]">
                <xsl:text> child of </xsl:text>
                <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][5]][not(ancestor::tei:persName[@type='attested'][6])]">
                  <xsl:choose>
                    <xsl:when test="@nymRef">
                      <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>-</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
                </xsl:for-each>
                <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][5]][not(ancestor::tei:persName[@type='attested'][6])])">
                  <xsl:text>-</xsl:text>
                </xsl:if>
                
                <xsl:if test="descendant::tei:persName[@type='attested'][3]">
                  <xsl:text> child of </xsl:text>
                  <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][6]][not(ancestor::tei:persName[@type='attested'][7])]">
                    <xsl:choose>
                      <xsl:when test="@nymRef">
                        <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text>-</xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
                  </xsl:for-each>
                  <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][6]][not(ancestor::tei:persName[@type='attested'][7])])">
                    <xsl:text>-</xsl:text>
                  </xsl:if>
                </xsl:if>
              </xsl:if>
            </xsl:if>
            
            <!-- child’s name(s) -->
            <xsl:text> parent of </xsl:text>
            <xsl:for-each select="preceding-sibling::tei:name|following-sibling::tei:name">
              <xsl:choose>
                <xsl:when test="@nymRef">
                  <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>-</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
            </xsl:for-each>
            <xsl:if test="not(preceding-sibling::tei:name|following-sibling::tei:name)">
              <xsl:text>-</xsl:text>
            </xsl:if>
            
            <!-- grandchild’s name(s) -->
            <xsl:text> parent of </xsl:text>
            <xsl:for-each select="ancestor::tei:persName[@type='attested'][not(ancestor::tei:persName[@type='attested'])]//tei:name[ancestor::tei:persName[@type='attested'][1]][not(ancestor::tei:persName[@type='attested'][2])]">
              <xsl:choose>
                <xsl:when test="@nymRef">
                  <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>-</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
            </xsl:for-each>
            <xsl:if test="not(ancestor::tei:persName[@type='attested'][not(ancestor::tei:persName[@type='attested'])]//tei:name[ancestor::tei:persName[@type='attested'][1]][not(ancestor::tei:persName[@type='attested'][2])])">
              <xsl:text>-</xsl:text>
            </xsl:if>
            
            <!-- not handling possible ethnics/provenance of patronymics -->
            <xsl:if test="descendant::tei:placeName[not(@type='ethnic')][@nymRef]">
              <xsl:text> from </xsl:text>
              <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[not(@type='ethnic')][1]/@nymRef, ' '), '#', ''))"/>
              <xsl:if test="descendant::tei:placeName[not(@type='ethnic')][2]">
                <xsl:text> and </xsl:text>
                <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[not(@type='ethnic')][2]/@nymRef, ' '), '#', ''))"/>
              </xsl:if>
            </xsl:if>
            <xsl:if test="descendant::tei:placeName[@type='ethnic'][@nymRef]">
              <xsl:text> </xsl:text>
              <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[@type='ethnic']/@nymRef, ' '), '#', ''))"/>
            </xsl:if>
          </field>
          <field name="index_external_resource">
            <xsl:choose>
              <xsl:when test="@ref">
                <xsl:value-of select="@ref" />
              </xsl:when>
              <xsl:when test="@key and not(@ref)">
                <xsl:value-of select="@key" />
              </xsl:when>
            </xsl:choose>
          </field>
          <xsl:apply-templates select="." />
        </doc>
      </xsl:for-each> 
     
      <!--'fourth-level' <persName>s-->
      <xsl:for-each select="//tei:persName[ancestor::tei:div[@type='edition']][@type='attested'][descendant::tei:name][ancestor::tei:persName[@type='attested'][3][descendant::tei:name[@nymRef]]][not(ancestor::tei:persName[@type='attested'][4])]">
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][4]][not(ancestor::tei:persName[@type='attested'][5])]">
              <xsl:choose>
                <xsl:when test="@nymRef">
                  <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>-</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
            </xsl:for-each>
            <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][4]][not(ancestor::tei:persName[@type='attested'][5])])">
              <xsl:text>-</xsl:text>
            </xsl:if>
            
             <xsl:if test="descendant::tei:persName[@type='attested'][1]">
                <xsl:text> child of </xsl:text>
               <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][5]][not(ancestor::tei:persName[@type='attested'][6])]">
                 <xsl:choose>
                   <xsl:when test="@nymRef">
                     <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                   </xsl:when>
                   <xsl:otherwise>
                     <xsl:text>-</xsl:text>
                   </xsl:otherwise>
                 </xsl:choose>
                 <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
               </xsl:for-each>
               <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][5]][not(ancestor::tei:persName[@type='attested'][6])])">
                 <xsl:text>-</xsl:text>
               </xsl:if>
               
              <xsl:if test="descendant::tei:persName[@type='attested'][2]">
                <xsl:text> child of </xsl:text>
                <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][6]][not(ancestor::tei:persName[@type='attested'][7])]">
                  <xsl:choose>
                    <xsl:when test="@nymRef">
                      <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>-</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
                </xsl:for-each>
                <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][6]][not(ancestor::tei:persName[@type='attested'][7])])">
                  <xsl:text>-</xsl:text>
                </xsl:if>
              </xsl:if>
            </xsl:if>
            
            <xsl:text> parent of </xsl:text>
            <xsl:for-each select="preceding-sibling::tei:name|following-sibling::tei:name">
              <xsl:choose>
                <xsl:when test="@nymRef">
                  <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>-</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
            </xsl:for-each>
            <xsl:if test="not(preceding-sibling::tei:name|following-sibling::tei:name)">
              <xsl:text>-</xsl:text>
            </xsl:if>
            <!-- not handling possible ethnics/provenance of patronymics -->
            <xsl:if test="descendant::tei:placeName[not(@type='ethnic')][@nymRef]">
              <xsl:text> from </xsl:text>
              <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[not(@type='ethnic')][1]/@nymRef, ' '), '#', ''))"/>
              <xsl:if test="descendant::tei:placeName[not(@type='ethnic')][2]">
                <xsl:text> and </xsl:text>
                <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[not(@type='ethnic')][2]/@nymRef, ' '), '#', ''))"/>
              </xsl:if>
            </xsl:if>
            <xsl:if test="descendant::tei:placeName[@type='ethnic'][@nymRef]">
              <xsl:text> </xsl:text>
              <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[@type='ethnic']/@nymRef, ' '), '#', ''))"/>
            </xsl:if>
          </field>
          <field name="index_external_resource">
            <xsl:choose>
              <xsl:when test="@ref">
                <xsl:value-of select="@ref" />
              </xsl:when>
              <xsl:when test="@key and not(@ref)">
                <xsl:value-of select="@key" />
              </xsl:when>
            </xsl:choose>
          </field>
          <xsl:apply-templates select="." />
        </doc>
      </xsl:for-each>
      
      
      <!--'fifth-level' <persName>s-->
      <xsl:for-each select="//tei:persName[@type='attested'][ancestor::tei:div[@type='edition']][descendant::tei:name][ancestor::tei:persName[@type='attested'][4][descendant::tei:name[@nymRef]]][not(ancestor::tei:persName[@type='attested'][5])]">
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][5]][not(ancestor::tei:persName[@type='attested'][6])]">
              <xsl:choose>
                <xsl:when test="@nymRef">
                  <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>-</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
            </xsl:for-each>
            <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][5]][not(ancestor::tei:persName[@type='attested'][6])])">
              <xsl:text>-</xsl:text>
            </xsl:if>
            
             <xsl:if test="descendant::tei:persName[@type='attested'][1]">
                <xsl:text> child of </xsl:text>
               <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][6]][not(ancestor::tei:persName[@type='attested'][7])]">
                 <xsl:choose>
                   <xsl:when test="@nymRef">
                     <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                   </xsl:when>
                   <xsl:otherwise>
                     <xsl:text>-</xsl:text>
                   </xsl:otherwise>
                 </xsl:choose>
                 <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
               </xsl:for-each>
               <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][6]][not(ancestor::tei:persName[@type='attested'][7])])">
                 <xsl:text>-</xsl:text>
               </xsl:if>
            </xsl:if>
            
            <xsl:text> parent of </xsl:text>
            <xsl:for-each select="preceding-sibling::tei:name|following-sibling::tei:name">
              <xsl:choose>
                <xsl:when test="@nymRef">
                  <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>-</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
            </xsl:for-each>
            <xsl:if test="not(preceding-sibling::tei:name|following-sibling::tei:name)">
              <xsl:text>-</xsl:text>
            </xsl:if>
            <!-- not handling possible ethnics/provenance of patronymics -->
            <xsl:if test="descendant::tei:placeName[not(@type='ethnic')][@nymRef]">
              <xsl:text> from </xsl:text>
              <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[not(@type='ethnic')][1]/@nymRef, ' '), '#', ''))"/>
              <xsl:if test="descendant::tei:placeName[not(@type='ethnic')][2]">
                <xsl:text> and </xsl:text>
                <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[not(@type='ethnic')][2]/@nymRef, ' '), '#', ''))"/>
              </xsl:if>
            </xsl:if>
            <xsl:if test="descendant::tei:placeName[@type='ethnic'][@nymRef]">
              <xsl:text> </xsl:text>
              <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[@type='ethnic']/@nymRef, ' '), '#', ''))"/>
            </xsl:if>
          </field>
          <field name="index_external_resource">
            <xsl:choose>
              <xsl:when test="@ref">
                <xsl:value-of select="@ref" />
              </xsl:when>
              <xsl:when test="@key and not(@ref)">
                <xsl:value-of select="@key" />
              </xsl:when>
            </xsl:choose>
          </field>
          <xsl:apply-templates select="." />
        </doc>
      </xsl:for-each>
      
      
      <!--'sixth-level' <persName>s-->
      <xsl:for-each select="//tei:persName[@type='attested'][ancestor::tei:div[@type='edition']][descendant::tei:name][ancestor::tei:persName[@type='attested'][5][descendant::tei:name[@nymRef]]][not(ancestor::tei:persName[@type='attested'][6])]">
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <xsl:for-each select=".//tei:name[ancestor::tei:persName[@type='attested'][6]][not(ancestor::tei:persName[@type='attested'][7])]">
              <xsl:choose>
                <xsl:when test="@nymRef">
                  <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>-</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
            </xsl:for-each>
            <xsl:if test="not(//tei:name[ancestor::tei:persName[@type='attested'][6]][not(ancestor::tei:persName[@type='attested'][7])])">
              <xsl:text>-</xsl:text>
            </xsl:if>
            
            <xsl:text> parent of </xsl:text>
            <xsl:for-each select="preceding-sibling::tei:name|following-sibling::tei:name">
              <xsl:choose>
                <xsl:when test="@nymRef">
                  <xsl:value-of select="translate(translate(normalize-unicode(@nymRef), '#', ''), '_', '-')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>-</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
            </xsl:for-each>
            <xsl:if test="not(preceding-sibling::tei:name|following-sibling::tei:name)">
              <xsl:text>-</xsl:text>
            </xsl:if>
            <!-- not handling possible ethnics/provenance of patronymics -->
            <xsl:if test="descendant::tei:placeName[not(@type='ethnic')][@nymRef]">
              <xsl:text> from </xsl:text>
              <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[not(@type='ethnic')][1]/@nymRef, ' '), '#', ''))"/>
              <xsl:if test="descendant::tei:placeName[not(@type='ethnic')][2]">
                <xsl:text> and </xsl:text>
                <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[not(@type='ethnic')][2]/@nymRef, ' '), '#', ''))"/>
              </xsl:if>
            </xsl:if>
            <xsl:if test="descendant::tei:placeName[@type='ethnic'][@nymRef]">
              <xsl:text> </xsl:text>
              <xsl:value-of select="normalize-unicode(translate(string-join(tei:placeName[@type='ethnic']/@nymRef, ' '), '#', ''))"/>
            </xsl:if>
          </field>
          <field name="index_external_resource">
            <xsl:choose>
              <xsl:when test="@ref">
                <xsl:value-of select="@ref" />
              </xsl:when>
              <xsl:when test="@key and not(@ref)">
                <xsl:value-of select="@key" />
              </xsl:when>
            </xsl:choose>
          </field>
          <xsl:apply-templates select="." />
        </doc>
      </xsl:for-each>
      
    </add>
  </xsl:template>

  <xsl:template match="tei:persName">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>
