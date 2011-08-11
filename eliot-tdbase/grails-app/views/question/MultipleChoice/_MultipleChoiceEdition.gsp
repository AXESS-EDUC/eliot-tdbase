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
  <td class="label">
    Lib&eacute;ll&eacute;:
  </td>
  <td>
    <g:textArea
            name="specifobject.libelle"
            rows="5" cols="55"
            value="${specifobject.libelle}"
    />
  </td>
</tr>
<tr>
  <td class="label">
    R&eacute;ponse(s):
  </td>
  <td>

    <table>
      <tr>
        <td>
          <g:each in="${specifobject.reponses}" var="reponse">
            <br/>
            &nbsp;
            <input type="checkbox" name="1.30.3.21.1.1.0.1"
                   value="1.30.3.21.1.1.0.1"/>
            <input size="35" type="text" value="réponse 1"
                   name="1.30.3.21.1.1.0.3"/>
            &nbsp;
            <input size="2" type="text" value="0" name="1.30.3.21.1.1.0.5"/>
            &nbsp;
            <input title="Supprime la réponse" type="image"
                   name="1.30.3.21.1.1.0.7"
                   src="/eliot-tdbase/images/eliot/ActionIconRemove.gif"
                   width="20" height="20"/>
          </g:each>
          <input type="image" name="1.30.3.21.1.3"
                 src="/eliot-tdbase/images/eliot/ActionIconAdd.gif"
                 width="20" height="19"/>
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
            rows="5" cols="55"
            value="${specifobject.correction}"
    />
  </td>
</tr>