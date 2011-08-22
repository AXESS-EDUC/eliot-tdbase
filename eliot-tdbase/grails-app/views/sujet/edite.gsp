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
  <r:require modules="jquery"/>
  <r:script>
    $(document).ready(function() {
      $('#menu-item-sujets').addClass('actif');
    });
  </r:script>
  <title>TDBase - Edition du sujet</title>
</head>

<body>

<div class="column span-22 last middle">
  <g:render template="/breadcrumps" model="[liens: liens]"/>
  <g:if test="${sujetEnEdition}">
    <div class="portal-tabs">
      <span class="portal-tabs-famille-liens">
        <g:link action="ajouteElement"
                id="${sujet.id}">Ajouter un élément</g:link> |
        <g:link action="editeProprietes"
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
    <g:each in="${sujet.questionsSequences}" var="sujetQuestion">
      <div class="tdbase-sujet-edition-question">
        <div class="tdbase-sujet-edition-question-boutons">
          <a href="#">
            <img border="0" src="/eliot-tdbase/images/eliot/write-btn.gif"
                 width="18"
                 height="16"/>
          </a>
          <a href="#">
            <img border="0" src="/eliot-tdbase/images/eliot/ActionIconAdd.gif"
                 width="20" height="19"/>
          </a>
          <g:link action="supprimeFromSujet" controller="question" id="${sujetQuestion.id}" >
            <img border="0" src="/eliot-tdbase/images/eliot/trashcan-btn.gif"
                 width="14"
                 height="16"/>
          </g:link>
        </div>
        <div class="tdbase-sujet-edition-question-preview">
          <g:set var="question" value="${sujetQuestion.question}"/>
        <g:render
                template="/question/${question.type.code}/${question.type.code}Preview"
                model="[question:question]"/>
        </div>

      </div>

    </g:each>
  </g:if>
</div>

</body>
</html>