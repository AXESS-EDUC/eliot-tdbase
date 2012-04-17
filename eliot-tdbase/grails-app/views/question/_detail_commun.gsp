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
<h1>${question.titre}</h1>
<table><tr>
  <td style="width: 60%; vertical-align: top;">
    <table>
      <tr>
        <td class="label">Type&nbsp;:</td>
        <td>
          ${question.type.nom}
        </td>
      </tr>
      <g:render
              template="/question/${question.type.code}/${question.type.code}Detail"
              model="[question: question]"/>

    </table>
  </td>
  <td style="width: 40%; vertical-align: top;">
    <table>
      <tr>
        <td class="label"><g:message code="question.propriete.principalAttachement"/>&nbsp;:</td>
        <td>
          <g:if test="${question.principalAttachement}">
            <g:link action="viewAttachement" controller="attachement"
                    id="${question.principalAttachement.id}" target="_blank">
              ${question.principalAttachement.nomFichierOriginal}
            </g:link>
            <br/>
          </g:if>
        </td>
      </tr>
      <tr>
        <td class="label">Titre&nbsp;:</td>
        <td>
          ${question.titre}
        </td>
      </tr>
      <tr>
        <td class="label">Auteur&nbsp;:</td>
        <td>
          ${question.proprietaire.prenom} ${question.proprietaire.nom}
        </td>
      </tr>
      <tr>
        <td class="label">Type&nbsp;:</td>
        <td>
          ${question.type.nom}
        </td>
      </tr>

      <tr>
        <td class="label">Mati&egrave;re&nbsp;:</td>
        <td>
          ${question.matiere?.libelleLong}
        </td>
      </tr>
      <tr>
        <td class="label">Niveau&nbsp;:</td>
        <td>
          ${question.niveau?.libelleLong}
        </td>
      </tr>

      <tr>
        <td class="label">Partage&nbsp;:</td>
        <td>
          <g:if test="${question.estPartage()}">
            <a href="${question.copyrightsType.lien}"
               target="_blank">${question.copyrightsType.presentation}</a>
          </g:if>
          <g:else>
            cette question n'est pas partagée
          </g:else>
        </td>
      </tr>
      <g:if test="${question.paternite}">
        <g:render template="/artefact/paternite"
                  model="[paternite: question.paternite]"/>
      </g:if>
    </table>
  </td>
</tr></table>
