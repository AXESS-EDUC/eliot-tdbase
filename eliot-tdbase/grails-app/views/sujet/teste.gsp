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

<%@ page import="org.lilie.services.eliot.tdbase.importexport.Format; org.lilie.services.eliot.tice.CopyrightsType; org.lilie.services.eliot.tice.utils.NumberUtils" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta name="layout" content="eliot-tdbase"/>
    <g:if test="${copie.estModifiable()}">
        <r:require module="copieEdite_CopieModifiableEnTest"/>
    </g:if>
    <g:else>
        <r:require module="copieEdite_CopieNonModifiableEnTest"/>
    </g:else>

    <title><g:message code="sujet.teste.head.title"/></title>
</head>

<body>

<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>
<div class="portal-tabs">
  <g:render template="menuSujet"
            model="${[
                artefactHelper: artefactHelper,
                utilisateur: utilisateur,
                sujet : sujet,
                modeEdition: false
            ]}"/>


  <span class="portal-tabs-famille-liens">
    <button id="toolbar_${sujet.id}">Actions</button>
    <ul id="menu_actions_toolbar_${sujet.id}" class="tdbase-menu-actions">
      <g:render template="menuActions"
                model="${[
                    artefactHelper: artefactHelper,
                    sujet         : sujet,
                    utilisateur   : utilisateur,
                    copie         : copie
                ]}"/>
    </ul>
  </span>
</div>
<g:if test="${flash.errorMessage}">
  <div class="portal-messages">
    <li class="error"><g:message code="${flash.errorMessage}"/></li>
  </div>
</g:if>
<g:hasErrors bean="${copie}">
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

<g:if test="${flash.messageCode}">
    <div class="portal-messages">
        <li class="notice"><g:message code="${flash.messageCode}"/></li>
    </div>
</g:if>

<div class="portal-messages">
    <li class="notice">
        Date dernier enregistrement : <span
            id="date_enregistrement">${copie.dateEnregistrement?.format(message(code: 'default.date.format'))}</span>
        <g:if test="${copie.dateRemise}">
            &nbsp;&nbsp;   &nbsp;&nbsp;
         Note (correction automatique) :
            <g:formatNumber number="${copie.correctionNoteAutomatique}"
                            format="##0.00"/>
            / <g:formatNumber number="${copie.maxPoints}" format="##0.00"/>
            &nbsp;&nbsp;(copie remise le ${copie.dateRemise.format('dd/MM/yy  à HH:mm')})
        </g:if>
    </li>
</div>


<g:render template="/copie/edite"
          model="[copie: copie, afficheCorrection: afficheCorrection]"/>

<g:render template="../importexport/export_dialog"/>
</body>
</html>