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



<%--
  Created by IntelliJ IDEA.
  User: bert
  Date: 20/12/11
  Time: 17:47
  To change this template use File | Settings | File Templates.
--%>
<g:set var="specifobject" value="${question.specificationObject}"/>
<g:set var="reponsespecifobject" value="${reponse?.specificationObject}"/>

${specifobject.libelle} <br/>

<div id="image_frame">
  <g:if test="${specifobject.attachmentId}">
    <et:viewAttachement
            attachement="${specifobject.attachement}"
            width="500"
            height="500"/>
    <br>
  </g:if>

  <g:each status="i" in="${specifobject.hotspots}" var="hotspot">
    <div id="hotspot_${indexReponse}_${hotspot.id}" class="hotspot"
         topDistance="${hotspot.topDistance}"
         leftDistance="${hotspot.leftDistance}">
      ${hotspot.id}
    </div>
  </g:each>

  <g:each status="i" in="${specifobject.icons}" var="icon">
    <div id="icon_${indexReponse}_${icon.id}" class="icon">
      <et:viewAttachement attachement="${icon.attachment}" width="30"
                          height="30"/>

      <g:textField id="icon_${indexReponse}_${icon.id}_graphicMatch"
                   name="reponsesCopie.listeReponses[${indexReponse}].specificationObject.valeursDeReponse[${icon.id}]"
                   value="${reponsespecifobject?.valeursDeReponse.get(icon.id.toString())}"/>
    </div>
  </g:each>
</div>
<br>