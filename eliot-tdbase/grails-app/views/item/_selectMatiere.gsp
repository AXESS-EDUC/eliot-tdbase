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

<g:form action="rechercheMatieres" controller="item">
    <div class="portal-form_container recherche" style="width: 100%">
      <table>
        <tr>
          <td class="label">
            Rechercher
          </td>
          <td>
            <g:textField name="patternCode" title="motif"
                         value="${rechercheMatieresCommand.patternCode}"/>
          </td>
          </tr>
        <tr>
          <td class="label">dans&nbsp;
          </td>
          <td>
            <g:select name="etablissementId" value="${rechercheMatieresCommand.etablissementId}"
                      noSelection="${['null': 'Tous les établissements']}"
                      from="${etablissements}"
                      optionKey="id"
                      optionValue="nomAffichage"/>
          </td>
        </tr>
      </table>
    </div>

    <div class="form_actions recherche" style="width: 100%">
      <g:submitToRemote value="Rechercher" action="rechercheMatieres" controller="item"
                      title="Lancer la recherche" class="button" update="search-matiere-form"/>
    </div>
</g:form>


<g:if test="${matieres && matieres.totalCount <= grailsApplication.config.eliot.listes.structures.maxrecherche}">

  <div class="portal_pagination">
    <p style="float: right">Cliquez sur la matière à sélectionner</p>
    <p class="nb_result" >${matieres.totalCount} résultat(s)</p>


  </div>

  <div class="portal-default_results-list">

    <g:each in="${matieres}" status="i" var="matiereInstance">
      <div class="${(i % 2) == 0 ? 'even' : 'odd'}" style="z-index: 0;text-align: left">
          <a onclick="selectMatiere(${matiereInstance.id},'${matiereInstance.libelleLong}')">${matiereInstance.libelleEdition}</a>
      </div>
    </g:each>
  </div>

</g:if>
<g:elseif test="${matieres && matieres.totalCount > grailsApplication.config.eliot.listes.structures.maxrecherche}">
  <div class="portal_pagination">
    <p class="nb_result">Plus de ${grailsApplication.config.eliot.listes.structures.maxrecherche} résultats ont été trouvés. Vous pouvez préciser votre recherche en renseignant des critères de recherche supplémentaires.</p>
  </div>
</g:elseif>
<g:else>
  <div class="portal_pagination">
    <p class="nb_result">Aucun résultat</p>
</div>
</g:else>

<script type="text/javascript">
  $("#patternCode").keypress(function(event) {
        if ( event.which == 13 ) {
           event.preventDefault();
         }
      })

  function selectMatiere(matiereId,matiereAffichage) {
   $("#matiere-selection").html(
           '<span id="matiere-selection">' +
           '<strong>'+ matiereAffichage + '</strong>'+
           '<input type="hidden" name="matiere.id" value="'+ matiereId +'"/>' +
           '</span>'
   )
   $( "#search-matiere-form" ).dialog( "close" );
  }


</script>