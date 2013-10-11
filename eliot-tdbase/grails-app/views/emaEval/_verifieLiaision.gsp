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


<table class="portal-default_table">
  <tr>
    <td class="inspect_field">Le référentiel "Palier 3" est disponible dans Eliot</td>
    <td><g:renderStatut value="${true}"/></td>
  </tr>
  <tr>
    <td class="inspect_field">Connexion à EmaEval</td>
    <td id="statut-ConnexionOK"><r:img file="spinner.gif"/></td>
  </tr>
  <tr>
    <td class="inspect_field">Le référentiel "Palier 3" est disponible dans EmaEval</td>
    <td id="statut-EmaEvalReferentiel"><r:img file="spinner.gif"/></td>
  </tr>
  <tr>
    <td class="inspect_field">Le référentiel d'Eliot est cohérent avec celui d'EmaEval</td>
    <td id="statut-coherenceReferentiel"><r:img file="spinner.gif"/></td>
  </tr>
</table>

<div id="section-detail-erreur" style="display: none;">
  <h3>Erreur rencontrée :</h3>

  <div id="contenu-detail-erreur"></div>
</div>

<r:script>
  var url = '<g:createLink action="verifieLiaisonEliotEmaEvalReferentiel" params="[eliotReferentielId: eliotReferentiel.id]"/>';
  $.get(url, function(data) {
  if(data.connexionEtablie) {
    $('#statut-ConnexionOK').html('<g:renderStatut value="${true}"/>');
  }
  else {
    $('#statut-ConnexionOK').html('<g:renderStatut value="${false}"/>');
  }

  if(data.emaEvalReferentiel) {
    $('#statut-EmaEvalReferentiel').html('<g:renderStatut value="${true}"/>');
  }
  else {
    $('#statut-EmaEvalReferentiel').html('<g:renderStatut value="${false}"/>');
  }

  if(data.coherenceReferentiel) {
    $('#statut-coherenceReferentiel').html('<g:renderStatut value="${true}"/>');
  }
  else {
    $('#statut-coherenceReferentiel').html('<g:renderStatut value="${false}"/>');
  }

  if(data.exception) {
      $('#contenu-detail-erreur').html(data.exception);
      $('#section-detail-erreur').show();
    }
  });
</r:script>
