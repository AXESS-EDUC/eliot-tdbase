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
  <meta name="layout" content="eliot"/>
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
  <h1>Recherche et consultation des sujets de TD</h1>

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

</div>

</body>
</html>