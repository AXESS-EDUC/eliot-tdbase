%{--
  - Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
  -  This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
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
  -   <http://www.gnu.org/licenses/> and
  -   <http://www.cecill.info/licences.fr.html>.
  --}%
<g:form action="rechercheContributeur" controller="sujet">

  <g:hiddenField name="max" value="${rechercheContributeurCommand.max}"></g:hiddenField>
  <g:hiddenField name="offset" value="0"></g:hiddenField>

  <div class="portal-form_container recherche" style="width: 100%">
    <table>
      <tr>
        <td class="label">
          Rechercher
        </td>
        <td>
          <g:textField name="patternCode" title="code"
                       value="${rechercheContributeurCommand.patternCode}"/>
        </td>
      </tr>

      <tr>
        <td class="label">dans&nbsp;
        </td>
        <td>
          <g:select name="etablissementId"
                    value="${rechercheContributeurCommand.etablissementId}"
                    from="${etablissements}"
                    optionKey="id"
                    optionValue="nomAffichage"/>
        </td>
      </tr>

      <tr>
        <td class="label">Profil&nbsp;
        </td>
        <td id="selectFonctionList">
          <g:render template="/seance/selectFonction"
                    model="[fonctionId: rechercheContributeurCommand.fonctionId, fonctionList: fonctionList]"/>
        </td>
      </tr>

    </table>
  </div>

  <div class="form_actions recherche" style="width: 100%">
    <g:submitToRemote value="Rechercher"
                      action="rechercheContributeur"
                      controller="sujet"
                      title="Lancer la recherche"
                      class="button"
                      update="search-contributeur-form"
                      onSuccess="searchContributeurOnLoad();"
                      id="search-contributeur-button"/>
  </div>

  <g:if test="${resultat?.nombreTotal}">

    <div class="portal_pagination">
      <p class="nb_result">
        ${resultat.nombreTotal} résultat(s)

        <input type="button" class="button" style="text-transform: none; position: relative; float: right;"
               value="Ajouter le / les formateurs sélectionnés" onclick="ajouterFormateursSelectionnes(); return false;">
      </p>
    </div>

    <div class="portal-default_results-list">
      <g:each in="${resultat.personneList}" status="i" var="formateur">
        <div class="${(i % 2) == 0 ? 'even' : 'odd'}" style="z-index: 0;text-align: left">
          <input type="checkbox" id="formateur-checkbox${formateur.id}" class="formateur-checkbox" data-id="${formateur.id}" data-nomaffichage="${formateur.nomAffichage}"/>
          ${formateur.nomAffichage}
        </div>
      </g:each>
    </div>

    <div id="search-contributeur-pagination" class="portal_pagination">
      <g:paginate total="${resultat?.nombreTotal}"
                  max="rechercheContributeurCommand.max"
                  offset="rechercheContributeurCommand.offset"/>
    </div>

  </g:if>

</g:form>

<script>
  $("#patternCode").keypress(function (event) {
    if (event.which == 13) {
      event.preventDefault();
    }
  });

  $("#etablissementId").change(function () {
    $.get("${createLink(action: 'updateFonctionList', controller: 'sujet')}",
        {etablissementId: $(this).val()},
        function (data) {
          $('#selectFonctionList').html(data)
        });
  })
</script>