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
  <meta name="layout" content="eliot-tdbase-activite"/>
  <g:if test="${copie.estModifiable()}">
    <r:require module="copieEdite_CopieModifiable"/>
  </g:if>
  <g:else>
    <r:require module="copieEdite_CopieNonModifiable"/>
  </g:else>

  <title><g:message code="activite.copie.edite.head.title"/></title>
</head>

<body>

<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>

<g:hasErrors bean="${copie}">
  <div class="portal-messages">
    <g:eachError>
      <li class="error"><g:message error="${it}"/></li>
    </g:eachError>
  </div>
</g:hasErrors>
<g:if test="${request.messageCode}">
  <div class="portal-messages">
    <li class="success"><g:message code="${request.messageCode}"/></li>
  </div>
</g:if>
<g:set var="sujet" value="${copie.sujet}"/>
<g:if test="${copie.modaliteActivite.estPerimee()}">
  <div class="portal-form_container">
    <table>
      <tr>
        <td class="label">Élève :</td>
        <td><strong>${copie.eleve.nomAffichage}</strong></td>
      </tr>

      <tr>
        <td class="label">Appréciation :</td>
        <td>
          ${copie.correctionAnnotation}
        </td>
      </tr>
      <tr>
        <td class="label">Modulation :</td>
        <td>
          ${NumberUtils.formatFloat(copie.pointsModulation)}
        </td>
      </tr>
      <tr>
        <td class="label">Note :</td>
        <td>
          <strong>${NumberUtils.formatFloat(copie.correctionNoteFinale)}
            / ${NumberUtils.formatFloat(copie.maxPoints)}</strong>
        </td>
      </tr>
    </table>
  </div>
</g:if>
<g:if test="${copie.modaliteActivite.estOuverte()}">
  <ul>

    <div class="portal-messages">
      <li class="notice">
        Date dernier enregistrement : <span
              id="date_enregistrement">${copie.dateEnregistrement?.format(message(code:'default.date.format'))}</span>
        <g:if test="${copie.dateRemise}">
          &nbsp;&nbsp;   &nbsp;&nbsp;
          Note (correction automatique) :
          <strong><g:formatNumber number="${copie.correctionNoteAutomatique}"
                                  format="##0.00"/></strong>
          / <g:formatNumber number="${copie.maxPoints}" format="##0.00"/>
          &nbsp;&nbsp;   &nbsp;&nbsp;(copie remise le ${copie.dateRemise.format('dd/MM/yy  à HH:mm')})

        </g:if>
      </li>
    </div>

    <g:if test="${!copie.estModifiable()}">
      <div class="portal-messages">
        <li class="notice">
          <strong>La copie n'est plus modifiable.</strong>
        </li>
      </div>
    </g:if>
  </ul>
</g:if>

<g:render template="/copie/edite"
          model="[copie: copie, afficheCorrection: copie.modaliteActivite.estPerimee()]"/>

</body>
</html>