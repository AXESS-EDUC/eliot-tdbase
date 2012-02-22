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




<g:set var="specifobject" value="${question.specificationObject}"/>
<tr>
    <td class="label">
        Lib&eacute;ll&eacute;:
    </td>
    <td>
        <g:textArea
                name="specifobject.libelle"
                rows="3" cols="55"
                value="${specifobject.libelle}"/>
    </td>
</tr>
<tr>
    <td class="label">
        R&eacute;ponse:
    </td>
    <td>
        <table style="float: left; width:200px;">
            <tr>
                <td>Valeur attendue :</td>
                <td>
                    <g:textField name="specifobject.valeur" value="${specifobject.valeurAffichage}" size="10"/>
                </td>

            </tr>
            <tr>
                <td>Précision :</td>
                <td>
                    <g:textField name="specifobject.precision" value="${specifobject.precisionAffichage}" size="10"/>
                </td>
            </tr>
            <tr>
                <td>Valeur minimale :</td>
                <td>
                    <g:textField name="specifobject.valeurMin" value="${specifobject.valeurMinAffichage}" size="10"/>
                </td>

            </tr>
            <tr>
                <td>Valeur maximale :</td>
                <td>
                    <g:textField name="specifobject.valeurMax" value="${specifobject.valeurMaxAffichage}"
                                 size="10"/><br/>
                </td>

            </tr>
            <tr>
                <td>Pas:</td>
                <td>
                    <g:textField name="specifobject.pas" value="${specifobject.pasAffichage}" size="10"/>
                </td>
            </tr>
        </table>
    </td>
</tr>
<tr>
    <td class="label">
        Correction:
    </td>
    <td>
        <g:textArea
                name="specifobject.correction"
                rows="3" cols="55"
                value="${specifobject.correction}"/>
    </td>
</tr>