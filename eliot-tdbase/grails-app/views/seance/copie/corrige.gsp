<%@ page import="org.lilie.services.eliot.tice.utils.NumberUtils" %>
%{--
  - Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
  - This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
  -
  - Lilie is free software. You can redistribute it and/or modify since
  - you respect the terms of either (at least one of the both license) :
  -  under the terms of the GNU Affero General Public License as
  - published by the Free Software Foundation, either version 3 of the
  - License, or (at your option) any later version.
  -  the CeCILL-C as published by CeCILL-C; either version 1 of the
  - License, or any later version
  -
  - There are special exceptions to the terms and conditions of the
  - licenses as they are applied to this software. View the full text of
  - the exception in file LICENSE.txt in the directory of this software
  - distribution.
  -
  - Lilie is distributed in the hope that it will be useful,
  - but WITHOUT ANY WARRANTY; without even the implied warranty of
  - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  - Licenses for more details.
  -
  - You should have received a copy of the GNU General Public License
  - and the CeCILL-C along with Lilie. If not, see :
  -  <http://www.gnu.org/licenses/> and
  -  <http://www.cecill.info/licences.fr.html>.
  --}%
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta name="layout" content="eliot-tdbase"/>
  <r:require module="seanceCopie_CorrigeJS"/>
  <r:script>
    $(document).ready(function () {
        $(".editinplace").editInPlace({
            default_text:"",
            url:"${g.createLink(controller: 'seance', action: 'updateReponseNote')}",
            success:function (jsonRes) {
                var res = JSON.parse(jsonRes);
                var eltId = "#" + res[0];
                $(eltId).html(res[1]);
                if (res.length > 2) {
                    $("#copie_note_finale").html(res[2]);
                }
            }
        });
    });
  </r:script>
  <title><g:message code="seance.copie.corrige.head.title"/> </title>
</head>

<body>

<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>
<div class="portal_pagination">
  <p class="nb_result">${copies.totalCount} élève(s)</p><g:paginate
        total="${copies.totalCount}"
        id="${seance.id}">
</g:paginate>
</div>
<g:set var="copie" value="${copies[0]}"/>

<g:hasErrors>
  <div class="portal-messages">
    <g:eachError>
      <li class="error"><g:message error="${it}"/></li>
    </g:eachError>
  </div>
</g:hasErrors>
<g:if test="${request.messageCode}">
  <div class="portal-messages">
    <li class="success"><g:message code="${request.messageCode}"
                                   class="portal-messages success"/></li>
  </div>
</g:if>
<g:set var="sujet" value="${copie.sujet}"/>
<form method="post">

  <g:hiddenField name="copieId" value="${copie.id}"/>
  <div class="portal-form_container corrige">
    <table>
      <tr>
        <td class="label">Élève :</td>
        <td><strong>${copie.eleve.nomAffichage}</strong></td>
      </tr>

      <tr>
        <td class="label">Appréciation :</td>
        <td>
          <g:textArea name="copieAnnotation"
                      value="${copie.correctionAnnotation}" rows="3"
                      cols="50" style="height: auto;"/>
        </td>
      </tr>
      <tr>
        <td class="label">Modulation :</td>
        <td>
          <g:textField name="copiePointsModulation"
                       value="${NumberUtils.formatFloat(copie.pointsModulation)}" class="micro"/>
        </td>
      </tr>
      <tr>
        <td class="label">Note :</td>
        <td>
          <strong><span
                  id="copie_note_finale">${NumberUtils.formatFloat(copie.correctionNoteFinale ?: 0)}</span>
            / <g:formatNumber number="${copie.maxPoints}"
                              format="##0.00"/></strong>
        </td>
      </tr>
    </table>
  </div>
  <g:hiddenField name="copieNoteFinale" value="${NumberUtils.formatFloat(copie.correctionNoteFinale ?: 0)}"/>
  <g:hiddenField name="copieMaxPoints" value="${copie.maxPoints}"/>
  <div class="form_actions corrige">
    <g:actionSubmit value="Enregistrer" action="enregistreCopie" class="button"
                    title="Enregistrer" id="${seance.id}"/>
  </div>
</form>

<div class="correction_copie">
<h1 class="tdbase-sujet-titre">${sujet.titre}</h1>
<g:set var="indexReponseNonVide" value="0"/>
<g:set var="indexQuestion" value="1"/>
<g:set var="exericeEnCours" value="${null}"/>
<g:set var="indexExercice" value="0"/>
<g:set var="indexQuestionInExercice" value="1"/>
<g:set var="etaitDansUnExercice" value="${false}"/>

<g:each in="${copie.reponses}" var="reponse">
  <g:set var="sujetQuestion" value="${reponse.sujetQuestion}"/>
  <g:set var="question" value="${sujetQuestion.question}"/>
  <g:set var="sujetEnCours" value="${sujetQuestion.sujet}"/>

  <g:if test="${etaitDansUnExercice && sujetEnCours != exericeEnCours}">
    </div>
<!-- Fermeture div exercice  quand exercice termine-->
    <g:set var="etaitDansUnExercice" value="${false}"/>
  </g:if>


  <g:if test="${sujetEnCours == sujet}">
    <!-- -------------------------------- -->
   <!-- mode question de premier niveau -->
   <!-- -------------------------------- -->
   <div class="tdbase-sujet-edition-question">
    <g:if test="${question.type.interaction}">
      <h1>Question ${indexQuestion}</h1>
      <g:set var="indexQuestion" value="${indexQuestion.toInteger() + 1}"/>
      <div class="tdbase-sujet-edition-question-points">
        <div id="SujetSequenceQuestions-${sujetQuestion.id}">
          <g:if test="${reponse.estEnNotationManuelle()}">
            <div class="editinplace" id="${reponse.id}"
                 title="Cliquez pour modifier le nombre de points...">
              <g:formatNumber number="${reponse.correctionNoteCorrecteur}"
                              format="##0.00"/>
            </div>
          </g:if>
          <g:else>
            <em><g:formatNumber number="${reponse.correctionNoteAutomatique}"
                                format="##0.00"/></em>
          </g:else>
        &nbsp;/&nbsp;<strong><g:formatNumber
                number="${sujetQuestion.points}"
                format="##0.00"/>&nbsp;point(s)</strong>
        </div>
      </div>

      <div class="tdbase-sujet-edition-question-interaction correction_copie">
        <g:hiddenField
                name="reponsesCopie.listeReponses[${indexReponseNonVide}].reponse.id"
                value="${reponse.id}"/>
        <g:render
                template="/question/Interaction"
                model="[question: question, reponse: reponse, indexReponse: indexReponseNonVide]"/>

        <g:set var="indexReponseNonVide"
               value="${indexReponseNonVide.toInteger() + 1}"/>

        <g:render
                template="/question/${question.type.code}/${question.type.code}Correction"
                model="[question: question]"/>

      </div>
    </g:if>
    <g:else>
      <div class="tdbase-sujet-edition-question-interaction correction_copie">
        <g:render
                template="/question/Preview"
                model="[question: question]"/>
      </div>
    </g:else>
  </g:if>
  <g:elseif test="${sujetEnCours == exericeEnCours}">
    <!-- -------------------------------- -->
   <!-- mode question dans un sujet -->
   <!-- -------------------------------- -->
   <div class="tdbase-sujet-edition-question">
    <g:if test="${question.type.interaction}">
      <h2>Ex. ${indexExercice} → Question ${indexQuestionInExercice}</h2>
      <g:set var="indexQuestionInExercice"
             value="${indexQuestionInExercice.toInteger() + 1}"/>
      <div class="tdbase-sujet-edition-question-points">
        <div id="SujetSequenceQuestions-${sujetQuestion.id}">
          <g:if test="${reponse.estEnNotationManuelle()}">
            <div class="editinplace" id="${reponse.id}"
                 title="Cliquez pour modifier le nombre de points...">
              <g:formatNumber number="${reponse.correctionNoteCorrecteur}"
                              format="##0.00"/>
            </div>
          </g:if>
          <g:else>
            <em><g:formatNumber number="${reponse.correctionNoteAutomatique}"
                                format="##0.00"/></em>
          </g:else>
        &nbsp;/&nbsp;<strong><g:formatNumber
                number="${sujetQuestion.points}"
                format="##0.00"/>&nbsp;point(s)</strong>
        </div>
      </div>

      <div class="tdbase-sujet-edition-question-interaction correction_copie">
        <g:hiddenField
                name="reponsesCopie.listeReponses[${indexReponseNonVide}].reponse.id"
                value="${reponse.id}"/>
        <g:render
                template="/question/Interaction"
                model="[question: question, reponse: reponse, indexReponse: indexReponseNonVide]"/>

        <g:set var="indexReponseNonVide"
               value="${indexReponseNonVide.toInteger() + 1}"/>

        <g:render
                template="/question/${question.type.code}/${question.type.code}Correction"
                model="[question: question]"/>

      </div>
    </g:if>
    <g:else>
      <div class="tdbase-sujet-edition-question-interaction correction_copie">
        <g:render
                template="/question/Preview"
                model="[question: question]"/>
      </div>
    </g:else>

  </g:elseif>
  <g:else>
    <!-- -------------------------------- -->
  <!-- entrée dans un exerice -->
  <!-- -------------------------------- -->
    <g:set var="exericeEnCours" value="${sujetQuestion.sujet}"/>
    <g:set var="indexQuestionInExercice" value="1"/>
    <g:set var="indexExercice" value="${indexExercice.toInteger() + 1}"/>
    <g:set var="etaitDansUnExercice" value="${true}"/>
    <div class="exercice" id="exercice_${indexExercice}">

    <h1>Exercice ${indexExercice}</h1>

    <div class="tdbase-sujet-edition-question">
    <h2>Ex. ${indexExercice} → Question ${indexQuestionInExercice}</h2>

    <g:set var="indexQuestionInExercice"
           value="${indexQuestionInExercice.toInteger() + 1}"/>
    <g:if test="${question.type.interaction}">
      <div class="tdbase-sujet-edition-question-points">
        <div id="SujetSequenceQuestions-${sujetQuestion.id}">
          <g:if test="${reponse.estEnNotationManuelle()}">
            <div class="editinplace" id="${reponse.id}"
                 title="Cliquez pour modifier le nombre de points...">
              <g:formatNumber number="${reponse.correctionNoteCorrecteur}"
                              format="##0.00"/>
            </div>
          </g:if>
          <g:else>
            <em><g:formatNumber number="${reponse.correctionNoteAutomatique}"
                                format="##0.00"/></em>
          </g:else>
        &nbsp;/&nbsp;<strong><g:formatNumber
                number="${sujetQuestion.points}"
                format="##0.00"/>&nbsp;point(s)</strong>
        </div>
      </div>

      <div class="tdbase-sujet-edition-question-interaction correction_copie">
        <g:hiddenField
                name="reponsesCopie.listeReponses[${indexReponseNonVide}].reponse.id"
                value="${reponse.id}"/>
        <g:render
                template="/question/Interaction"
                model="[question: question, reponse: reponse, indexReponse: indexReponseNonVide]"/>

        <g:set var="indexReponseNonVide"
               value="${indexReponseNonVide.toInteger() + 1}"/>

        <g:render
                template="/question/${question.type.code}/${question.type.code}Correction"
                model="[question: question]"/>

      </div>
    </g:if>
    <g:else>
      <div class="tdbase-sujet-edition-question-interaction correction_copie">
        <g:render
                template="/question/Preview"
                model="[question: question]"/>
      </div>
    </g:else>
  </g:else>

  </div> <!-- fermeture div class = tdbase-sujet-edition-question -->

</g:each>
<g:if test="${etaitDansUnExercice}">
</div>
</g:if>

</div>

</body>
</html>