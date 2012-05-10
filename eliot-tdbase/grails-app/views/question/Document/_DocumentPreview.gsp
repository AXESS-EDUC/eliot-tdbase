<%@ page import="org.lilie.services.eliot.tdbase.impl.document.DocumentTypeEnum" %>
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

<p class="title"><strong>${question.titre}</strong></p>
<strong>Auteur :</strong>${specifobject.auteur} <br/>
<strong>Source :</strong>${specifobject.source} <br/>
<g:if test="${specifobject.attachement}">
  <br/>
  <g:if test="${specifobject.estInsereDansLeSujet}">
    <g:if test="${specifobject.type == DocumentTypeEnum.JMOL.name}">
      <et:viewJmolAttachement attachement="${specifobject.attachement}"/>
    </g:if>
    <g:else>
      <et:viewAttachement attachement="${specifobject.attachement}"/>
    </g:else><br/>
  </g:if>
  <g:else>
    <g:if test="${specifobject.type == DocumentTypeEnum.JMOL.name}">
      <g:link action="viewJmolAttachement" controller="attachementCustom"
                    id="${specifobject.attachement.id}" target="_blank">
              <g:message code="attachement.acces"/>
            </g:link>
    </g:if>
    <g:else>
      <g:link action="viewAttachement" controller="attachement"
              id="${specifobject.attachement.id}" target="_blank">
        <g:message code="attachement.acces"/>
      </g:link>
    </g:else><br/>
  </g:else>
</g:if>
<g:if test="${specifobject.urlExterne}">
  <br/>
  <a href="${specifobject.urlExterne}" target="_blank">
    <g:message code="attachement.acces"/>
  </a> <br/>
</g:if>
<br/>



