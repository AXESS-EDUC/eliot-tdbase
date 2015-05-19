<%@ page import="org.lilie.services.eliot.tice.scolarite.FonctionEnum; org.lilie.services.eliot.tice.scolarite.Fonction; org.lilie.services.eliot.tdbase.RechercheContributeurCommand; org.lilie.services.eliot.tdbase.SujetType" %>
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
    <title><g:message code="sujet.editeProprietes.head.title"/></title>
</head>

<body>
<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>

<g:hasErrors bean="${sujet}">
    <div class="portal-messages">
        <g:eachError>
            <li class="error"><g:message error="${it}"/></li>
        </g:eachError>
    </div>
</g:hasErrors>

<div class="portal-form_container edite apercu">
    <h1>${sujet.titre}</h1>

  <table>
    <tr>
      <td class="label">Titre&nbsp;:</td>
      <td>
        ${sujet.titre}
      </td>
    </tr>
    <tr>
      <td class="label">Propriétaire&nbsp;:</td>
      <td>
        ${sujet.proprietaire.nomAffichage}
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td class="label">Type&nbsp;:</td>
      <td>
        ${sujet.sujetType?.nom}
      </td>
    </tr>
    <tr>
      <td class="label">Mati&egrave;re&nbsp;:</td>
      <td>
        ${sujet.matiereBcn?.libelleEdition}
      </td>
    </tr>
    <tr>
      <td class="label">Niveau&nbsp;:</td>
      <td>
        ${sujet.niveau?.libelleLong}
      </td>
    </tr>
    <tr>
      <td class="label">Travail collaboratif&nbsp;:</td>
      <td>
        <div id="contributeurList">
          <g:if test="${sujet.contributeurs?.isEmpty()}">
            Aucun contributeur
          </g:if>
          <g:else>
            <ul>
              <g:each in="${sujet.contributeurs}" var="contributeur">
                <li>${contributeur.nomAffichage}</li>
              </g:each>
            </ul>
          </g:else>
        </div>
        <br/>&nbsp;
      </td>
    </tr>
    <tr>
      <td class="label">Dur&eacute;e&nbsp;:</td>
      <td>
        ${sujet.dureeMinutes} (en minutes)
      </td>
    </tr>

    <tr>
      <td class="label">Ordre&nbsp;questions&nbsp;:</td>
      <td>
        <g:if test="${sujet.ordreQuestionsAleatoire}">
          Al&eacute;atoire
        </g:if>
      </td>
    </tr>

    <tr>
      <td class="label">Description&nbsp;:</td>
      <td>
        <p>${sujet.presentation}</p>
      </td>
    </tr>
    <g:if test="${artefactHelper.partageArtefactCCActive}">
      <tr>
        <td class="label">Partage :</td>
        <td>
          <g:if test="${sujet.estPartage()}">
            <a href="${sujet.copyrightsType.lien}"
               target="_blank"><img src="${sujet.copyrightsType.logo}"
                                    title="${sujet.copyrightsType.code}"
                                    style="float: left;margin-right: 10px;"/> ${sujet.copyrightsType.presentation}
            </a>
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
    </g:if>
    </table>
</div>

</body>
</html>