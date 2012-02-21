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


<style type="text/css">

.participantCorrection {
    text-align: center;
    float: left;
    margin: 5px 5px 5px 5px;
    border: solid 1px #808080;
    background: #b5bdff;
    display: inline-block;
    height: 1.5em;
    width: 17em;
    padding: 0.5em 0.5em 0.5em 0.5em;
    text-decoration-color: #817134;
}

</style>

<g:set var="specifobject" value="${question.specificationObject}"/>
<div class="item">
    <strong>Correction&nbsp;:</strong> <br/>
    <table>
        <g:each status="i" in="${specifobject.associations}" var="association">
            <tr>
                <td class="participantCorrection">
                    ${association.participant1}
                </td>
                <td>------</td>
                <td class="participantCorrection">
                    ${association.participant2}
                </td>
            </tr>
        </g:each>
    </table>
    <strong>Remarque :</strong> ${specifobject.correction}
</div>