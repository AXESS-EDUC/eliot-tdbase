<%@ page import="org.lilie.services.eliot.tdbase.impl.document.DocumentTypeEnum; org.lilie.services.eliot.tdbase.QuestionAttachement" %>
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
<g:set var="specifobject" value="${question.specificationObject}"/>
<r:script>
  $('li').css('list-style', 'none');
</r:script>

<tr>
  <td class="label">Détail&nbsp;:</td>

  <td class="detail">
    <table>
      <tr>
        <td><strong>Auteur&nbsp;:</strong></td>
        <td>${specifobject.auteur}</td>
      </tr>
      <tr>
        <td><strong>Source&nbsp;:</strong></td>
        <td>${specifobject.source}</td>
      </tr>
      <tr>
        <td><strong>Type&nbsp;:</strong></td>
        <td>${specifobject.type}</td>
      </tr>
      <tr>
        <td><strong>URL&nbsp;externe&nbsp;:</strong></td>
        <td>
          <g:if test="${specifobject.urlExterne}">
            <a href="${specifobject.urlExterne}" target="_blank">
              ${specifobject.urlExterne}
            </a>
          </g:if>
        </td>
      </tr>
      <tr>
        <td><strong>Fichier&nbsp;:</strong></td>
        <td>
          <g:if test="${specifobject.questionAttachementId}">
            <g:set var="attachement"
                   value="${specifobject.attachement}"/>

            <g:if test="${specifobject.type == DocumentTypeEnum.JMOL.name}">
              <et:viewJmolAttachement attachement="${attachement}" width="200"/>
            </g:if>
            <g:else>
              <g:link action="viewAttachement" controller="attachement"
                      id="${attachement.id}" target="_blank">
                ${attachement.nomFichierOriginal}
              </g:link>
            </g:else>
            <br/>
          </g:if>
        </td>
      </tr>
      <tr>
        <td><strong>Affichage&nbsp;:</strong></td>
        <td>
          <g:checkBox name="specifobject.estInsereDansLeSujet"
                      title="Le document est inséré dans le sujet"
                      checked="${specifobject.estInsereDansLeSujet}"
                      disabled="true"/>
          Le document est inséré dans le sujet
        </td>
      </tr>
      <tr>
        <td><strong>Présentation&nbsp;:</strong></td>
        <td>${specifobject.presentation}</td>
      </tr>
    </table>
  </td>
</tr>

