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

<g:each status="i" in="${specifobject.hotspots}" var="hotspot">
  <div id="hotspot_${i}" class="hotspot">

    <g:submitToRemote id="${i}"
                      name="hotspotSupressButton"
                      title="Supprimer un hotspot"
                      value="X"
                      action="supprimeHotspot"
                      controller="questionGraphicMatch"
                      update="hotspotsEtIcons"
                      onComplete="afterHotspotDeleted()"/>

    <span class="hotspotLabel">Hotspot: ${hotspot.id}</span>
    <g:hiddenField class="idField" name="specifobject.hotspots[${i}].id"
                   value="${hotspot.id}"/>

    <span class="hotspotLabel">Top:</span>
    <g:textField class="offTop"
                 name="specifobject.hotspots[${i}].topDistance"
                 value="${hotspot.topDistance}" size="3"/>

    <span class="hotspotLabel">Left:</span>
    <g:textField class="offLeft"
                 name="specifobject.hotspots[${i}].leftDistance"
                 value="${hotspot.leftDistance}" size="3"/>
  </div>
</g:each>

<g:hiddenField name="specifobject.hotspots.size"
               value="${specifobject.hotspots?.size()}"/>

<ul>
  <g:each status="i" in="${specifobject.icons}" var="icon">
    <li class="editIcon">
      <strong>Hotspot ${specifobject.graphicMatches.getAt(icon.id)}:</strong>

      <g:if test="${icon.attachmentId}">
        <et:viewAttachement attachement="${icon.attachment}" width="40" height="40"/>
      </g:if>


      <g:actionSubmit value="upload" action="enregistreEtPoursuisEdition" hidden="true"
                      id="iconUpload${i}"/>

      <input type="file" name="specifobject.icons[${i}].fichier"
             onchange="$('#iconUpload${i}').trigger('click');"/>

      <g:hiddenField id="graphicMatch_${icon.id}"
                     name="specifobject.graphicMatches[${icon.id}]"
                     value="${specifobject.graphicMatches.getAt(icon.id)}"/>
      <g:hiddenField name="specifobject.icons[${i}].attachmentId"
                     value="${icon.attachmentId}"/>
      <g:hiddenField name="specifobject.icons[${i}].id"
                     value="${icon.id}"/>
    </li>
  </g:each>
</ul>

<g:hiddenField name="specifobject.icons.size"
               value="${specifobject.icons?.size()}"/>