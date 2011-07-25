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
  <title>TDBase - Edition des propriétés du sujet</title>
</head>

<body>

<div class="column span-22 last middle">
  <h1>Propriétés du sujet</h1>

  <form method="post"
        action="#">
    <div class="portal-form_container">
      <table>
        <tr>
          <td class="label">Titre:</td>
          <td>
            <input size="80" type="text" value="${sujet.titre}" name="titre"/>
          </td>
        </tr>
        <tr>
          <td class="label">Type:</td>
          <td>
            <select name="3.30.3.3"><option value="0">Exercice</option><option
                    selected="selected" value="1">Sujet</option></select>
          </td>
        </tr>
        <tr>
          <td class="label">Mati&egrave;re:</td>
          <td>
            <select name="3.30.3.5"><option
                    value="WONoSelectionString">Choisissez</option><option
                    value="0">SES</option><option
                    value="1">SES Spécialité</option><option
                    value="2">Histoire</option><option
                    value="3">Géographie</option><option
                    value="4">Communication</option><option
                    value="5">Anglais</option></select>
          </td>
        </tr>
        <tr>
          <td class="label">Niveau:</td>
          <td>
            <select name="3.30.3.7"><option selected="selected"
                                            value="0">Seconde</option><option
                    value="1">Première</option><option
                    value="2">Terminale</option><option
                    value="3">IUT 1ère année</option><option
                    value="4">IUT 2ème année</option></select>
          </td>
        </tr>
        <tr>
          <td class="label">Statut:</td>
          <td>
            <select name="3.30.3.9"><option selected="selected"
                                            value="0">Privé</option><option
                    value="1">En travaux</option><option
                    value="2">Public</option></select>
          </td>
        </tr>
        <tr>
          <td class="label">Dur&eacute;e:</td>
          <td>
            <input type="text" name="3.30.3.11"/>
            <i>(en minutes)</i>
          </td>
        </tr>
        <tr>
          <td class="label">Accessible:</td>
          <td>
            <input type="checkbox" name="3.30.3.13" value="3.30.3.13"/>
            Directement</td>
        </tr>
        <tr>
          <td class="label">Présentation:</td>
          <td>
            <input type="checkbox" name="3.30.3.15" value="3.30.3.15"/>
            s&eacute;quentielle</td>
        </tr>
        <tr>
          <td class="label">Export QTI:</td>
          <td>
            <input type="checkbox" name="3.30.3.17" value="3.30.3.17"/>
            Autoris&eacute;e</td>
        </tr>
        <tr>
          <td class="label">Ordre des questions:</td>
          <td>
            <input type="checkbox" name="3.30.3.19" value="3.30.3.19"/>
            Al&eacute;atoire</td>
        </tr>
        <tr>
          <td class="label">S&eacute;lection:</td>
          <td>
            <input type="text" name="3.30.3.21"/>
            <i>(le nombre de questions &agrave; selectionner)</i>
          </td>
        </tr>
        <tr>
          <td class="label">En bref:</td>
          <td>
            <textarea cols="80" rows="10" name="3.30.3.23"></textarea>
          </td>
        </tr>
      </table>
    </div>

    <div class="form_actions">
      <input title="Mémorise et propage les modifications. A effectuer avant toute sauvegarde"
             type="submit" value="Appliquer les modifications"
             name="3.30.3.25"/>
    </div>
  </form>
</div>

</body>
</html>