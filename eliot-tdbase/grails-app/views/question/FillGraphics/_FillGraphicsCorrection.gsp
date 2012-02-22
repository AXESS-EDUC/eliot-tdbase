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
<div class="item">
    <strong>Correction&nbsp;:</strong> <br/>

    <div class="fillgraphicsEditor">
        <g:if test="${specifobject.attachmentId}">
            <div class="imageContainer">
                <et:viewAttachement
                        attachement="${specifobject.attachement}"
                        width="500"
                        height="500"/>
            </div>
        </g:if>

        <g:each status="i" in="${specifobject.textZones}" var="textZone">
            <div id="textZone_${i}" class="textZone"
                 style=" top: ${textZone.topDistance}px; left: ${textZone.leftDistance}px;">
                <g:textArea name="specifobject.textZones[${i}].text" rows="3" cols="3"
                            style="width: ${textZone.width}px; height: ${textZone.height}px;"
                            value="${textZone.text}" readonly="true" class="nonResizableTextArea"/>
            </div>
        </g:each>
    </div>

    <br/>
    <strong>Remarque :</strong> ${specifobject.correction}
</div>
