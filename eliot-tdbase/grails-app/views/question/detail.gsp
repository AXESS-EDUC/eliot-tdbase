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
    $(document).ready(function () {
      $('#menu-item-contributions').addClass('actif');
    });
  </r:script>
  <title>TDBase - Détail d'un item</title>
</head>

<body>

<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>

<g:if test="${sujet == null}">
  <div class="portal-tabs">

    <span class="portal-tabs-famille-liens">
      <g:if test="${peutModifierQuestion}">
        <g:link action="edite" class="modify"
                id="${question.id}">Modifer l'item</g:link>&nbsp; |
      </g:if>
      <g:else>
        Modifier l'item&nbsp;| &nbsp;
      </g:else>
      <g:if test="${peutPartagerQuestion}">
        <g:link action="partage" class="share"
                id="${question.id}">Partager l'item</g:link> |
      </g:if>
      <g:else>
        Partager l'item | &nbsp;
      </g:else>
      Exporter l'item | &nbsp;
    </span>

    <span class="portal-tabs-famille-liens">
      <g:if test="${peutSupprimer}">
        <g:link action="supprime" class="delete"
                id="${question.id}">Supprimer</g:link>
      </g:if>
      <g:else>
        Supprimer
      </g:else>
    </span>

  </div>
</g:if>

<g:if test="${request.messageCode}">
  <div class="portal-messages">
    <li class="success"><g:message code="${request.messageCode}"/></li>
  </div>
</g:if>

<g:if test="${sujet}">
  <g:render template="/sujet/listeElements" model="[sujet: sujet]"/>
</g:if>


<div class="portal-form_container edite apercu">
  <g:render template="/question/detail_commun"
            model="[question: question]"/>

</div>

<div class="form_actions edite">
  <g:link action="${lienRetour.action}" class="button"
          controller="${lienRetour.controller}"
          params="${lienRetour.params}">Retour</g:link>&nbsp;
  <g:if test="${sujet && afficheLienInserer}">|
    <g:link action="insert"
            title="Insérer dans le sujet" id="${question.id}"
            params="[sujetId: sujet?.id]">
      Insérer dans le sujet &nbsp;
    </g:link>
  </g:if>
  <br/><br/><br/><br/><br/><br/>
</div>

</body>
</html>