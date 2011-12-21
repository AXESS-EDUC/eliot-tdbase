/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 * Lilie is free software. You can redistribute it and/or modify since
 * you respect the terms of either (at least one of the both license) :
 * - under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * - the CeCILL-C as published by CeCILL-C; either version 1 of the
 * License, or any later version
 *
 * There are special exceptions to the terms and conditions of the
 * licenses as they are applied to this software. View the full text of
 * the exception in file LICENSE.txt in the directory of this software
 * distribution.
 *
 * Lilie is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * Licenses for more details.
 *
 * You should have received a copy of the GNU General Public License
 * and the CeCILL-C along with Lilie. If not, see :
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */

package org.lilie.services.eliot.tdbase.impl.gapfill

import org.lilie.services.eliot.tdbase.impl.fillgap.FillGapSpecification

/**
 * Created by IntelliJ IDEA.
 * User: bert
 * Date: 18/11/11
 * Time: 17:53
 * To change this template use File | Settings | File Templates.
 */
class FillGapSpecificationTest extends GroovyTestCase {

    void testGetTextATrousStructure() {

        def texteATrous = "The color of blood is #{red}. Major blood vessels are #{arteries, veins} and #{veins, arteries}."
        def structure = new FillGapSpecification([texteATrous: texteATrous]).texteATrousStructure

        assertEquals(structure.size(), 7)
        assertTrue(structure[0].isTexte())
        assertFalse(structure[1].isTexte())
        assertTrue(structure[2].isTexte())
        assertFalse(structure[3].isTexte())
        assertTrue(structure[4].isTexte())
        assertFalse(structure[5].isTexte())
        assertTrue(structure[6].isTexte())
    }

}
