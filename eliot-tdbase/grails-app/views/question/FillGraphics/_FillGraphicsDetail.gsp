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

<r:require module="fillGraphics_Common"/>
<g:set var="specifobject" value="${question.specificationObject}"/>

<tr>
    <td class="label">Détail&nbsp;:</td>

    <td class="detail">
        <strong><g:message code="question.propriete.libelle"/></strong>
        <p>${specifobject.libelle} </p>

        <div class="fillgraphicsEditor" style="width: 250px; height: 250px;">
            <g:if test="${specifobject.attachmentId}">
                <div class="imageContainer">
                    <et:viewAttachement
                            attachement="${specifobject.attachement}"
                            width="250"
                            height="250"/>
                </div>
            </g:if>

            <g:each status="i" in="${specifobject.textZones}" var="textZone">
                <div id="textZone_${i}" class="textZone"
                     style=" top: ${textZone.topDistance/2}px; left: ${textZone.leftDistance/2}px;">
                    <g:textArea name="specifobject.textZones[${i}].text" rows="3" cols="3"
                                style="font-size: 0.5em; width: ${textZone.width/2}px; height: ${textZone.height/2}px;"
                                value="${textZone.text}" readonly="true" class="nonResizableTextArea"/>
                </div>
            </g:each>
        </div>

        <strong>Correction :</strong> 
        <p>${specifobject.correction}</p>
    </td>
</tr>