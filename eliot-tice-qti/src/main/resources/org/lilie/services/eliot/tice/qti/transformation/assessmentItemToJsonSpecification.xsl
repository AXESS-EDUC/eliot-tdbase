<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:qti="http://www.imsglobal.org/xsd/imsqti_v2p0">

    <xsl:output encoding="UTF-8" omit-xml-declaration="yes" method="text"/>


    <xsl:template match="qti:assessmentItem" xml:space="preserve">
    {
      "title" : "<xsl:value-of select="./@title"/>"
      "questions" : [
        <xsl:apply-templates select="qti:itemBody"/>
      ]
    }
    </xsl:template>

    <xsl:template match="qti:itemBody">
        <xsl:apply-templates/>
    </xsl:template>

    <!--
        Tous les noeuds ne faisant pas l'objet d'un traitement particulier sont
        recopiés. On perd le balisage en raison du format de sortie textuel.
    -->
    <xsl:template match="qti:itemBody/node()[string-length(normalize-space(text()))>0]" priority="-1">
        {
        "questionTypeCode": "Statement",
        "enonce" : "&lt;p&gt;<xsl:copy-of select="text()"></xsl:copy-of>&lt;/p&gt;"
        },
        <xsl:apply-templates select="qti:itemBody/node()[string-length(normalize-space(text()))>0]"/>
    </xsl:template>




    <xsl:template match="qti:choiceInteraction">
        {
        <xsl:if test="@maxChoices > 1">"questionTypeCode" : "MultipleChoice",</xsl:if>
        <xsl:if test="@maxChoices = 1">"questionTypeCode" : "ExclusiveChoice",</xsl:if>
        "libelle" : "<xsl:value-of select="qti:prompt"/>",

        },
    </xsl:template>


    <xsl:template match="qti:img">
        {
        "questionTypeCode": "Document",
        "presentation" : "<xsl:value-of select="@alt"/>",
        "questionAttachementSrc": "<xsl:value-of select="@src"/>"
        },
    </xsl:template>

    <!--
    Traitement des responses declaration
    -->
    <xsl:template match="qti:responseDeclaration">
            <!--todofsil-->
    </xsl:template>

    <!--
    On ignore les éléments non supportés par eliot- tdbase
    -->
    <xsl:template match="qti:outcomeDeclaration"/>
    <xsl:template match="qti:responseProcessing"/>

</xsl:stylesheet>