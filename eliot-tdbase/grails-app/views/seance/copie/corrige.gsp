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
  <r:require module="eliot-tdbase-ui"/>
  <r:script>
    $(document).ready(function() {
      $('#menu-item-seances').addClass('actif');
      $(':checkbox').attr('disabled', true);
      $('textarea').attr('disabled', true);
      $('.interaction').attr('disabled', true);
      $('#copieAnnotation').removeAttr('disabled');
      $(".editinplace").editInPlace({
              url: "${g.createLink(controller: 'seance', action: 'updateReponseNote')}"
            });

    });
  </r:script>
  <title>TDBase - Edition d'une copie</title>
</head>

<body>

<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>
<div class="portal_pagination">
  ${copies.totalCount} élève(s) <g:paginate total="${copies.totalCount}"
                                            id="${seance.id}"></g:paginate>
</div>
<g:set var="copie" value="${copies[0]}"/>
<g:hasErrors bean="${copieNotation}">
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
  <div class="portal-form_container">
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
                       value="${NumberUtils.formatFloat(copie.pointsModulation)}"/>
        </td>
      </tr>
      <tr>
        <td class="label">Note :</td>
        <td>
          <strong><g:formatNumber number="${copie.correctionNoteFinale}"
                                  format="##0.00"/>
            / <g:formatNumber number="${copie.maxPoints}"
                              format="##0.00"/></strong>
        </td>
      </tr>
    </table>
  </div>

  <div class="form_actions">
    <g:link action="${lienRetour.action}"
            controller="${lienRetour.controller}"
            params="${lienRetour.params}">Annuler</g:link>&nbsp;
    |&nbsp;
    <g:actionSubmit value="Enregistrer" action="enregistreCopie"
                    title="Enregistrer" id="${seance.id}"/>
  </div>
</form>

<h3 class="tdbase-sujet-titre">${sujet.titre}</h3>

<g:set var="indexReponse" value="0"/>
<g:each in="${sujet.questionsSequences}" var="sujetQuestion">
  <div class="tdbase-sujet-edition-question">
    <g:if test="${sujetQuestion.question.type.interaction}">
      <g:set var="reponse"
             value="${copie.getReponseForSujetQuestion(sujetQuestion)}"/>
      <div class="tdbase-sujet-edition-question-points"
           style="margin-bottom: 15px">
        <div id="SujetSequenceQuestions-${sujetQuestion.id}"
             style="float: left;width: 80px;">
          <g:if test="${reponse}">
            <g:if test="${reponse.estEnNotationManuelle()}">
              <div class="editinplace" id="${reponse.id}"
                   title="Cliquez pour modifier le nombre de points...">
                <g:formatNumber number="${reponse.correctionNoteCorrecteur}"
                                format="##0.00"/>
              </div>
            </g:if>
            <g:else>
              <g:formatNumber number="${reponse.correctionNoteAutomatique}"
                              format="##0.00"/>
            </g:else>
          </g:if>
          <g:else>
            <span title="L'élève a rendu sa copie après l'ajout de cette réponse">Non&nbsp;évaluable</span>
          </g:else>
        </div>
        &nbsp;/&nbsp;<g:formatNumber number="${sujetQuestion.points}"
                                     format="##0.00"/>&nbsp;point(s)
      </div>
    </g:if>


    <g:set var="question" value="${sujetQuestion.question}"/>
    <div class="tdbase-sujet-edition-question-interaction">
      <g:if test="${question.type.interaction}">
        <g:render
                template="/question/${question.type.code}/${question.type.code}Interaction"
                model="[question: question, reponse: reponse, indexReponse: indexReponse++]"/>

        <g:render
                template="/question/${question.type.code}/${question.type.code}Correction"
                model="[question: question]"/>

      </g:if>
      <g:else>
        <g:render
                template="/question/${question.type.code}/${question.type.code}Preview"
                model="[question: question]"/>
      </g:else>
    </div>
  </div>
</g:each>

</body>
</html>