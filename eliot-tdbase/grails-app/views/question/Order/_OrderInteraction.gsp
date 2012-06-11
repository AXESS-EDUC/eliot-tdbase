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

.draggableItem {
    float: left;
    margin: 0;
    border: solid 1px #FFD324;
    background: #FFF6BF;
    color: #817134;
    display: inline-block;
    height: 1em;
    width: 26em;
    padding: 0.5em 0.5em 0.5em 0.5em;
    text-decoration: none;
}

.dropTarget {
    float: left;
    margin: 0;
    border: solid 1px #808080;
    background: #f5f5f5;
    display: inline-block;
    height: 2em;
    width: 28em;
    padding: 0.5em 0.5em 0.5em 0.5em;
}

</style>

<r:require module="orderJS"/>
<g:set var="questionspecifobject" value="${question.specificationObject}"/>
<g:set var="reponsespecifobject" value="${reponse?.specificationObject}"/>


<p class="title"><strong>${questionspecifobject.libelle}</strong></p>

<div id="orderQuestionContainment_${indexReponse}">
    <table>

        <g:if test="${reponsespecifobject.hasValeursDeResponses()}">
            <g:set var="items" value="${reponsespecifobject.valeursDeReponse}"/>
        </g:if>

        <g:else>
            <g:set var="items" value="${questionspecifobject.shuffledItems}"/>
        </g:else>


        <g:each status="i" in="${items}" var="orderedItem">

            <tr>
                <td id="dropTarget${indexReponse}_${i}" class="dropTarget">

                    <div id="orderedItem${indexReponse}_${i}" class="orderedItemCell">
                        <g:hiddenField id="orderedItem${indexReponse}_${i}_text"
                                       name="reponsesCopie.listeReponses[${indexReponse}].specificationObject.valeursDeReponse[${i}].text"
                                       value="${orderedItem.text}"/>

                        <span>${orderedItem.text}</span>

                        <g:set var="ordinalValue" value="${reponsespecifobject?.valeursDeReponse?.getAt(i)?.ordinal?:i+1}"/>

                        <g:select class="ordinalSelector"
                                  name="reponsesCopie.listeReponses[${indexReponse}].specificationObject.valeursDeReponse[${i}].ordinal"
                                  from="${questionspecifobject.selectableOrdinalList}"
                                  value="${ordinalValue}"
                        />
                    </div>
                </td>
            </tr>
        </g:each>
    </table>
</div>
