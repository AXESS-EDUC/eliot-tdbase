%{--
  - Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
  - This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
  -
  -  Lilie is free software. You can redistribute it and/or modify since
  -  you respect the terms of either (at least one of the both license) :
  -  - under the terms of the GNU Affero General Public License as
  -  published by the Free Software Foundation, either version 3 of the
  -  License, or (at your option) any later version.
  -  - the CeCILL-C as published by CeCILL-C; either version 1 of the
  -  License, or any later version
  -
  -  There are special exceptions to the terms and conditions of the
  -  licenses as they are applied to this software. View the full text of
  -  the exception in file LICENSE.txt in the directory of this software
  -  distribution.
  -
  -  Lilie is distributed in the hope that it will be useful,
  -  but WITHOUT ANY WARRANTY; without even the implied warranty of
  -  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  -  Licenses for more details.
  -
  -  You should have received a copy of the GNU General Public License
  -  and the CeCILL-C along with Lilie. If not, see :
  -  <http://www.gnu.org/licenses/> and
  -  <http://www.cecill.info/licences.fr.html>.
  --}%



<div class="widget resultats">
  <h1><g:link action="listeResultats" controller="activite">${titre}</g:link></h1>
  <g:if test="${copies}">
  <p class="nb_result">${copies.totalCount} résultat(s)
  	<g:if test="${copies.totalCount>5}">
  		/ <g:link action="listeResultats" controller="activite">Voir tous</g:link>
  	</g:if>
  </p>
  <div class="innertube">
	  <ul>
	    <g:each in="${copies}" status="i" var="copie">
	      <g:set var="seance" value="${copie.modaliteActivite}"/>
	      <li class="${(i % 2) == 0 ? 'even' : 'odd'}"><g:link controller="activite" action="visualiseCopie" id="${copie.id}">
	      	<g:if test="{seance.matiere?.libelleLong} == ''">
	      		 
	      	</g:if>
	      	<g:else>
	      	     ${seance.matiere?.libelleLong} -
	      	</g:else>
	      	${seance.sujet.titre}</g:link><br/>
	        <strong> » Note : </strong><b><g:formatNumber number="${copie.correctionNoteFinale}" format="##0.00" /></b>
	        		  		/ <g:formatNumber number="${copie.maxPoints}" format="##0.00" />
	      </li>
	    </g:each>
	  </ul>
	  </div>
	  </g:if>
	  <g:else>
		  <p class="nb_result">${copies.totalCount} résultat(s)</p>
		  <p class="none">Aucun résultat n'est publié.</p>
	  </g:else>
	
</div>
