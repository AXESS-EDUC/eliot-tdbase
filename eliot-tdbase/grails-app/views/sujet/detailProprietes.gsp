%<%@ page import="org.lilie.services.eliot.tdbase.SujetType" %>
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
  <r:require modules="eliot-tdbase-ui"/>
  <r:script>
    $(document).ready(function () {
      $('#menu-item-sujets').addClass('actif');
      initButtons();
    });
  </r:script>
  <title><g:message code="sujet.editeProprietes.head.title"/></title>
</head>

<body>
<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>

<div class="portal-tabs">
  <span class="portal-tabs-famille-liens">
    <g:if test="${artefactHelper.utilisateurPeutModifierArtefact(utilisateur, sujet)}">
      <g:link action="edite" controller="sujet" class="modify"
              id="${sujet.id}" params="[bcInit: true]">Modifier le sujet</g:link> |
      <g:link action="editeProprietes" controller="sujet" class="modify"
              id="${sujet.id}" params="[bcInit: true]">Modifier les propriétés du sujet</g:link>
    </g:if>
    <g:else>
      <span class="add">Modifier le sujet</span> |
      <span class="modify">Modifier les propriétés du sujet</span>
    </g:else>
  </span>
  <span class="portal-tabs-famille-liens">
    <button id="toolbar_${sujet.id}">Actions</button>
    <ul id="menu_actions_toolbar_${sujet.id}"
        class="tdbase-menu-actions">
      <li><g:link action="ajouteSeance" id="${sujet.id}">
        Nouvelle&nbsp;séance
      </g:link>
      </li>
      <li><hr/></li>
      <g:if test="${artefactHelper.utilisateurPeutDupliquerArtefact(utilisateur, sujet)}">
        <li><g:link action="duplique"
                    id="${sujet.id}">Dupliquer</g:link></li>
      </g:if>
      <g:else>
        <li>Dupliquer</li>
      </g:else>
      <li><hr/></li>
      <g:if test="${artefactHelper.utilisateurPeutPartageArtefact(utilisateur, sujet)}">
        <li><g:link action="partage"
                    id="${sujet.id}">Partager</g:link></li>
      </g:if>
      <g:else>
        <li>Partager</li>
      </g:else>
      <g:if test="${artefactHelper.utilisateurPeutExporterArtefact(utilisateur, sujet)}">
        <li><g:link action="exporter" id="${sujet.id}">Exporter</g:link></li>
      </g:if>
      <g:else>
        <li>Exporter</li>
      </g:else>
      <li><hr/></li>
      <g:if test="${artefactHelper.utilisateurPeutSupprimerArtefact(utilisateur, sujet)}">
        <li><g:link action="supprime"
                    id="${sujet.id}">Supprimer</g:link></li>
      </g:if>
      <g:else>
        <li>Supprimer</li>
      </g:else>
    </ul>
  </span>
</div>
<g:if test="${flash.messageCode}">
  <div class="portal-messages">
    <li class="success"><g:message code="${flash.messageCode}"
                                   class="portal-messages success"/></li>
  </div>
</g:if>

<div class="portal-form_container edite">
  <table>
    <tr>
      <td class="label title">Titre&nbsp;:</td>
      <td>
        ${sujet.titre}
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td class="label">Type&nbsp;:</td>
      <td>
        ${sujet.sujetType.nom}
      </td>
    </tr>
    <tr>
      <td class="label">Mati&egrave;re&nbsp;:</td>
      <td>
        ${sujet.matiere?.libelleLong}
      </td>
    </tr>
    <tr>
      <td class="label">Niveau&nbsp;:</td>
      <td>
        ${sujet.niveau?.libelleLong}
      </td>
    </tr>
    <tr>
      <td class="label">Dur&eacute;e&nbsp;:</td>
      <td>
        ${sujet.dureeMinutes}
        (en minutes)
      </td>
    </tr>

    <tr>
      <td class="label">Ordre&nbsp;questions&nbsp;:</td>
      <td>
        <g:checkBox name="ordreQuestionsAleatoire"
                    checked="${sujet.ordreQuestionsAleatoire}" disabled="true"/>
        Al&eacute;atoire</td>
    </tr>

    <tr>
      <td class="label">Description&nbsp;:</td>
      <td>
        ${sujet.presentation}
      </td>
    </tr>
    <tr>
      <td class="label">Partage :</td>
      <td>
        <g:if test="${sujet.estPartage()}">
          <a href="${sujet.copyrightsType.lien}"
             target="_blank">${sujet.copyrightsType.presentation}</a>
        </g:if>
        <g:else>
          ce sujet n'est pas partagé
        </g:else>
      </td>
    </tr>
    <g:if test="${sujet.paternite}">
      <g:render template="/artefact/paternite"
                model="[paternite: sujet.paternite]"/>
    </g:if>
  </table>
</div>

</body>
</html>