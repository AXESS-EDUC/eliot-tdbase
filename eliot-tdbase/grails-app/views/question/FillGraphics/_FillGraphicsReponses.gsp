<%@ page import="grails.converters.JSON" %>
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

<g:if test="${specifobject.attachmentId}">
  <div id="imageContainer"
       style="position: absolute; top: 0; left: 0;">
    <et:viewAttachement
            attachement="${specifobject.attachement}"
            width="500"
            height="500"/>
  </div>
</g:if>

<g:each status="i" in="${specifobject.textZones}" var="textZone">
  <div id="textZone_${i}" class="textZone"
       style="z-index: 1; position: absolute; top: 30; left: 30;">
    <div>
      <g:submitToRemote id="${i}"
                        name="textZoneSupressButton"
                        title="Supprimer une zone de text"
                        value="X"
                        action="supprimeTextZone"
                        controller="questionFillGraphics"
                        update="fillgraphicsEditor"/>
    </div>

    <div>
      <g:textArea name="specifobject.textZones[${i}].text" rows="3" cols="10"
                  value="${textZone.text}"/>
    </div>

    <g:hiddenField class="idField" name="specifobject.textZones[${i}].id"
                   value="${textZone.id}"/>
  </div>
</g:each>

<g:hiddenField name="specifobject.textZones.size"
               value="${specifobject.textZones?.size()}"/>