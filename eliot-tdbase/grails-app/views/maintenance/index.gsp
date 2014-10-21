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


<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta name="layout" content="eliot-tdbase-maintenance"/>
  <r:require modules="eliot-tdbase"/>
  <title><g:message code="maintenance.head.title"/></title>
</head>

<body>
<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>
<div style="margin-left: 30px;">
  <h2>
    <g:message code="maintenance.head.title"/>
  </h2>

  <p>
    <g:link action="supprimeCopiesJetables"
            controller="maintenance">Suppression des copies jetables</g:link>
  </p>
  <hr class="separator"/>

    <p>
        <g:link action="resetPreferencesEtablissement"
                controller="maintenance">Reset des préférences établissement</g:link>
    </p>
    <hr class="separator"/>

  <div>
    <g:link action="garbageCollectAttachementDataStore"
            controller="maintenance">Garbage collection des fichiers du datastore</g:link>

    <div class="portal-messages notice"
         style="color: red">
      Par précaution, il est recommandé d'effectuer une sauvegarde du datastore avant de
      lancer cette action de maintenance.
    </div>
  </div>
  <hr class="separator"/>

  <p>
    <g:link controller="emaEval">Administration de la liaison eliot-tdbase / EmaEval</g:link>
  </p>

  <p>
  </p>
</div>
</body>
</html>