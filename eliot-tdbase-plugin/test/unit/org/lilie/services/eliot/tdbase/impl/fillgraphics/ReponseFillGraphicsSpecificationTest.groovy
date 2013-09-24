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

package org.lilie.services.eliot.tdbase.impl.fillgraphics

/**
 * Created by IntelliJ IDEA.
 * User: bert
 * Date: 27/01/12
 * Time: 11:10
 * To change this template use File | Settings | File Templates.
 */
class ReponseFillGraphicsSpecificationTest extends GroovyTestCase {

  void testEvaluate() {
    List<TextZoneContenu> valeursDeReponse = []
    valeursDeReponse << new TextZoneContenu(id: "1", text: "HellO")
    valeursDeReponse << new TextZoneContenu(id: "2", text: "Toto")

    List<TextZoneContenu> reponsesPossibles = []
    reponsesPossibles << new TextZoneContenu(id: "1", text: "HEllo")
    reponsesPossibles << new TextZoneContenu(id: "2", text: "Toto")

    def result = new ReponseFillGraphicsSpecification(valeursDeReponse: valeursDeReponse,
                                                      reponsesPossibles: reponsesPossibles).evaluate(4F)
    assertEquals(4F, result, 0F)

    valeursDeReponse = []
    valeursDeReponse << new TextZoneContenu(id: "2", text: "Toto")

    reponsesPossibles = []
    reponsesPossibles << new TextZoneContenu(id: "1", text: "Hello")
    reponsesPossibles << new TextZoneContenu(id: "2", text: "Toto")

    result = new ReponseFillGraphicsSpecification(valeursDeReponse: valeursDeReponse,
                                                  reponsesPossibles: reponsesPossibles).evaluate(4F)
    assertEquals(2F, result, 0F)

  }
}
