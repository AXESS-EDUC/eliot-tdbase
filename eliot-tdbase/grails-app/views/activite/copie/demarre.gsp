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




<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta name="layout" content="eliot-tdbase-activite"/>

    <title><g:message code="activite.copie.edite.head.title"/></title>
</head>

<body>

<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>

<g:form method="post" class="edite">
    <g:hiddenField name="id" value="${copie.id}"/>

    <div class="portal-form_container edite" width="69%">

        <table>
            <tr>
                <td class="label">Sujet :</td>
                <td><strong>${copie.modaliteActivite.sujet.titre}</strong></td>
            </tr>
            <tr>
                <td class="label">Début :</td>
                <td><strong>${copie.modaliteActivite.dateDebut.format('dd/MM/yyyy HH:mm')}</strong></td>
            </tr>
            <tr>
                <td class="label">Fin :</td>
                <td><strong>${copie.modaliteActivite.dateFin.format('dd/MM/yyyy HH:mm')}</strong></td>
            </tr>
            <tr>
                <td class="label">Durée de la séance :</td>
                <td><strong>${copie.modaliteActivite.dureeMinutes}</strong> minutes</td>
            </tr>
        </table>
    </div>

    <div class="bottom">
        <g:if test="${copie.estModifiable()}">
            <div class="form_actions">
                <g:actionSubmit value="Démarrer le travail"
                                action="commenceSession"
                                class="button"
                                title="Démarrer le travail"/>
            </div>
        </g:if>
    </div>
</g:form>
</body>
</html>