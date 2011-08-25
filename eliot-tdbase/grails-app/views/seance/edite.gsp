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
  <g:javascript src="jquery/jquery-1.6.1.min.js"/>
  <g:javascript src="eliot/tiny_mce/tiny_mce.js"/>

  <r:script>
    $(document).ready(function() {
      $('#menu-item-seances').addClass('actif');
    });
  </r:script>

  <title>TDBase - Edition d'une séance</title>
</head>

<body>

<div class="column span-22 last middle">
  <g:render template="/breadcrumps" model="[liens: liens]"/>

  <g:hasErrors bean="${modaliteActivite}">
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


  <form method="post" id="form_question_edit">
    <div class="portal-form_container" style="width: 70%;margin-left: 15px;">
      <table>

        <tr>
          <td class="label">Service&nbsp;:</td>
          <td>
            <g:select name="service.id" value="${modaliteActivite.service?.id}"
                      noSelection="${['null':'Sélectionner un service...']}"
                      from="${services}"
                      optionKey="id"
                      optionValue="libelle"/>
          </td>
        </tr>
        <tr>
          <td class="label">Sujet&nbsp;:</td>
          <td>
            <g:if test="${modaliteActivite.sujet}">
            ${modaliteActivite.sujet.titre} &nbsp;&nbsp;&nbsp;
            </g:if>
            rechercher un sujet...
          </td>
        </tr>
        <tr>
          <td class="label">Début&nbsp;:</td>
          <td>
            <g:datePicker name="dateDebut" value="${modaliteActivite.dateDebut}"/>
          </td>
        </tr>
        <tr>
          <td class="label">Fin&nbsp;:</td>
          <td>
            <g:datePicker name="dateFin" value="${modaliteActivite.dateDebut}"/>
          </td>
        </tr>
        <tr>
          <td class="label">Remise&nbsp;des&nbsp;réponses&nbsp;:</td>
          <td>
            <g:datePicker name="dateRemiseReponses" value="${modaliteActivite.dateRemiseReponses}"/>
          </td>
        </tr>

        <tr>
          <td class="label">Copie&nbsp;améliorable&nbsp;:</td>
          <td>
            <g:checkBox name="copieAmeliorable" title="améliorable"
                        checked="${modaliteActivite.copieAmeliorable}"/>
          </td>
        </tr>
      </table>
    </div>
    <g:hiddenField name="id" value="${modaliteActivite.id}"/>
    <div class="form_actions" style="width: 70%;margin-left: 15px;">
      <g:link action="${lienRetour.action}"
              controller="${lienRetour.controller}"
              params="${lienRetour.params}">Annuler</g:link> |
        <g:actionSubmit value="Enregistrer"
                        action="enregistre"
                        controller="seance"
                        title="Enregistrer"/>
    </div>
  </form>
</div>

</body>
</html>