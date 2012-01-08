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

  <input type="radio" name="selectedHotspot" value="${i}"/>

  Id:
  <g:textField name="specifobject.hotspots[${i}].id"
               value="${hotspot.id}" disabled="true"/>
  <g:hiddenField name="specifobject.hotspots[${i}].id"
                 value="${hotspot.id}"/>

  Top:
  <g:textField name="specifobject.hotspots[${i}].topDistance"
               value="${hotspot.topDistance}" size="3"/>
  Left:
  <g:textField name="specifobject.hotspots[${i}].leftDistance"
               value="${hotspot.leftDistance}" size="3"/>
  <br>
</g:each>

<g:hiddenField name="specifobject.hotspots.size"
               value="${specifobject.hotspots?.size()}"/>

<table>
  <g:each status="i" in="${specifobject.icons}" var="icon">
    <tr>
      <td>
        <g:submitToRemote id="${i}"
                          title="Supprimer un icon"
                          value="X"
                          action="supprimeIcon"
                          controller="questionGraphicMatch"
                          update="hotspotsEtIcons"/>
      </td>

      <td>
        <g:hiddenField name="specifobject.icons[${i}].id"
                       value="${icon.id}"/>

        <g:if test="${icon.id}">
          <et:viewAttachement attachement="${icon.attachment}" width="30"
                              height="30"/>
        </g:if>
      </td>
      <td>
        <input type="file" name="specifobject.icons[${i}].fichier"
               onchange="$('#iconUpload${i}').trigger('click');"/>

        <g:actionSubmit value="upload" action="enregistre" title="Upload"
                        hidden="true"
                        id="iconUpload${i}"/>
      </td>
      <td>
        <g:select name="specifobject.graphicMatches[${icon.id}]"
                  from="${specifobject.hotspots*.id}"
                  noSelection="['0': 'avec Hotspot...']"
                  value="${specifobject.graphicMatches[icon.id.toString()]}"/>
      </td>
    </tr>
  </g:each>
</table>

<g:hiddenField name="specifobject.icons.size"
               value="${specifobject.icons?.size()}"/>