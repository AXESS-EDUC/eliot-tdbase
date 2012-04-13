<%@ page import="org.lilie.services.eliot.tdbase.impl.document.DocumentTypeEnum; org.lilie.services.eliot.tdbase.QuestionAttachement; org.lilie.services.eliot.tdbase.impl.document.DocumentTypeEnum" %>
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
  <td class="label">Auteur<span class="obligatoire">*</span>&nbsp;:</td>
  <td>
    <input size="75" type="text" value="${specifobject.auteur}"
           name="specifobject.auteur"/>
  </td>
</tr>
<tr>
  <td class="label">Source<span class="obligatoire">*</span>&nbsp;:</td>
  <td>
    <input size="75" type="text" value="${specifobject.source}"
           name="specifobject.source"/>
  </td>
</tr>
<tr>
  <td class="label">Type&nbsp;:</td>
  <td>
    <g:select name="specifobject.type"
              from="${org.lilie.services.eliot.tdbase.impl.document.DocumentTypeEnum.values()}"
              value="${specifobject.type}"
              optionKey="name"
              optionValue="name"/>
  </td>
</tr>
<tr>
  <td class="label">URL externe<span class="obligatoire">*</span>&nbsp;:</td>
  <td>
    <input size="75" type="text" value="${specifobject.urlExterne}"
           name="specifobject.urlExterne"/>
  </td>
</tr>
<tr>
  <td class="label">OU</td>
  <td>&nbsp;</td>
</tr>
<tr>
  <td class="label">Fichier<span class="obligatoire">*</span>&nbsp;:</td>
  <td id="specifobject_fichier">
    <g:render template="/question/Document/DocumentEditionFichier"
              model="[specifobject:specifobject]"/>
  </td>
</tr>
<tr>
  <td class="label">Affichage&nbsp;:</td>
  <td>
    <g:checkBox name="specifobject.estInsereDansLeSujet"
                title="Le document est inséré dans le sujet"
                checked="${specifobject.estInsereDansLeSujet}"/>
    Le document est inséré dans le sujet
  </td>
</tr>
<tr>
  <td class="label">
    Présentation&nbsp;:
  </td>
  <td>
    <g:textArea
            name="specifobject.presentation"
            rows="4" cols="55"
            value="${specifobject.presentation}"/>
  </td>
</tr>
