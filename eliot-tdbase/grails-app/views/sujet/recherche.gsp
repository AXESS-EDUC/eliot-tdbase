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
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta name="layout" content="eliot-tdbase"/>
  <r:require modules="jquery"/>
  <r:script>
    $(function() {
      $('#menu-item-sujets').addClass('actif');
    });
  </r:script>
  <title>TDBase - Recherche de sujets</title>
</head>

<body>
<div class="column span-22 last middle">
  <div class="portal-breadcrumbs">${titrePage}</div>
  <g:if test="${afficheFormulaire}">
    <form name="f_3_30_3" method="post"
          action="#">
      <div class="portal-form_container">
        <table>
          <tr>
            <td class="label">
              titre :
            </td>
            <td>
              <input size="30" type="text" name="3.30.3.1"/>
            </td>
            <td width="20"/>
            <td class="label">type :
            </td>
            <td>
              <select name="3.30.3.3"><option
                      value="WONoSelectionString">Tous</option><option
                      value="0">Exercice</option><option
                      value="1">Sujet</option></select>
            </td>
          </tr>
          <tr>
            <td class="label">
              en bref :
            </td>
            <td>
              <input size="30" type="text" name="3.30.3.5"/>
            </td>
            <td width="20"/>
            <td class="label">discipline :
            </td>
            <td>
              <select name="3.30.3.7"><option
                      value="WONoSelectionString">Toutes</option><option
                      value="0">SES</option><option
                      value="1">SES Spécialité</option><option
                      value="2">Histoire</option><option
                      value="3">Géographie</option><option
                      value="4">Communication</option><option
                      value="5">Anglais</option></select>
            </td>
          </tr>
          <tr>
            <td class="label">auteur :
            </td>
            <td>
              <input size="30" type="text" name="3.30.3.9"/>
            </td>
            <td width="20"/>
            <td class="label">niveau :
            </td>
            <td>
              <select name="3.30.3.11"><option
                      value="WONoSelectionString">Tous</option><option
                      value="0">Seconde</option><option
                      value="1">Première</option><option
                      value="2">Terminale</option><option
                      value="3">IUT 1ère année</option><option
                      value="4">IUT 2ème année</option></select>
            </td>
          </tr>

        </table>
      </div>

      <div class="form_actions">
        <input type="submit" value="Rechercher" name="3.30.3.13"/>
      </div>
    </form>
  </g:if>

  <g:if test="${sujetsCount}">
    <div class="portal_pagination">
      <g:paginate controller="sujet" action="mesSujets" total="${sujetsCount}"></g:paginate>
    </div>

    <div class="portal-default_table">
      <table>
        <thead>
        <tr>
          <th>Titre</th>
          <th>Niveau</th>
          <th>Dur&eacute;e</th>
          <g:if test="${afficheFormulaire}">
            <th>Auteur</th>
          </g:if>
          <th>Accès public</th>
          <th>Tester</th>
          <th>Séance</th>
        </tr>
        </thead>

        <tbody>
        <g:each in="${sujets}" status="i" var="sujetInstance">
          <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">
            <td>
              <g:link action="edite"
                      id="${sujetInstance.id}">${fieldValue(bean: sujetInstance, field: "titre")}</g:link>
            </td>
            <td>
              ${sujetInstance.niveau?.libelleLong}
            </td>
            <td>
              ${fieldValue(bean: sujetInstance, field: "dureeMinutes")}
            </td>
            <g:if test="${afficheFormulaire}">
              <td>${sujetInstance.proprietaire.prenom} ${sujetInstance.proprietaire.nom}</td>
            </g:if>
            <td>
              ${sujetInstance.accesPublic ? 'oui' : 'non'}
            </td>
            <td>

              <a href="#">
                <img border="0"
                     src="/eliot-tdbase/images/eliot/write-btn.gif"
                     width="18" height="16"/>
              </a>

            </td>
            <td>

              <a href="#">
                <img border="0"
                     src="/eliot-tdbase/images/eliot/ActionIconAdd.gif"
                     width="20" height="19"/>
              </a>

            </td>
          </tr>
        </g:each>
        </tbody>
      </table>
    </div>
  </g:if>
</div>

</body>
</html>