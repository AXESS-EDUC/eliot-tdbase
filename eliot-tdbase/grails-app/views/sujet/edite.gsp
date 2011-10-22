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
  <r:require module="eliot-tice-ui"/>
  <r:script>
    $(document).ready(function() {
      $('#menu-item-sujets').addClass('actif');

      $(".editinplace").editInPlace({
        url: "${g.createLink(controller: 'sujet', action: 'updatePoints')}"
      });

    });
  </r:script>
  <title>TDBase - Edition du sujet</title>
</head>

<body>

<div class="column span-22 last middle">
  <g:render template="/breadcrumps" plugin="eliot-tice-plugin" model="[liens: liens]"/>
  <g:if test="${sujetEnEdition}">
    <div class="portal-tabs">
      <span class="portal-tabs-famille-liens">
        <g:link action="ajouteElement" controller="sujet"
                id="${sujet.id}">Ajouter un élément</g:link> |
        <g:link action="editeProprietes" controller="sujet"
                id="${sujet.id}">Éditer les propriétés du sujet</g:link>
      </span>
      <span class="portal-tabs-famille-liens">
        Exporter | Partager
      </span>
      <span class="portal-tabs-famille-liens">
        Versions
      </span>
    </div>
  </g:if>
  <g:else>
    <div class="portal-tabs">
      <span class="portal-tabs-famille-liens">
        Ajouter un élément |
        Éditer les propriétés du sujet
      </span>
      <span class="portal-tabs-famille-liens">
        Exporter | Partager
      </span>
      <span class="portal-tabs-famille-liens">
        Versions
      </span>
    </div>
  </g:else>
  <g:hasErrors bean="${sujet}">
    <div class="portal-messages error">
      <g:eachError>
        <li><g:message error="${it}"/></li>
      </g:eachError>
    </div>
  </g:hasErrors>
  <g:if test="${request.messageCode}">
    <div class="portal-messages success">
      <li><g:message code="${request.messageCode}"
                     class="portal-messages success"/></li>
    </div>
  </g:if>
  <form method="post">
    <div class="portal-form_container" style="width: 80%;border: none;">
      <table>
        <tr>
          <td class="label">
            titre&nbsp;:
          </td>
          <td>
            <g:textField name="sujetTitre" value="${titreSujet}" size="80"/>
          </td>
          <td>
            <g:actionSubmit action="enregistre" value="Enregistrer"/>
          </td>
        </tr>
      </table>

      <g:if test="${sujetEnEdition}">
        <g:hiddenField name="sujetId" value="${sujet.id}"/>
      </g:if>
    </div>
  </form>
  <g:if test="${sujet}">
    <g:each in="${sujet.questionsSequences}" var="sujetQuestion" status="indexQuestion">
      <div class="tdbase-sujet-edition-question">
        <div class="tdbase-sujet-edition-question-boutons">
          <g:link action="edite"
                  controller="question${sujetQuestion.question.type.code}"
                  id="${sujetQuestion.question.id}"
                  style="text-decoration: none;">
            <r:img uri="/images/eliot/write-btn.gif" style="border-style:solid;border-width:1px;border-color:#AAAAAA"
                alt="Modifier l'élément..."
                title="Modifier l'élément..."/>
          </g:link>
          <g:link action="remonteElement" controller="sujet"
                  id="${sujetQuestion.id}" style="text-decoration: none;">
            <img  src="/eliot-tdbase/images/eliot/24-em-up.png"
                 width="22"
                 height="18"
                 style="border-style:solid;border-width:1px;border-color:#AAAAAA"
                 alt="Déplacer vers le haut..."
                 title="Déplacer vers le haut..."/>
          </g:link>
          <g:link action="descendElement" controller="sujet"
                  id="${sujetQuestion.id}" style="text-decoration: none;">
            <img src="/eliot-tdbase/images/eliot/24-em-down.png"
                 width="22"
                 height="18"
                 style="border-style:solid;border-width:1px;border-color:#AAAAAA"
                 alt="Déplacer vers le bas..." title="Déplacer vers le bas..."/>
          </g:link>
          <g:link action="ajouteElement" controller="sujet"
                  id="${sujet.id}" params="[direction:'avant',
                                          rang: sujetQuestion.rang]">
            <img src="/eliot-tdbase/images/eliot/btnInsertRowBefore.png"
                 style="border-style:solid;border-width:1px;border-color:#AAAAAA"
                 alt="Insérer un élément avant..."
                 title="Insérer un élément avant..."/>
          </g:link>
          <g:link action="ajouteElement" controller="sujet"
                  id="${sujet.id}" params="[rang: sujetQuestion.rang]">
            <img src="/eliot-tdbase/images/eliot/btnInsertRowAfter.png"
                 style="border-style:solid;border-width:1px;border-color:#AAAAAA"
                 alt="Insérer un élément après..."
                 title="Insérer un élément après..."/>
          </g:link>
          <g:link action="supprimeFromSujet" controller="sujet"
                  id="${sujetQuestion.id}" style="text-decoration: none;">
            <img src="/eliot-tdbase/images/eliot/btnDeleteRow.png"
                 style="border-style:solid;border-width:1px;border-color:#AAAAAA"
                 alt="Supprimer l'élément du sujet..."
                 title="Supprimer l'élément du sujet..."/>
          </g:link>
        </div>
        <g:if test="${sujetQuestion.question.type.interaction}">
          <div class="tdbase-sujet-edition-question-points" style="margin-bottom: 15px">
          <div class="editinplace"
               id="SujetSequenceQuestions-${sujetQuestion.id}"
               title="Cliquez pour modifier le nombre de points..." style="float: left">
            ${sujetQuestion.points}
          </div>

            &nbsp;point(s)</div>
        </g:if>
        <div class="tdbase-sujet-edition-question-preview">
          <g:set var="question" value="${sujetQuestion.question}"/>
          <g:render
                  template="/question/${question.type.code}/${question.type.code}Preview"
                  model="[question:question, indexQuestion:indexQuestion]"/>
        </div>

      </div>

    </g:each>
  </g:if>
</div>

</body>
</html>