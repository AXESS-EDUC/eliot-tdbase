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
<r:require module="graphicMatch_InteractionJS"/>
<g:set var="specifobject" value="${question.specificationObject}"/>
<g:set var="reponsespecifobject" value="${reponse?.specificationObject}"/>
<p class="title"><strong>${specifobject.libelle}</strong></p>
<div class="imageContainer" qualifier="interaction" indexReponse="${indexReponse}" id="imageContainer_${indexReponse}">

  <g:if test="${specifobject.attachmentId}">
    <et:viewAttachement
            attachement="${specifobject.attachement}"
            width="${grailsApplication.config.eliot.graphicitems.dimension}"
            height="${grailsApplication.config.eliot.graphicitems.dimension}"/>
    <br>
  </g:if>

  <ul class="hotspots">
    <g:each status="i" in="${specifobject.hotspots}" var="hotspot">
      <li topDistance="${hotspot.topDistance}"
          leftDistance="${hotspot.leftDistance}"
          id="hotspot_interaction_${indexReponse}_${hotspot.id}"
          hotspotId="${hotspot.id}"
          width="${hotspot.width}"
          height="${hotspot.height}"
          class="hotspot">
      </li>
    </g:each>
  </ul>

  <div class="icons">
    <g:each status="i" in="${specifobject.icons}" var="icon">
      <g:if test="${icon.attachmentId}">
        <div id="icon_interaction_${indexReponse}_${icon.id}" class="icon">

          <et:viewAttachement attachement="${icon.attachment}"
                              width="${specifobject.getCorrespondingHotspot(icon.id).width-5}"
                              height="${specifobject.getCorrespondingHotspot(icon.id).height-5}"/>

          <g:select
                  id="icon_interaction_${indexReponse}_${icon.id}_graphicMatch"
                  class="hotspotSelector"
                  name="reponsesCopie.listeReponses[${indexReponse}].specificationObject.valeursDeReponse[${icon.id}]"
                  value="${reponsespecifobject?.valeursDeReponse.get(icon.id)}"
                  from="${specifobject.hotspots*.id}"
                  noSelection="['-1': 'Hotspot']"/>
        </div>
      </g:if>
    </g:each>
  </div>
</div>

<br>