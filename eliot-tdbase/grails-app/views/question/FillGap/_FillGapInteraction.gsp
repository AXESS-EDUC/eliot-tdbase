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
<r:require module="fillGap_InteractionJS"/>

<g:set var="questionspecifobject" value="${question.specificationObject}"/>
<g:set var="reponsespecifobject" value="${reponse?.specificationObject}"/>
<g:set var="index" value="0"/>

<p class="title"><strong>${questionspecifobject.libelle}</strong></p>

<div class="fillGapTextContainer" id="${indexReponse}">
    <br>

    <div class="gapText">

        <g:each in="${questionspecifobject.texteATrousStructure}" var="texteATrouElement" status="i">

            <g:if test="${texteATrouElement.isTextElement()}">
                <span class="textElement">${texteATrouElement.valeur}</span>
            </g:if>

            <g:else>
                <g:if test="${questionspecifobject.modeDeSaisie == 'MDR'}">
                    <span class="textElement">
                    <g:select
                            name="reponsesCopie.listeReponses[${indexReponse}].specificationObject.valeursDeReponse[${index}]"
                            from="${texteATrouElement.valeur*.text}"
                            value="${reponsespecifobject.valeursDeReponse[index.toInteger()]}"
                            noSelection="${['': g.message(code: "default.select.null")]}"/>
                    </span>
                </g:if>
                <g:else>
                    <span class="gapElement" id="gapElement_${indexReponse}_${i}">

                        <g:textField
                                class="gapField"
                                value="${reponsespecifobject.valeursDeReponse[index.toInteger()]}"
                                name="reponsesCopie.listeReponses[${indexReponse}].specificationObject.valeursDeReponse[${index}]"/>
                    </span>
                </g:else>
                <g:set var="index" value="${index.toInteger() + 1}"/>
            </g:else>
        </g:each>
    </div>
        <div class="gapWords" id="${indexReponse}" show="${questionspecifobject.modeDeSaisie == 'MLM'}">
            <br>
            <span class="label">Mots suggérés :</span>
            <div class="gapWordsList">
                <g:each in="${questionspecifobject.motsSugeres}" var="gapWord" status="i">
                    <div class="gapWord"
                        id="gapWord_${indexReponse}_${i}"
                        word="${gapWord}">
                        ${gapWord}
                    </div>
                </g:each>
            </div>
        </div>
    </div>