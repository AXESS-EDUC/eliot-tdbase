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
<g:set var="questionspecifobject" value="${question.specificationObject}"/>
<g:set var="reponsespecifobject" value="${reponse?.specificationObject}"/>

<r:require module="eliot-tdbase-ui"/>
<r:script>
  $(document).ready( function() {
  		$( "#slider_${indexReponse}" ).slider({
  			value:${reponsespecifobject?.valeurReponse ? reponsespecifobject.valeurReponse : questionspecifobject.valeurMin},
  			min: ${questionspecifobject.valeurMin},
  			max: ${questionspecifobject.valeurMax},
  			step: ${questionspecifobject.pas},
  			slide: function( event, ui ) {
  			    var valeurSlide =   new String(ui.value).replace('.',',');
  				$( "#valeur_slider_${indexReponse}" ).val( valeurSlide );
  			}
  		});
  		var valeur = new String($( "#slider_${indexReponse}" ).slider( "value" ));
  		valeur = valeur. replace('.',',');
  		$( "#valeur_slider_${indexReponse}" ).val( valeur );
  	}

  );
</r:script>


<p class="title"><strong>${questionspecifobject.libelle}</strong></p>
<strong>Valeur :</strong><g:textField id="valeur_slider_${indexReponse}"
                                      name="reponsesCopie.listeReponses[${indexReponse}].specificationObject.valeurReponse"
                                      value="${reponsespecifobject?.valeurReponseAffichage}"
                                      size="10"/>

<div id="slider_${indexReponse}" style="width: 50%"></div>


