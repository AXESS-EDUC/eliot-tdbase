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



<div class="widget items">
  <h1><g:link action="recherche" controller="question" params="[patternAuteur: message(code: 'eliot.label.me')]">${titre}</g:link></h1>
  <g:if test="${items}">
  <p class="nb_result">${items.totalCount} item(s)
  	<g:if test="${items.totalCount>5}">
  		/ <g:link action="recherche" controller="question" params="[patternAuteur: message(code: 'eliot.label.me')]">Voir tous</g:link>
  	</g:if>
  </p>
  <div class="innertube">
	  <ul>
	    <g:each in="${items}" status="i" var="item">
	      <li class="${(i % 2) == 0 ? 'even' : 'odd'}"><g:link controller="question" title="${item.titre}" action="detail" id="${item.id}">${item.titre}</g:link><br/>
	      	<em>(${item.type.nom})</em><br/>
	        <g:if test="${item.niveau?.libelleLong}"><strong>» Niveau : </strong>${item.niveau?.libelleLong} </g:if>
	        <g:if test="${item.matiere?.libelleLong}"><strong>» Matière : </strong>${item.matiere?.libelleLong} </g:if>
	      </li>
	    </g:each>
	  </ul>
	  </div>
	  </g:if>
	  <g:else>
	  	<p class="nb_result">${items.totalCount} item(s)</p>
	  	<p class="none">Aucun items.</p>
	  </g:else>
	  
	  <g:link controller="question" class="add" action="nouvelle">Créer un item</g:link></div>
 
	     

