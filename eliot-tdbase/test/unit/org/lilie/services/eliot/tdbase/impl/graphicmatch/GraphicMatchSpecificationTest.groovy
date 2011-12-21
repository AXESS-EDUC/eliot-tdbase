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

package org.lilie.services.eliot.tdbase.impl.graphicmatch

/**
 * Created by IntelliJ IDEA.
 * User: bert
 * Date: 20/12/11
 * Time: 15:08
 * To change this template use File | Settings | File Templates.
 */
class GraphicMatchSpecificationTest extends GroovyTestCase {

    void testItemEquals() {
        def field1 = new TextField([topDistance: 2, leftDistance: 2, hSize: 100, vSize: 50, text: "Hi Dude"])
        def field2 = new TextField([topDistance: 2, leftDistance: 2, hSize: 100, vSize: 50, text: "Hi Dude"])
        assertEquals(field1, field2)

        field1 = new TextField([topDistance: 2])
        field2 = new TextField([topDistance: 2])
        assertEquals(field1, field2)

        field1 = new TextField([topDistance: 2, text: "Hello"])
        field2 = new TextField([topDistance: 1, text: "Hello"])
        assertEquals(field1, field2)

        field1 = new TextField([topDistance: 2, text: "Hello"])
        field2 = new TextField([topDistance: 1, text: "Hello Dude"])
        assertNotSame(field1, field2)
    }

    void testEvaluate() {

        def valuesReponse = [[text: "Wie"], [text: "Wo"]]
        def reponsesPossibles = [[text: "Wie"], [text: "Wo"]]
        def spec = new ReponseGraphicMatchSpecification(reponsesPossibles: reponsesPossibles, valeursDeReponse: valuesReponse)
        assertEquals(1.0f, spec.evaluate(1.0f), 0.0f)

        valuesReponse = [[text: "Wie"], [text: "Wer"]];
        reponsesPossibles = [[text: "Wie"], [text: "Wo"]];;
        spec = new ReponseGraphicMatchSpecification(reponsesPossibles: reponsesPossibles, valeursDeReponse: valuesReponse)
        assertEquals(0.5f, spec.evaluate(1.0f), 0.0f)
    }
}