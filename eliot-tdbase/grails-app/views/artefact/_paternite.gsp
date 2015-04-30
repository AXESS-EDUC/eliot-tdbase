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

<tr>
  <td class="label">Paternité&nbsp;:</td>
  <td>
    <span id="paternite"></span>
  </td>
</tr>

<r:script>
$(document).ready(function () {
    var paterniteObj = ${paternite};
    var nbItems = paterniteObj.paterniteItems.length
    var paterniteHtml = ""
    var strOeuvrePubliee = " a publié cette oeuvre le "
    var strOeuvreModifiee = " a contribué à cette oeuvre"
    var strOeuvreAjoutContributeurs = " a ajouté les contributeurs suivants à cette oeuvre : "
    var strOeuvreReutiliseePubliee = " a publié l'oeuvre réutilisée par la présente le  "
    var strOeuvreReutiliseeModifiee = " a contribué à l'oeuvre réutilisée par la présente"
    var strOeuvreReutiliseeAjoutContributeurs = " a ajouté les contributeurs suivants à l'oeuvre réutilisée par la présente : "
    for (i = 0 ; i < nbItems ; i++) {
       var paterniteItem = paterniteObj.paterniteItems[i];
       paterniteHtml += paterniteItem.auteur;
       if(paterniteItem.datePublication) {
         var dateArray = paterniteItem.datePublication.substring(0,10).split("-") ;
         if(paterniteItem.oeuvreEnCours == true) {
            paterniteHtml += strOeuvrePubliee + dateArray[2] + "/" + dateArray[1] + "/" + dateArray[0] + "<br/>";
         }
         else {
            paterniteHtml += strOeuvreReutiliseePubliee + dateArray[2] + "/" + dateArray[1] + "/" + dateArray[0] + "<br/>";
         }
       }
       else if(paterniteItem.contributeurs) {
          if(paterniteItem.oeuvreEnCours == true) {
            paterniteHtml += strOeuvreAjoutContributeurs + paterniteItem.contributeurs.join(', ') + "<br/>"
          }
          else {
            paterniteHtml += strOeuvreReutiliseeAjoutContributeurs + paterniteItem.contributeurs.join(', ') + "<br/>"
          }
       }
       else {
        if(paterniteItem.oeuvreEnCours == true) {
            paterniteHtml += strOeuvreModifiee + "<br/>"
         }
         else {
            paterniteHtml += strOeuvreReutiliseeModifiee + "<br/>"
         }
       }
    }
    $("#paternite").html(paterniteHtml) ;
  });
</r:script>