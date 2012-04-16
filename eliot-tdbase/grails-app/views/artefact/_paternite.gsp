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
    var strPub1 = " a publié l'oeuvre réutilisée par la présente le  "
    var strPub2 = " a publié cette oeuvre le "
    for (i = 0 ; i < nbItems ; i++) {
       var strPub = strPub1 ;
       var paterniteItem = paterniteObj.paterniteItems[i];
       if (paterniteItem.oeuvreEnCours == true ) {
        strPub = strPub2 ;
       }
       paterniteHtml += paterniteItem.auteur + strPub  ;
       var dateArray = paterniteItem.datePublication.substring(0,10).split("-") ;
       paterniteHtml += dateArray[2] + "/" + dateArray[1] + "/" + dateArray[0] + "<br/>"
    }
    $("#paternite").html(paterniteHtml) ;
  });
</r:script>