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
  <title>Administration de la liaison eliot-tdbase / EmaEval</title>
  <r:require module="eliot-tdbase"/>
  <r:layoutResources/>
</head>

<body>
<div id="portal-content" class="container">
  <h1 style="margin-left: 0;">Administration de la liaison à EmaEval</h1>

  <g:render template="showConfig" model="[config: config]"/>


  <g:if test="${config.eliot.interfacage.emaeval.actif}">
    <h2>Statut de la liaison EmaEval</h2>

    <g:if test="${!eliotReferentiel}">
      <g:render template="importeReferentiel" />
    </g:if>
    <g:else>
      <g:render template="verifieLiaision" model="[eliotReferentiel: eliotReferentiel]"/>
    </g:else>

  </g:if>

</div>

<r:layoutResources/>
</body>
</html>