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

<style type="text/css">

.participant {
  float: left;
  margin: 0 2px 0 2px;
  border: solid 1px #FFD324;
  background: #FFF6BF;
  color: #817134;
  display: inline-block;
  height: 1em;
  padding: 0.5em 0.5em 0.5em 0.5em;
  text-decoration: none;
}

.associationCell {
  float: left;
  margin: 5px 5px 5px 5px;
  border: solid 1px #808080;
  background: #f5f5f5;
  display: inline-block;
  height: 1.5em;
  width: 17em;
  padding: 0.5em 0.5em 0.5em 0.5em;
}

.highlighted {
  background: #b5bdff;
}

</style>

<r:require module="modernizr"/>
<r:script disposition="head">
  Modernizr.load({
            test: Modernizr.touch,
            yep:"${r.resource(uri: '/static/dragNDrop.js')}",
            nope:"${r.resource(uri: '/static/dragNDrop.polyfill.js')}"

          });
</r:script>


<g:set var="specifobject" value="${question.specificationObject}"/>

<tr>
  <td class="label">Lib&eacute;ll&eacute;:</td>
  <td>
    <g:textField name="specifobject.libelle" value="${specifobject.libelle}"
                 size="75"/>
  </td>
</tr>
<tr>
  <td class="label">R&eacute;ponse:</td>
  <td>
    <g:hiddenField name="specifobject.attachmentId"
                   value="${specifobject.attachmentId}"/>

    <g:if test="${specifobject.attachmentId}">
      <et:viewAttachement
              attachement="${specifobject.attachement}"/>
      <br>
    </g:if>

    <input type="file" name="specifobject.fichier"
           onchange="$('#imageUpload').trigger('click');"/>

    <g:actionSubmit value="upload" action="enregistre" title="Upload"
                    hidden="true"
                    id="imageUpload"/>

    <table>
      <tr>
        <td id="textfields">
          <g:render
                  template="/question/GraphicMatch/GraphicMatchEditionReponses"
                  model="[specifobject:specifobject]"/>
        </td>
        <td style="vertical-align: bottom;">
          <g:submitToRemote title="Ajouter une textfield" value="Ajouter"
                            action="ajouteTextField"
                            controller="questionGraphicMatch"
                            update="textfields"
                            after="afterTextFieldAdded();"/>

          <g:submitToRemote value="Suppr" title="Supprimer le textField"
                            action="supprimeTextField"
                            controller="questionGraphicMatch"
                            update="textfields"
                            after="afterTextfieldDeleted();"/>
          <br/>

        </td>
      </tr>
    </table>

  </td>
</tr>
<tr>
  <td class="label">Correction:</td>
  <td>
    <g:textArea
            name="specifobject.correction"
            rows="10" cols="55"
            value="${specifobject.correction}"/>
  </td>
</tr>