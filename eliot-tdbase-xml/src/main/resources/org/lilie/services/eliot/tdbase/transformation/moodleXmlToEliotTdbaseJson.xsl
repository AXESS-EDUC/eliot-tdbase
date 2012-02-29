<!--
  ~ Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
  ~ This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
  ~
  ~  Lilie is free software. You can redistribute it and/or modify since
  ~  you respect the terms of either (at least one of the both license) :
  ~  - under the terms of the GNU Affero General Public License as
  ~  published by the Free Software Foundation, either version 3 of the
  ~  License, or (at your option) any later version.
  ~  - the CeCILL-C as published by CeCILL-C; either version 1 of the
  ~  License, or any later version
  ~
  ~  There are special exceptions to the terms and conditions of the
  ~  licenses as they are applied to this software. View the full text of
  ~  the exception in file LICENSE.txt in the directory of this software
  ~  distribution.
  ~
  ~  Lilie is distributed in the hope that it will be useful,
  ~  but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~  Licenses for more details.
  ~
  ~  You should have received a copy of the GNU General Public License
  ~  and the CeCILL-C along with Lilie. If not, see :
  ~  <http://www.gnu.org/licenses/> and
  ~  <http://www.cecill.info/licences.fr.html>.
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:json="http://json.org/">

    <xsl:output encoding="UTF-8" omit-xml-declaration="yes" method="text"/>

    <!--
     Traitement du noeud racine
    -->
    <xsl:template match="quiz">
      {
        "quiz" : [
          {
            "nombreItems" : "<xsl:value-of
            select="count(question[@type != 'category'])"/>"
          }
          <xsl:for-each select="question[@type != 'category']">
          ,
          {
            "titre" : "<xsl:value-of
                select="json:encode-string(name/text/text())"/>",
            "attachement" : {<xsl:apply-templates select="image"/>},
            "specification" : {<xsl:apply-templates select="."/>
            }
          }
        </xsl:for-each>
        ]
      }
    </xsl:template>


    <!--
      Traitement d'une question  de type "calculated", "Cloze"
      Renvoie vers le template de question non supportée
    -->
    <xsl:template match="question[@type = 'calculated' or @type = 'cloze']">
        <xsl:call-template name="type_question_non_supporte"/>
    </xsl:template>

    <xsl:template match="image">
        <xsl:if test="not(empty(text()))">
            <xsl:variable name="nom" select="tokenize(text(),'/')[last()]"/>
              "nom" : "<xsl:value-of select="json:encode-string($nom)"/>"<xsl:if test="not(empty(image_base64/text()))">,
              "contenu_base64" : "<xsl:value-of select="json:encode-string(normalize-space(image_base64/text()))"/>"
            </xsl:if><xsl:if test="not(empty(following-sibling::image_base64[position()=1]/text()))">,
              "contenu_base64_not_nested" : "<xsl:value-of select="json:encode-string(normalize-space(following::image_base64[position()=1]/text()))"/>"
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!--
        Les questions de type description sont associées à un item de type
        Statement.
    -->
    <xsl:template match="question[@type = 'description']">
        <xsl:call-template name="Statement"/>
    </xsl:template>

    <!--
          Les questions de type essay sont associées à un item de type
          Open.
     -->
    <xsl:template match="question[@type = 'essay']">
        <xsl:call-template name="Open"/>
    </xsl:template>

    <!--
         Les questions de type matching sont associées à un item de type
         Associate.
    -->
    <xsl:template match="question[@type = 'matching']">
        <xsl:call-template name="Associate"/>
    </xsl:template>

    <!--
         Les questions de type multichoice sont associées à un item de type
         MultipleChoice ou ExclusiveChoice.
    -->
    <xsl:template match="question[@type = 'multichoice']">
        <xsl:choose>
        <xsl:when test="single/text() = 'false'">
        <xsl:call-template name="MultipleChoice"/>
        </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!--
      Traitement d'une question  dont le type est à ignorer ne fait rien
    -->
    <xsl:template match="question">
    </xsl:template>


    <!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        Template nommés pour le rendu des types de question eliot-tdbase
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->

    <xsl:template name="type_question_non_supporte">
              "questionTypeCode": "<xsl:value-of select="@type"/>"
    </xsl:template>

    <!--
        Template pour la generation d'une Statement question
        -->
    <xsl:template name="Statement">
              "questionTypeCode": "Statement",
              "enonce" : "<xsl:value-of select="json:encode-string(questiontext/text/text())"/>"
    </xsl:template>

    <!--
        Template pour la generation d'une Statement question
     -->
    <xsl:template name="Open">
              "questionTypeCode": "Open",
              "libelle" : "<xsl:value-of select="json:encode-string(questiontext/text/text())"/>",
              "nombreLignesReponses" : 5
    </xsl:template>

    <!--
        Template pour la génération d'une Associate question
     -->
    <xsl:template name="Associate">
              "questionTypeCode" : "Associate",
              "libelle" : "<xsl:value-of select="json:encode-string(questiontext/text/text())"/>",
              "montrerColonneAGauche" : true,
              "associations" : [<xsl:for-each select="subquestion">
                 {
                   "participant1": "<xsl:value-of select="json:encode-string(text/text())"/>",
                   "participant2": "<xsl:value-of select="json:encode-string(answer/text/text())"/>"
                 }<xsl:if test="position() != last()">,</xsl:if></xsl:for-each>
              ]
    </xsl:template>

    <!--
       Template pour la génération d'une MultipleChoice question
    -->
    <xsl:template name="MultipleChoice">
              "questionTypeCode" : "MultipleChoice",
               "libelle" : "<xsl:value-of select="json:encode-string(questiontext/text/text())"/>",
               "shuffled" : <xsl:choose><xsl:when test="shuffleanswers/text() = 1">true</xsl:when><xsl:otherwise>false</xsl:otherwise></xsl:choose>,
               "reponses" : [<xsl:for-each select="answer">
                  {
                     "libelleReponse" : "<xsl:value-of select="json:encode-string(text/text())"/>",
                     "estUneBonneReponse" : <xsl:choose><xsl:when test="@fraction &lt;= 0">false</xsl:when><xsl:otherwise>true</xsl:otherwise></xsl:choose>
                  }<xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>
               ]
    </xsl:template>


    <!--&lt;!&ndash;-->
    <!--Template pour la generation d'une FillGap question-->
    <!--@param response un element de type qti:responseDeclaration/qti:correctResponse-->
    <!--&ndash;&gt;-->
    <!--<xsl:template name="FillGap">-->
    <!--<xsl:param name="response"/>-->
    <!--<xsl:param name="saisieLibre"/>-->
    <!--<xsl:param name="montrerLesMots"/>-->
    <!--<xsl:variable name="textAtrous">-->
    <!--&lt;p&gt;-->
    <!--<xsl:call-template name="constitueTexteATrous">-->
    <!--<xsl:with-param name="responseElt" select="$response"/>-->
    <!--<xsl:with-param name="gapMatchInteractionElt" select="."/>-->
    <!--</xsl:call-template>-->
    <!--&lt;/p&gt;-->
    <!--</xsl:variable>-->
    <!--,{-->
    <!--"questionTypeCode" : "FillGap",-->
    <!--"libelle" : "<xsl:value-of select="normalize-space(qti:prompt)"/>",-->
    <!--"saisieLibre" : <xsl:value-of select="$saisieLibre"/>,-->
    <!--"montrerLesMots" : <xsl:value-of select="$montrerLesMots"/>,-->
    <!--"texteATrous" : "<xsl:value-of select="normalize-space($textAtrous)"/>"-->
    <!--}-->
    <!--</xsl:template>-->


    <!--&lt;!&ndash;-->
    <!--Template pour la generation d'une MultipleChoice question-->
    <!--@param response un élément de type qti:responseDeclaration/qti:correctResponse-->
    <!--@param montrerColonneAGauche true si il faut montrer la colonne à gauche-->
    <!--&ndash;&gt;-->
    <!--<xsl:template name="Assiociate">-->
    <!--<xsl:param name="response"/>-->
    <!--<xsl:param name="montrerColonneAGauche"/>-->
    <!--,{-->
    <!--"questionTypeCode" : "Associate",-->
    <!--"libelle" : "<xsl:value-of select="normalize-space(qti:prompt)"/>",-->
    <!--"montrerColonneAGauche" : <xsl:value-of-->
    <!--select="$montrerColonneAGauche"/>,-->
    <!--"associations" : [-->
    <!--<xsl:call-template name="constituePaires">-->
    <!--<xsl:with-param name="associateInteractionElt" select="."/>-->
    <!--<xsl:with-param name="correctResponseElt" select="$response"/>-->
    <!--</xsl:call-template>-->
    <!--]-->
    <!--}-->
    <!--</xsl:template>-->

    <!--&lt;!&ndash;-->
    <!--Template pour la generation d'une MultipleChoice question-->
    <!--@param response un element de type qti:responseDeclaration/qti:correctResponse-->
    <!--&ndash;&gt;-->
    <!--<xsl:template name="MultipleChoice">-->
    <!--<xsl:param name="response"/>-->
    <!--,{-->
    <!--"questionTypeCode" : "MultipleChoice",-->
    <!--"libelle" : "<xsl:value-of select="normalize-space(qti:prompt)"/>",-->
    <!--"shuffled" : <xsl:value-of select="@shuffle"/>,-->
    <!--"reponses" : [-->
    <!--<xsl:for-each select="qti:simpleChoice">-->
    <!--{-->
    <!--"libelleReponse" : "<xsl:value-of select="text()"/>",-->
    <!--"estUneBonneReponse" :-->
    <!--<xsl:call-template-->
    <!--name="afficheTrueSiReponseCorrecte">-->
    <!--<xsl:with-param name="correctResponseElt"-->
    <!--select="$response/qti:correctResponse"/>-->
    <!--<xsl:with-param name="idReponseAEvaluer" select="@identifier"/>-->
    <!--</xsl:call-template>-->
    <!--}<xsl:if test="position()!=last()">,</xsl:if>-->
    <!--</xsl:for-each>-->
    <!--]-->
    <!--}-->
    <!--</xsl:template>-->


    <!--&lt;!&ndash;-->
    <!--Template pour la generation d'une MultipleChoice question-->
    <!--@param response  un element de type qti:correctResponse-->
    <!--&ndash;&gt;-->
    <!--<xsl:template name="ExclusiveChoice">-->
    <!--<xsl:param name="response"/>-->
    <!--,{-->
    <!--"questionTypeCode" : "ExclusiveChoice",-->
    <!--"libelle" : "<xsl:value-of select="normalize-space(qti:prompt)"/>",-->
    <!--"shuffled" : <xsl:value-of select="@shuffle"/>,-->
    <!--"indexBonneReponse": "<xsl:value-of-->
    <!--select="$response/qti:correctResponse/qti:value"/>",-->
    <!--"reponses" : [-->
    <!--<xsl:for-each select="qti:simpleChoice">-->
    <!--{-->
    <!--"libelleReponse" : "<xsl:value-of select="text()"/>",-->
    <!--"id" : "<xsl:value-of select="@identifier"/>"-->
    <!--}<xsl:if test="position()!=last()">,</xsl:if>-->
    <!--</xsl:for-each>-->
    <!--]-->
    <!--}-->
    <!--</xsl:template>-->

    <!--&lt;!&ndash;-->
    <!--Affiche true si une reponse est correcte-->
    <!--@param correctResponseElt un element de type qti:correctResponse-->
    <!--@param idReponseAEvaluer valeur d'un simpleChoice/@identifier-->
    <!--&ndash;&gt;-->
    <!--<xsl:template name="afficheTrueSiReponseCorrecte">-->
    <!--<xsl:param name="correctResponseElt"/>-->
    <!--<xsl:param name="idReponseAEvaluer"/>-->
    <!--<xsl:variable name="reponseCorrecte"-->
    <!--select="$correctResponseElt/qti:value[text()=$idReponseAEvaluer]"/>-->
    <!--<xsl:if test="$reponseCorrecte">true</xsl:if>-->
    <!--<xsl:if test="not($reponseCorrecte)">false</xsl:if>-->
    <!--</xsl:template>-->

    <!--&lt;!&ndash;-->
    <!--Constitue les paires pour une question de type Associate-->
    <!--@param correctResponseElt un element de type qti:correctResponse-->
    <!--@param associateInteractionElt un element de type qti:associateInteraction-->
    <!--&ndash;&gt;-->
    <!--<xsl:template name="constituePaires">-->
    <!--<xsl:param name="correctResponseElt"/>-->
    <!--<xsl:param name="associateInteractionElt"/>-->
    <!--<xsl:for-each-->
    <!--select="$correctResponseElt/qti:correctResponse/qti:value">-->
    <!--<xsl:variable name="tabPartIds" select="tokenize(text(),'\s+')"/>-->
    <!--{-->
    <!--"participant1": "<xsl:value-of-->
    <!--select="$associateInteractionElt//qti:simpleAssociableChoice[@identifier=$tabPartIds[1]]"/>",-->
    <!--"participant2": "<xsl:value-of-->
    <!--select="$associateInteractionElt//qti:simpleAssociableChoice[@identifier=$tabPartIds[2]]"/>"-->
    <!--}<xsl:if test="position()!=last()">,</xsl:if>-->
    <!--</xsl:for-each>-->
    <!--</xsl:template>-->





    <!-- Credit:  Bram Stein http://www.bramstein.com/projects/xsltjson/ -->
    <xsl:function name="json:encode-string" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence select="normalize-space(replace(
        					replace(
        					replace(
        					replace(
        					replace(
        					replace(
        					replace(
        					replace(
        					replace($string,
        						'\\','\\\\'),
        						'/', '\\/'),
        						'&quot;', '\\&quot;'),
        						'&#xA;','\\n'),
        						'&#xD;','\\r'),
        						'&#x9;','\\t'),
        						'\n','\\n'),
        						'\r','\\r'),
        						'\t','\\t'))"/>
    </xsl:function>

</xsl:stylesheet>