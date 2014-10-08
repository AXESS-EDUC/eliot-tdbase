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

<%@ page import="org.lilie.services.eliot.competence.SourceReferentiel" contentType="text/html;charset=UTF-8" %>
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
<html>
<head>
  <meta name="layout" content="eliot-tdbase-maintenance"/>
  <title>Administration de la liaison eliot-tdbase / EmaEval</title>
</head>

<body>
<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>

<div style="margin-left: 30px;">


%{--<div id="portal-content" class="container">--}%
  <h1 style="margin-left: 0;">Administration de la liaison à EmaEval</h1>

  <g:render template="/maintenance/emaEval/showConfig" model="[config: config]"/>


  <g:if test="${config.eliot.interfacage.emaeval.actif}">
    <h2>Statut de la liaison EmaEval</h2>

    <table class="portal-default_table" style="width: 95%;">
      <tr>
        <td class="inspect_field" style="width: 25%;">Référentiel</td>
        <td id="statut-referentiel" style="text-align: left; width: 75%"><r:img file="spinner.gif"/></td>
      </tr>

      <tr>
        <td class="inspect_field">Plan</td>
        <td id="statut-plan" style="text-align: left"><r:img file="spinner.gif"/></td>
      </tr>

      <tr>
        <td class="inspect_field">Scénario</td>
        <td id="statut-scenario" style="text-align: left"><r:img file="spinner.gif"/></td>
      </tr>

      <tr>
        <td class="inspect_field">Méthode d'évaluation</td>
        <td id="statut-methode" style="text-align: left"><r:img file="spinner.gif"/></td>
      </tr>
    </table>

  </g:if>

</div>

<r:script>
  var urlInitialiseOuVerifieReferentiel = '<g:createLink action="initialiseOuVerifieReferentiel" />';
  var urlInitialiseOuVerifiePlan = '<g:createLink action="initialiseOuVerifiePlan" />';
  var urlInitialiseOuVerifieScenario = '<g:createLink action="initialiseOuVerifieScenario" />';
  var urlInitialiseOuVerifieMethodeEvaluation = '<g:createLink action="initialiseOuVerifieMethodeEvaluation" />';

  $.get(urlInitialiseOuVerifieReferentiel, function(data) {
    if(data.success) {
      $('#statut-referentiel').html('<g:renderStatut value="${true}"/>');
    }
    else {
      $('#statut-referentiel').html('<g:renderStatut value="${false}"/>'+data.error);
    }
  });

  $.get(urlInitialiseOuVerifiePlan, function(data) {
    if(data.success) {
      $('#statut-plan').html('<g:renderStatut value="${true}"/>');
    }
    else {
      $('#statut-plan').html('<g:renderStatut value="${false}"/>'+data.error);
    }
  });

  $.get(urlInitialiseOuVerifieScenario, function(data) {
    if(data.success) {
      $('#statut-scenario').html('<g:renderStatut value="${true}"/>');
    }
    else {
      $('#statut-scenario').html('<g:renderStatut value="${false}"/>'+data.error);
    }
  });

  $.get(urlInitialiseOuVerifieMethodeEvaluation, function(data) {
    if(data.success) {
      $('#statut-methode').html('<g:renderStatut value="${true}"/>');
    }
    else {
      $('#statut-methode').html('<g:renderStatut value="${false}"/>'+data.error);
    }
  });
</r:script>

</body>
</html>