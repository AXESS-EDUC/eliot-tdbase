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

%{-- TODO Numérotation --}%
<ul>
  <form id="form-competence-selection">
    <g:each in="${referentiel.domaineRacineList.sort { it.nom }}" var="domaine">
      <g:render
          template="/competence/affiche_domaine_competence"
          model="[
              referentiel: referentiel,
              domaine: domaine,
              lectureSeule: lectureSeule,
              selectionUniquement: selectionUniquement,
              competenceSelectionList: competenceSelectionList
          ]"/>
    </g:each>

    %{-- Images de référence utilisées par la méthode toggleDomaine pour changer l'image d'un domaine --}%
    %{-- suivant si celui-ci est ouvert ou fermé --}%
    <g:img id="image-triangle-down" file="TriangleDown8.png" style="display: none" />
    <g:img id="image-triangle-right" file="TriangleRight8.png" style="display: none" />

    <script>
    var imageTriangleDownElement = document.getElementById('image-triangle-down');
    var imageTriangleRightElement = document.getElementById('image-triangle-right');

      function toggleDomaine(domaineId) {
        var domaineContenuElement = document.getElementById('domaine-' + domaineId + '-contenu');
        var domaineImage = document.getElementById('domaine-' + domaineId + '-image');

        if (domaineContenuElement.style.display == 'none') {
          domaineContenuElement.style.display = 'block';
          domaineImage.src = imageTriangleDownElement.src;
        }
        else {
          domaineContenuElement.style.display = 'none';
          domaineImage.src = imageTriangleRightElement.src;
        }
      }
    </script>
  </form>
</ul>
