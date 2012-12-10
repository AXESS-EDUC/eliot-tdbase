<%@ page import="org.lilie.services.eliot.tice.Dimension" %>
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
<r:require module="graphicMatch_DetailsJS"/>
<g:set var="specifobject" value="${question.specificationObject}"/>


<tr>
    <td class="label">Détail&nbsp;:</td>
    <td class="detail">

        <strong>${specifobject.libelle}</strong>
        <br/>

        <div class="imageContainer" style="width: 250px">
            <g:if test="${specifobject.attachement}">
                <et:viewAttachement attachement="${specifobject.attachement}"
                                    width="250" height="250"/>

              <g:set var="dimDisplayedAttachement"
                                value="${specifobject.attachement.calculeDimensionRendu(new Dimension(largeur: 250, hauteur: 250))}"/>
                         <g:set var="ratio"
                                value="${dimDisplayedAttachement.hauteur / specifobject.attachement.dimension.hauteur }"/>

              <ul class="hotspots">
                              <g:each status="i" in="${specifobject.hotspots}" var="hotspot">
                                  <li topDistance="${hotspot.topDistance* (Math.max(0.5, ratio))}"
                                      leftDistance="${hotspot.leftDistance* (Math.max(0.5, ratio))}"
                                      hotspotId="${hotspot.id}"
                                      width="${hotspot.width*(Math.max(0.5, ratio))}"
                                      height="${hotspot.height*(Math.max(0.5, ratio))}">
                                  </li>
                              </g:each>
                          </ul>

            </g:if>



            <div class="icons" style="width: 250px;">
                <g:each status="i" in="${specifobject.icons}" var="icon">

                    <g:if test="${icon.attachment}">
                        <div class="icon">
                            <et:viewAttachement attachement="${icon.attachment}"
                                                width="20" height="20"/>
                            <br>
                            avec Zone ${specifobject.graphicMatches[icon.id]}
                        </div>
                    </g:if>
                </g:each>
            </div>
        </div>
        <strong><g:message code="question.label.complement_reponse" />&nbsp;:</strong><br/> ${specifobject.correction}
    </td>
</tr>
