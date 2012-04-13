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
<tr>
  <td class="label">
    <g:message code="question.propriete.libelle"/><span class="obligatoire">*</span>&nbsp;:
  </td>
  <td>
    <g:textArea
            name="specifobject.libelle"
            rows="3" cols="55"
            value="${specifobject.libelle}"
    />
  </td>
</tr>
<tr>
  <td class="label">
    R&eacute;ponses<span class="obligatoire">*</span>&nbsp;:
  </td>
  <td>
    <table>
      <tr>
        <td id="specifobject_reponses">
          <g:render template="/question/ExclusiveChoice/ExclusiveChoiceEditionReponses"
                    model="[specifobject:specifobject]"/>
        </td>
        <td style="vertical-align: bottom;">
          <g:submitToRemote title="Ajouter une réponse possible" value="Ajouter"
                            action="ajouteReponse"
                            controller="questionExclusiveChoice"
                            update="specifobject_reponses" class="button"/>
        </td>
      </tr>
    </table>
  </td>
</tr>
<tr>
    <td class="label">Présentation&nbsp;aléatoire&nbsp;:</td>
    <td><g:checkBox name="specifobject.shuffled"
                    checked="${specifobject.shuffled}"/></td>
</tr>
<tr>
  <td class="label">
    Correction&nbsp;:
  </td>
  <td>
     <g:textArea
            name="specifobject.correction"
            rows="3" cols="55"
            value="${specifobject.correction}"
    />
  </td>
</tr>