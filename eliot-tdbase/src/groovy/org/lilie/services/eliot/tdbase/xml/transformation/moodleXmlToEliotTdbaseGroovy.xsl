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
        [
        "quiz" : [
        [
        "nombreItems" : <xsl:value-of
            select="count(question[@type != 'category'])"/>,
        "nombreImages" :
        <xsl:value-of
                select="count(//image/text())"/>
        ]
        <xsl:for-each select="question[@type != 'category']">
            ,
            [
            "titre" : """<xsl:value-of
                select="name/text/text()"/>""",
            "attachementInputId" : "<xsl:apply-templates select="image"/>",
            <xsl:apply-templates select="."/>
            ]
        </xsl:for-each>
        ]
        ]
    </xsl:template>


    <!--
      Traitement d'une question  de type "calculated", "Cloze"
      Renvoie vers le template de question non supportée
    -->
    <xsl:template match="question[@type = 'calculated' or @type = 'cloze']">
        <xsl:call-template name="type_question_non_supporte"/>
    </xsl:template>

    <xsl:template match="image">
        <xsl:value-of select="text()"/>
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
            <xsl:when test="single = false()">
                <xsl:call-template name="MultipleChoice"/>
            </xsl:when>
            <xsl:when test="single = true()">
                <xsl:call-template name="ExclusiveChoice"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!--
         Les questions de type truefalse sont associées à un item de type
         ExclusiveChoice.
    -->
    <xsl:template match="question[@type = 'truefalse']">
        <xsl:call-template name="ExclusiveChoice"/>
    </xsl:template>

    <!--
         Les questions de type numerical sont associées à un item de type
         Decimal.
    -->
    <xsl:template match="question[@type = 'numerical']">
        <xsl:call-template name="Decimal"/>
    </xsl:template>

    <!--
         Les questions de type shortAnswer sont associées à un item de type
         FillGap.
    -->
    <xsl:template match="question[@type = 'shortanswer']">
        <xsl:call-template name="FillGap"/>
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
        "specification" : """{
        "questionTypeCode": "Statement",
        "enonce" : "<xsl:value-of select="json:encode-string(questiontext/text/text())"/>"
        }"""

    </xsl:template>

    <!--
        Template pour la generation d'une Statement question
     -->
    <xsl:template name="Open">
        "questionTypeCode": "Open",
        "specification" : """{
        "questionTypeCode": "Open",
        "libelle" : "<xsl:value-of select="json:encode-string(questiontext/text/text())"/>",
        "nombreLignesReponse" : 5
        }"""
    </xsl:template>

    <!--
        Template pour la génération d'une Associate question
     -->
    <xsl:template name="Associate">
        "questionTypeCode" : "Associate",
        "specification" : """{
        "questionTypeCode" : "Associate",
        "libelle" : "<xsl:value-of select="json:encode-string(questiontext/text/text())"/>",
        "montrerColonneAGauche" : true,
        "associations" : [
        <xsl:for-each select="subquestion">
            {
            "participant1": "<xsl:value-of select="json:encode-string(text/text())"/>",
            "participant2": "<xsl:value-of select="json:encode-string(answer/text/text())"/>"
            }
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        ]
        }"""
    </xsl:template>

    <!--
       Template pour la génération d'une MultipleChoice question
    -->
    <xsl:template name="MultipleChoice">
        "questionTypeCode" : "MultipleChoice",
        "specification" : """{
        "questionTypeCode" : "MultipleChoice",
        "libelle" : "<xsl:value-of select="json:encode-string(questiontext/text/text())"/>",
        "shuffled" :
        <xsl:choose>
            <xsl:when test="shuffleanswers/text() = 1">true</xsl:when>
            <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
        ,
        "reponses" : [
        <xsl:for-each select="answer">
            {
            "libelleReponse" : "<xsl:value-of select="json:encode-string(text/text())"/>",
            "estUneBonneReponse" :
            <xsl:choose>
                <xsl:when test="@fraction &lt;= 0">false</xsl:when>
                <xsl:otherwise>true</xsl:otherwise>
            </xsl:choose>
            ,
            "id" : "<xsl:value-of select="position()"/>"
            }
            <xsl:if test="position()!=last()">,</xsl:if>
        </xsl:for-each>
        ]
        }"""
    </xsl:template>

    <!--
        Template pour la génération d'une ExclusiveChoice question
    -->
    <xsl:template name="ExclusiveChoice">
        "questionTypeCode" : "ExclusiveChoice",
        "specification" : """{
        "questionTypeCode" : "ExclusiveChoice",
        "libelle" : "<xsl:value-of select="json:encode-string(questiontext/text/text())"/>",
        "shuffled" :
        <xsl:choose>
            <xsl:when test="shuffleanswers = true()">true</xsl:when>
            <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
        ,
        "reponses" : [
        <xsl:for-each select="answer">
            {
            "libelleReponse" : "<xsl:value-of select="json:encode-string(text/text())"/>",
            "id" : "<xsl:value-of select="position()"/>"
            }
            <xsl:if test="position()!=last()">,</xsl:if>
        </xsl:for-each>
        ],
        "indexBonneReponse":
        <xsl:for-each select="answer">
            <xsl:if test="@fraction &gt; 0">"<xsl:value-of select="position()"/>"
            </xsl:if>
        </xsl:for-each>
        }"""
    </xsl:template>


    <!--
        Template pour la génération d'une Decimal question
        -->
    <xsl:template name="Decimal">
        "questionTypeCode":"Decimal",
        "specification" : """{
        "questionTypeCode":"Decimal",
        "libelle" : "<xsl:value-of select="json:encode-string(questiontext/text/text())"/>",
        "valeur" : <xsl:value-of select="answer/text/text()"/>,
        "unite": "<xsl:value-of select="units/unit[1]/unit_name/text()"/>",
        "precision":
        <xsl:value-of select="answer/tolerance/text()"/>
        }"""
    </xsl:template>

    <!--
         Template pour la génération d'une FillGap question
            -->
    <xsl:template name="FillGap">
        "questionTypeCode" : "FillGap",
        "specification" : """{
        "questionTypeCode" : "FillGap",
        "libelle" : "<xsl:value-of select="json:encode-string(questiontext/text/text())"/>",
        "modeDeSaisie" : "SL",
        "texteATrous" : "<xsl:value-of select="json:encode-string(questiontext/text/text())"/> {
        <xsl:for-each select="answer">
            <xsl:choose>
                <xsl:when test="@fraction &gt; 0">=<xsl:value-of
                        select="json:encode-string(normalize-space(text/text()))"/>
                </xsl:when>
                <xsl:when test="@fraction &lt;= 0">~<xsl:value-of
                        select="json:encode-string(normalize-space(text/text()))"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        }"
        }"""
    </xsl:template>


    <!-- Credit:  Bram Stein http://www.bramstein.com/projects/xsltjson/ -->
    <xsl:function name="json:encode-string" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:if test="$string">
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
        </xsl:if>
        <xsl:if test="not($string)">
            <xsl:value-of select="$string"/>
        </xsl:if>
    </xsl:function>

</xsl:stylesheet>