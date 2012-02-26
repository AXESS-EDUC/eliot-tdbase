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

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:qti="http://www.imsglobal.org/xsd/imsqti_v2p0">

    <xsl:output encoding="UTF-8" omit-xml-declaration="yes" method="text"/>

    <!--
     Traitement du neoud racine
    -->
    <xsl:template match="qti:assessmentItem" xml:space="preserve">
    {
      "title" : "<xsl:value-of select="./@title"/>"
      "questions" : [
        <xsl:apply-templates select="qti:itemBody"/>
      ]
    }
    </xsl:template>

    <!--
      Traitement du corps de l'item
    -->
    <xsl:template match="qti:itemBody">
        <xsl:apply-templates/>
    </xsl:template>

    <!--
        Tous les noeuds ne faisant pas l'objet d'un traitement particulier sont
        recopiés et placés dans un item de type Statement.
        On perd le balisage en raison du format de sortie textuel.
    -->
    <xsl:template
            match="qti:itemBody/node()[string-length(normalize-space(text()))>0]"
            priority="-1">
        {
        "questionTypeCode": "Statement",
        "enonce" : "&lt;p&gt;<xsl:copy-of select="text()"></xsl:copy-of>&lt;/p&gt;"
        },
        <xsl:apply-templates
                select="qti:itemBody/node()[string-length(normalize-space(text()))>0]"/>
    </xsl:template>

    <!--
       Les éléments 'img' sont plaçés dans des items de type document
    -->
    <xsl:template match="qti:img">
        {
        "questionTypeCode": "Document",
        "presentation" : "<xsl:value-of select="@alt"/>",
        "questionAttachementSrc": "<xsl:value-of select="@src"/>"
        },
    </xsl:template>

    <!--
       Les items QTI de type choiceInteraction sont placés dans des éléments de
       type MultipleChoice ou ExclusiveChoice
    -->
    <xsl:template match="qti:choiceInteraction">
        <xsl:variable name="idResponse" select="@responseIdentifier"/>
        <xsl:variable name="response"
                      select="//qti:responseDeclaration[@identifier=$idResponse]"/>
        <xsl:if test="$response/@cardinality = 'multiple'">
            <xsl:call-template name="MultipleChoice">
                <xsl:with-param name="response" select="$response"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$response/@cardinality = 'single'">
            <xsl:call-template name="ExclusiveChoice">
                <xsl:with-param name="response" select="$response"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!--
       Les items QTI de type assiociateInteraction sont placés dans des éléments
       de type Associate ou la colonne à gauche n'est pas montrée
    -->
    <xsl:template match="qti:associateInteraction">
        <xsl:variable name="idResponse" select="@responseIdentifier"/>
        <xsl:variable name="response"
                      select="//qti:responseDeclaration[@identifier=$idResponse]"/>
        <xsl:call-template name="Assiociate">
            <xsl:with-param name="response" select="$response"/>
            <xsl:with-param name="montrerColonneAGauche">false</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!--
    On ignore les éléments non supportés par eliot- tdbase
    -->
    <xsl:template match="qti:outcomeDeclaration"/>
    <xsl:template match="qti:responseProcessing"/>


    <!--
    Template pour la generation d'une MultipleChoice question
    @param response un élément de type qti:responseDeclaration/qti:correctResponse
    @param montrerColonneAGauche true si il faut montrer la colonne à gauche
    -->
    <xsl:template name="Assiociate">
        <xsl:param name="response"/>
        <xsl:param name="montrerColonneAGauche"/>
        {
        "questionTypeCode" : "Associate",
        "libelle" : "<xsl:value-of select="qti:prompt"/>",
        "montrerColonneAGauche" : <xsl:value-of select="$montrerColonneAGauche"/>,
        "associations" : [ <xsl:call-template name="constituePaires">
                            <xsl:with-param name="associateInteractionElt" select="."/>
                            <xsl:with-param name="correctResponseElt" select="$response"/>
                            </xsl:call-template>]
        },
    </xsl:template>

    <!--
    Template pour la generation d'une MultipleChoice question
    @param response un element de type qti:responseDeclaration/qti:correctResponse
    -->
    <xsl:template name="MultipleChoice">
        <xsl:param name="response"/>
        {
        "questionTypeCode" : "MultipleChoice",
        "libelle" : "<xsl:value-of select="qti:prompt"/>",
        "shuffled" : <xsl:value-of select="@shuffle"/>,
        "reponses" : [
        <xsl:for-each select="qti:simpleChoice">
            {
            "libelleReponse" : "<xsl:value-of select="text()"/>",
            "estUneBonneReponse" :
            <xsl:call-template
                    name="afficheTrueSiReponseCorrecte">
                <xsl:with-param name="correctResponseElt"
                                select="$response/qti:correctResponse"/>
                <xsl:with-param name="idReponseAEvaluer" select="@identifier"/>
            </xsl:call-template>
            },
        </xsl:for-each>
        ]
        },
    </xsl:template>


    <!--
        Template pour la generation d'une MultipleChoice question
        @param response  un element de type qti:correctResponse
    -->
    <xsl:template name="ExclusiveChoice">
        <xsl:param name="response"/>
        {
        "questionTypeCode" : "ExclusiveChoice",
        "libelle" : "<xsl:value-of select="qti:prompt"/>",
        "shuffled" : <xsl:value-of select="@shuffle"/>,
        "indexBonneReponse": "<xsl:value-of
            select="$response/qti:correctResponse/qti:value"/>",
        "reponses" : [
        <xsl:for-each select="qti:simpleChoice">
            {
            "libelleReponse" : "<xsl:value-of select="text()"/>",
            "id" : "<xsl:value-of select="@identifier"/>"
            },
        </xsl:for-each>
        ]
        },
    </xsl:template>

    <!--
       Affiche true si une reponse est correcte
       @param correctResponseElt un element de type qti:correctResponse
       @param idReponseAEvaluer valeur d'un simpleChoice/@identifier
    -->
    <xsl:template name="afficheTrueSiReponseCorrecte">
        <xsl:param name="correctResponseElt"/>
        <xsl:param name="idReponseAEvaluer"/>
        <xsl:variable name="reponseCorrecte"
                      select="$correctResponseElt/qti:value[text()=$idReponseAEvaluer]"/>
        <xsl:if test="$reponseCorrecte">true</xsl:if>
        <xsl:if test="not($reponseCorrecte)">false</xsl:if>
    </xsl:template>

    <xsl:template name="constituePaires">
        <xsl:param name="correctResponseElt"/>
        <xsl:param name="associateInteractionElt"/>
        <xsl:for-each select="$correctResponseElt/qti:correctResponse/qti:value">
            <xsl:variable name="tabPartIds" select="tokenize(text(),'\s+')"/>
          {
            "participant1": "<xsl:value-of select="$associateInteractionElt/qti:simpleAssociableChoice[@identifier=$tabPartIds[1]]"/>",
            "participant2": "<xsl:value-of select="$associateInteractionElt/qti:simpleAssociableChoice[@identifier=$tabPartIds[2]]"/>"
          },
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>