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

%{-- Si le filtre n'est pas actif, on affiche tous les domaines --}%
%{-- Si le filtre est actif, on affiche uniquement les domaines ancêtres des compétences sélectionnées --}%
<g:if test="${!selectionUniquement || domaine.isAncestorOfAnyOf(competenceSelectionList)}">

  <li>
    <b>${domaine.nom}</b>

    <ul>
      <g:each in="${domaine.allSousDomaine.sort { it.nom }}" var="sousDomaine">
        <g:render
            template="/competence/affiche_domaine_competence"
            model="[domaine: sousDomaine, lectureSeule: lectureSeule, selectionUniquement: selectionUniquement, competenceSelectionList: competenceSelectionList]"/>
      </g:each>

      <g:each in="${domaine.allCompetence.sort { it.nom }}" var="competence">
        <g:if test="${!selectionUniquement || competence in competenceSelectionList}">
          <li>
            <g:if test="${!lectureSeule}">
              %{-- TODO nom du champs ? --}%
              <g:checkBox name="competence"
                          checked="${competence in competenceSelectionList}"
                          value="${competence.id}"/>
            </g:if>
            ${competence.nom}
          </li>
        </g:if>
      </g:each>
    </ul>
  </li>
</g:if>