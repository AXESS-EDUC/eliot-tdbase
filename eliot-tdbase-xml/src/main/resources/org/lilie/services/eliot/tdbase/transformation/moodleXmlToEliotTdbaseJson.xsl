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
        <xsl:call-template name="type_question_non_supporte">
            <xsl:with-param name="question" select="."/>
        </xsl:call-template>
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
        Les questions de type description un item de type Statement.
    -->
    <xsl:template match="question[@type = 'description']">
        <xsl:call-template name="Statement">
            <xsl:with-param name="question" select="."/>
        </xsl:call-template>
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
        <xsl:param name="question"/>
              "questionTypeCode": "<xsl:value-of select="@type"/>"
    </xsl:template>

    <!--
        Template pour la generation d'une Statement question
        -->
    <xsl:template name="Statement">
        <xsl:param name="question"/>
              "questionTypeCode": "Statement",
              "enonce" : "<xsl:value-of select="json:encode-string($question/questiontext/text/text())"/>"
    </xsl:template>


    <!--&lt;!&ndash;-->
    <!--Les éléments 'img' sont plaçés dans des items de type document-->
    <!--&ndash;&gt;-->
    <!--<xsl:template match="qti:img">-->
    <!--<xsl:call-template name="Document"/>-->
    <!--</xsl:template>-->

    <!--&lt;!&ndash;-->
    <!--Les items QTI de type choiceInteraction sont placés dans des éléments de-->
    <!--type MultipleChoice ou ExclusiveChoice-->
    <!--&ndash;&gt;-->
    <!--<xsl:template match="qti:choiceInteraction">-->
    <!--<xsl:variable name="idResponse" select="@responseIdentifier"/>-->
    <!--<xsl:variable name="response"-->
    <!--select="//qti:responseDeclaration[@identifier=$idResponse]"/>-->
    <!--<xsl:if test="$response/@cardinality = 'multiple'">-->
    <!--<xsl:call-template name="MultipleChoice">-->
    <!--<xsl:with-param name="response" select="$response"/>-->
    <!--</xsl:call-template>-->
    <!--</xsl:if>-->
    <!--<xsl:if test="$response/@cardinality = 'single'">-->
    <!--<xsl:call-template name="ExclusiveChoice">-->
    <!--<xsl:with-param name="response" select="$response"/>-->
    <!--</xsl:call-template>-->
    <!--</xsl:if>-->
    <!--</xsl:template>-->

    <!--&lt;!&ndash;-->
    <!--Les items QTI de type assiociateInteraction sont placés dans des éléments-->
    <!--de type Associate ou la colonne à gauche n'est pas montrée-->
    <!--&ndash;&gt;-->
    <!--<xsl:template match="qti:associateInteraction">-->
    <!--<xsl:variable name="idResponse" select="@responseIdentifier"/>-->
    <!--<xsl:variable name="response"-->
    <!--select="//qti:responseDeclaration[@identifier=$idResponse]"/>-->
    <!--<xsl:call-template name="Assiociate">-->
    <!--<xsl:with-param name="response" select="$response"/>-->
    <!--<xsl:with-param name="montrerColonneAGauche">false</xsl:with-param>-->
    <!--</xsl:call-template>-->
    <!--</xsl:template>-->

    <!--&lt;!&ndash;-->
    <!--Les items QTI de type matchInteraction sont placés dans des éléments-->
    <!--de type Associate ou la colonne à gauche est montrée-->
    <!--&ndash;&gt;-->
    <!--<xsl:template match="qti:matchInteraction">-->
    <!--<xsl:variable name="idResponse" select="@responseIdentifier"/>-->
    <!--<xsl:variable name="response"-->
    <!--select="//qti:responseDeclaration[@identifier=$idResponse]"/>-->
    <!--<xsl:call-template name="Assiociate">-->
    <!--<xsl:with-param name="response" select="$response"/>-->
    <!--<xsl:with-param name="montrerColonneAGauche">true</xsl:with-param>-->
    <!--</xsl:call-template>-->
    <!--</xsl:template>-->

    <!--&lt;!&ndash;-->
    <!--Les items QTI de type extendedTextInteraction sont placés dans des éléments-->
    <!--de type Open-->
    <!--&ndash;&gt;-->
    <!--<xsl:template match="qti:extendedTextInteraction">-->
    <!--<xsl:call-template name="Open">-->
    <!--</xsl:call-template>-->
    <!--</xsl:template>-->

    <!--&lt;!&ndash;-->
    <!--Les items QTI de type orderInteraction sont placés dans des éléments-->
    <!--de type Order-->
    <!--&ndash;&gt;-->
    <!--<xsl:template match="qti:orderInteraction">-->
    <!--<xsl:variable name="idResponse" select="@responseIdentifier"/>-->
    <!--<xsl:variable name="response"-->
    <!--select="//qti:responseDeclaration[@identifier=$idResponse]"/>-->
    <!--<xsl:call-template name="Order">-->
    <!--<xsl:with-param name="response" select="$response"/>-->
    <!--</xsl:call-template>-->
    <!--</xsl:template>-->


    <!--&lt;!&ndash;-->
    <!--Les items QTI de type sliderInteraction sont placés dans des éléments-->
    <!--de type Slider-->
    <!--&ndash;&gt;-->
    <!--<xsl:template match="qti:sliderInteraction">-->
    <!--<xsl:variable name="idResponse" select="@responseIdentifier"/>-->
    <!--<xsl:variable name="response"-->
    <!--select="//qti:responseDeclaration[@identifier=$idResponse]"/>-->
    <!--<xsl:call-template name="Slider">-->
    <!--<xsl:with-param name="response" select="$response"/>-->
    <!--</xsl:call-template>-->
    <!--</xsl:template>-->

    <!--&lt;!&ndash;-->
    <!--Les items QTI de type uploadInteraction sont placés dans des éléments-->
    <!--de type FileUpload-->
    <!--&ndash;&gt;-->
    <!--<xsl:template match="qti:uploadInteraction">-->
    <!--<xsl:call-template name="FileUpload">-->
    <!--</xsl:call-template>-->
    <!--</xsl:template>-->

    <!--&lt;!&ndash;-->
    <!--Les items QTI de type gapMatchInteraction sont placés dans des éléments-->
    <!--de type FillGap-->
    <!--&ndash;&gt;-->
    <!--<xsl:template match="qti:gapMatchInteraction">-->
    <!--<xsl:variable name="idResponse" select="@responseIdentifier"/>-->
    <!--<xsl:variable name="response"-->
    <!--select="//qti:responseDeclaration[@identifier=$idResponse]"/>-->
    <!--<xsl:call-template name="FillGap">-->
    <!--<xsl:with-param name="response" select="$response"/>-->
    <!--<xsl:with-param name="saisieLibre">true</xsl:with-param>-->
    <!--<xsl:with-param name="montrerLesMots">true</xsl:with-param>-->
    <!--</xsl:call-template>-->
    <!--</xsl:template>-->

    <!--&lt;!&ndash;-->
    <!--Les items QTI de type graphicGapMatchInteraction sont placés dans des éléments-->
    <!--de type GraphicMatch-->
    <!--&ndash;&gt;-->
    <!--<xsl:template match="qti:graphicGapMatchInteraction">-->
    <!--<xsl:variable name="idResponse" select="@responseIdentifier"/>-->
    <!--<xsl:variable name="response"-->
    <!--select="//qti:responseDeclaration[@identifier=$idResponse]"/>-->
    <!--<xsl:call-template name="GraphicMatch">-->
    <!--<xsl:with-param name="response" select="$response"/>-->
    <!--</xsl:call-template>-->
    <!--</xsl:template>-->

    <!--&lt;!&ndash;-->
    <!--On ignore les éléments non supportés par eliot- tdbase-->
    <!--&ndash;&gt;-->
    <!--<xsl:template match="qti:outcomeDeclaration"/>-->
    <!--<xsl:template match="qti:responseProcessing"/>-->

    <!--&lt;!&ndash;-->
    <!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
    <!--Template nommés pour le rendu des types de question eliot-tdbase-->
    <!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
    <!--&ndash;&gt;-->


    <!--&lt;!&ndash;-->
    <!--Template pour la generation d'une Document question-->
    <!--&ndash;&gt;-->
    <!--<xsl:template name="Document">-->
    <!--,{-->
    <!--"questionTypeCode": "Document",-->
    <!--"presentation" : "<xsl:value-of select="@alt"/>",-->
    <!--"questionAttachementSrc": "<xsl:value-of select="@src"/>"-->
    <!--}-->
    <!--</xsl:template>-->



    <!--&lt;!&ndash;-->
    <!--Template pour la generation d'une GraphicMatch question-->
    <!--@param response un element de type qti:responseDeclaration/qti:correctResponse-->
    <!--&ndash;&gt;-->
    <!--<xsl:template name="GraphicMatch">-->
    <!--<xsl:param name="response"/>-->
    <!--,{-->
    <!--"questionTypeCode" : "GraphicMatch",-->
    <!--"libelle" : "<xsl:value-of select="normalize-space(qti:prompt)"/>",-->
    <!--"attachmentSrc" : "<xsl:value-of select="qti:object/@data"/>",-->
    <!--"hotspots" : [-->
    <!--<xsl:call-template name="constitueHotspots">-->
    <!--<xsl:with-param name="graphicGapMatchInteraction" select="."/>-->
    <!--</xsl:call-template>-->
    <!--],-->
    <!--"icons" : [-->
    <!--<xsl:call-template name="constitueIcons">-->
    <!--<xsl:with-param name="response" select="$response"/>-->
    <!--<xsl:with-param name="graphicGapMatchInteraction" select="."/>-->
    <!--</xsl:call-template>-->
    <!--],-->
    <!--"graphicMatches" : {-->
    <!--<xsl:call-template name="constitueGraphicMatchs">-->
    <!--<xsl:with-param name="response" select="$response"/>-->
    <!--</xsl:call-template>-->
    <!--}-->
    <!--}-->
    <!--</xsl:template>-->

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
    <!--Template pour la generation d'une Open question-->
    <!--@param response un element de type qti:responseDeclaration/qti:correctResponse-->
    <!--&ndash;&gt;-->
    <!--<xsl:template name="FileUpload">-->
    <!--,{-->
    <!--"questionTypeCode" : "FileUpload",-->
    <!--"libelle" : "<xsl:value-of select="normalize-space(qti:prompt)"/>"-->
    <!--}-->
    <!--</xsl:template>-->

    <!--&lt;!&ndash;-->
    <!--Template pour la generation d'une Open question-->
    <!--@param response un element de type qti:responseDeclaration/qti:correctResponse-->
    <!--&ndash;&gt;-->
    <!--<xsl:template name="Slider">-->
    <!--<xsl:param name="response"/>-->
    <!--,{-->
    <!--"questionTypeCode" : "Slider",-->
    <!--"libelle" : "<xsl:value-of select="normalize-space(qti:prompt)"/>",-->
    <!--"valeur" : <xsl:value-of select="$response/qti:correctResponse/qti:value/text()"/>,-->
    <!--"valeurMin" : <xsl:value-of select="@lowerBound"/>,-->
    <!--"valeurMax" : <xsl:value-of select="@upperBound"/>,-->
    <!--"pas" : <xsl:value-of select="@step"/>,-->
    <!--"precision" :-->
    <!--<xsl:value-of select="@step"/>-->
    <!--}-->
    <!--</xsl:template>-->


    <!--&lt;!&ndash;-->
    <!--Template pour la generation d'une Open question-->
    <!--@param response un element de type qti:responseDeclaration/qti:correctResponse-->
    <!--&ndash;&gt;-->
    <!--<xsl:template name="Order">-->
    <!--<xsl:param name="response"/>-->
    <!--,{-->
    <!--"questionTypeCode" : "Order",-->
    <!--"libelle" : "<xsl:value-of select="normalize-space(qti:prompt)"/>",-->
    <!--"orderedItems" : [-->
    <!--<xsl:call-template name="constitueItemsOrdonnes">-->
    <!--<xsl:with-param name="correctResponseElt" select="$response"/>-->
    <!--<xsl:with-param name="orderInteractionElt" select="."/>-->
    <!--</xsl:call-template>-->
    <!--]-->
    <!--}-->
    <!--</xsl:template>-->

    <!--&lt;!&ndash;-->
    <!--Template pour la generation d'une Open question-->
    <!--@param response un element de type qti:responseDeclaration/qti:correctResponse-->
    <!--&ndash;&gt;-->
    <!--<xsl:template name="Open">-->
    <!--<xsl:variable name="nbLignes" select="floor(@expectedLength div 80)+1"/>-->
    <!--,{-->
    <!--"questionTypeCode" : "Open",-->
    <!--"libelle" : "<xsl:value-of select="normalize-space(qti:prompt)"/>",-->
    <!--"nombreLignesReponses" :-->
    <!--<xsl:value-of select="$nbLignes"/>-->
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

    <!--&lt;!&ndash;-->
    <!--Constitue les items ordonnés pour une question de type Order-->
    <!--@param correctResponseElt un element de type qti:responseDeclaration-->
    <!--@param orderInteractionElt un element de type qti:orderInteraction-->
    <!--&ndash;&gt;-->
    <!--<xsl:template name="constitueItemsOrdonnes">-->
    <!--<xsl:param name="correctResponseElt"/>-->
    <!--<xsl:param name="orderInteractionElt"/>-->
    <!--<xsl:for-each-->
    <!--select="$correctResponseElt/qti:correctResponse/qti:value">-->
    <!--<xsl:variable name="identifier" select="text()"/>-->
    <!--{-->
    <!--"text": "<xsl:value-of-->
    <!--select="$orderInteractionElt//qti:simpleChoice[@identifier=$identifier]"/>",-->
    <!--"ordinal": "<xsl:value-of select="position()"/>"-->
    <!--}<xsl:if test="position()!=last()">,</xsl:if>-->
    <!--</xsl:for-each>-->
    <!--</xsl:template>-->

    <!--&lt;!&ndash;-->
    <!--Constitue le texte à trous pour une question de type FillGap-->
    <!--@param responseElt un element de type qti:responseDeclaration-->
    <!--@param gapMatchInteractionElt un element de type qti:gapMatchInteraction-->
    <!--&ndash;&gt;-->
    <!--<xsl:template name="constitueTexteATrous">-->
    <!--<xsl:param name="responseElt"/>-->
    <!--<xsl:param name="gapMatchInteractionElt"/>-->
    <!--<xsl:apply-templates select=".//node()">-->
    <!--<xsl:with-param name="responseElt" select="$responseElt"/>-->
    <!--<xsl:with-param name="gapMatchInteractionElt"-->
    <!--select="$gapMatchInteractionElt"/>-->
    <!--</xsl:apply-templates>-->
    <!--</xsl:template>-->

    <!--<xsl:template-->
    <!--match="qti:gapMatchInteraction//node()[string-length(normalize-space(text()))>0]"-->
    <!--priority="-0.5">-->
    <!--<xsl:copy>-->
    <!--<xsl:apply-templates-->
    <!--select="qti:gapMatchInteraction//node()[string-length(normalize-space(text()))>0]"/>-->
    <!--</xsl:copy>-->
    <!--</xsl:template>-->

    <!--<xsl:template match="qti:gap">-->
    <!--<xsl:param name="responseElt"/>-->
    <!--<xsl:param name="gapMatchInteractionElt"/>-->
    <!--<xsl:variable name="gapId" select="@identifier"/>-->
    <!--{-->
    <!--<xsl:for-each select="$gapMatchInteractionElt/qti:gapText">-->
    <!--<xsl:variable name="gapTextId" select="@identifier"/>-->
    <!--<xsl:variable name="gapTextIdWithCurrentGap"-->
    <!--select="tokenize($responseElt/qti:correctResponse/qti:value[tokenize(text(),'\s+')[2]=$gapId]/text(),'\s+')[1]"/>-->
    <!--<xsl:if test="$gapTextIdWithCurrentGap=$gapTextId">=</xsl:if>-->
    <!--<xsl:if test="not($gapTextIdWithCurrentGap=$gapTextId)">~</xsl:if>-->
    <!--<xsl:value-of select="text()"/>-->
    <!--</xsl:for-each>-->
    <!--}-->
    <!--</xsl:template>-->

    <!--<xsl:template match="qti:gapText//node()"/>-->
    <!--<xsl:template match="qti:prompt//node()"/>-->

    <!--&lt;!&ndash;-->
    <!--Constitue les hotspots pour une question de type GraphicMatch-->
    <!--@param graphicGapMatchInteraction un element de type qti:graphicGapMatchInteraction-->
    <!--&ndash;&gt;-->
    <!--<xsl:template name="constitueHotspots">-->
    <!--<xsl:param name="graphicGapMatchInteraction"/>-->
    <!--<xsl:for-each-->
    <!--select="$graphicGapMatchInteraction/qti:associableHotspot">-->
    <!--<xsl:variable name="tabCoords" select="tokenize(@coords,',')"/>-->
    <!--{"id":"<xsl:value-of-->
    <!--select="@identifier"/>","topDistance":<xsl:value-of-->
    <!--select="$tabCoords[2]"/>, "leftDistance":<xsl:value-of-->
    <!--select="$tabCoords[1]"/> }-->
    <!--<xsl:if test="position()!=last()">,</xsl:if>-->
    <!--</xsl:for-each>-->
    <!--</xsl:template>-->

    <!--&lt;!&ndash;-->
    <!--Constitue les icons pour une question de type GraphicMatch-->
    <!--@param graphicGapMatchInteraction un element de type qti:graphicGapMatchInteraction-->
    <!--@param response un élément de type de qti:responseDeclaration-->
    <!--&ndash;&gt;-->
    <!--<xsl:template name="constitueIcons">-->
    <!--<xsl:param name="graphicGapMatchInteraction"/>-->
    <!--<xsl:param name="response"/>-->
    <!--<xsl:for-each-->
    <!--select="$response/qti:correctResponse/qti:value">-->
    <!--<xsl:variable name="idImg" select="tokenize(text(),'\s+')[1]"/>-->
    <!--{"id":"<xsl:value-of select="$idImg"/>","attachmentSrc":-->
    <!--"<xsl:value-of-->
    <!--select="$graphicGapMatchInteraction/qti:gapImg[@identifier=$idImg]/qti:object/@data"/>"}-->
    <!--<xsl:if test="position()!=last()">,</xsl:if>-->
    <!--</xsl:for-each>-->
    <!--</xsl:template>-->

    <!--&lt;!&ndash;-->
    <!--Constitue les matches pour une question de type GraphicMatch-->
    <!--@param response un élément de type de qti:responseDeclaration-->
    <!--&ndash;&gt;-->
    <!--<xsl:template name="constitueGraphicMatchs">-->
    <!--<xsl:param name="response"/>-->
    <!--<xsl:for-each-->
    <!--select="$response/qti:correctResponse/qti:value">-->
    <!--<xsl:variable name="idsTab" select="tokenize(text(),'\s+')"/>-->
    <!--"<xsl:value-of select="$idsTab[1]"/>" : "<xsl:value-of-->
    <!--select="$idsTab[2]"/>"-->
    <!--<xsl:if test="position()!=last()">,</xsl:if>-->
    <!--</xsl:for-each>-->
    <!--</xsl:template>-->

    <!-- Credit:  Bram Stein http://www.bramstein.com/projects/xsltjson/ -->
    <xsl:function name="json:encode-string" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence select="replace(
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
        						'\t','\\t')"/>
    </xsl:function>

</xsl:stylesheet>