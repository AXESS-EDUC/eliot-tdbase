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

<r:script>
  $(function () {
    $('#selection-competence-dialog').dialog({
      resizable: false,
      modal: true,
      height: 600,
      width: 600,
      buttons: {
        Annuler: function () {
          $(this).dialog("close");
        },
        Valider: function () {
          var allSelectedCompetenceId =
          $('#form-competence-selection').find('input:checked[name=competence]').map(function () {
            return $(this).val();
          }).get();

          // Supprime tous les champs cachés stockant les identifiants de compétences anciennement utilisées
          $('input[name=competenceAssocieeIdList]').remove();

          // Ajouter un champs caché pour chaque compétence utilisée maintenant
          var sectionCompetence = $('#section-competence');
          $.each(allSelectedCompetenceId, function (index, value) {
            sectionCompetence.append("<input type='hidden' name='competenceAssocieeIdList' value='" + value + "'/>");
          });

          var url = '${g.createLink(plugin: 'eliot-competence-plugin', controller: 'competence', action: 'afficheArbreCompetence', params: [referentielId: referentielCompetence.id, lectureSeule: true, selectionUniquement: true])}';
          $.each(allSelectedCompetenceId, function (index, value) {
            url += ('&competenceSelectionIdList='+ value)
          });
          $.get(url, function(data) {
            $('#arbre-competence').html(data);
          });

          $(this).dialog("close");
        }
      },
      autoOpen: false
    });
  });

  var selectedCompetence = [];

  function actionSelectionCompetence() {
    var selectCompetenceDialogElement = $('#selection-competence-dialog');

    if(selectCompetenceDialogElement.children().size() === 0) {
      var url = '${g.createLink(plugin: 'eliot-competence-plugin', controller: 'competence', action: 'afficheArbreCompetence', params: [referentielId: referentielCompetence.id, lectureSeule: false, selectionUniquement: false, competenceSelectionIdList: competenceAssocieeList*.id])}';

      $.get(url, function(data) {
        selectCompetenceDialogElement.html(data);
      });
    }

    selectCompetenceDialogElement.dialog('open');

}
</r:script>


<div id="selection-competence-dialog" title="Sélection des compétences" style="display: none; text-align: left;">
  %{-- Le contenu de la fenêtre de sélection des compétences sera alimenté par
       requête AJAX quand l'action selectionCompetence sera déclenchée --}%
</div>