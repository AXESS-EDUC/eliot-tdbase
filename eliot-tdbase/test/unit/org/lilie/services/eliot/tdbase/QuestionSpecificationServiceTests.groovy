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



package org.lilie.services.eliot.tdbase

import org.lilie.services.eliot.tdbase.impl.MultipleChoiceSpecification
import org.lilie.services.eliot.tdbase.impl.MultipleChoiceSpecificationReponse
import org.lilie.services.eliot.tdbase.impl.QuestionMultipleChoiceSpecificationService

/**
 *
 * @author franck Silvestre
 */
class QuestionSpecificationServiceTests extends GroovyTestCase {

  private static final String LIBELLE_QUESTION_1 = "Quelle est la bonne réponse"
  private static final String CORRECTION_QUESTION_1 = "Attention la 1 n'est pas la bonne"
  QuestionMultipleChoiceSpecificationService questionMultipleChoiceSpecificationService

  protected void setUp() {
    super.setUp()
    questionMultipleChoiceSpecificationService = new QuestionMultipleChoiceSpecificationService()
  }

  protected void tearDown() {
    super.tearDown()
  }

  void testGetSpecificationFromObject() {
    def rep1 = new MultipleChoiceSpecificationReponse(
            libelleReponse: "réponse 1",
            valeur: -0.5
    )
    def rep2 = new MultipleChoiceSpecificationReponse(
            libelleReponse: "réponse 2",
            estUneBonneReponse: true,
            valeur: 0.5
    )
    def rep3 = new MultipleChoiceSpecificationReponse(
            libelleReponse: "réponse 3",
            estUneBonneReponse: true,
            valeur: 0.5
    )
    def specObject = new MultipleChoiceSpecification(
            libelle: LIBELLE_QUESTION_1,
            correction: CORRECTION_QUESTION_1,
            reponses: [rep1, rep2, rep3]
    )
    String specString = questionMultipleChoiceSpecificationService.getSpecificationFromObject(specObject)

    assertNotNull(specString)
    println(specString)

  }

  void testGetObjectFromSpecification() {
    String specAsString = '''
      {
          "libelle": "Quelle est la bonne réponse",
          "correction": "Attention la 1 n'est pas la bonne",
          "reponses": [
              {
                  "libelleReponse": "réponse 1",
                  "estUneBonneReponse": false,
                  "valeur": -0.5
              },
              {
                  "libelleReponse": "réponse 2",
                  "estUneBonneReponse": true,
                  "valeur": 0.5
              },
              {
                  "libelleReponse": "réponse 3",
                  "estUneBonneReponse": true,
                  "valeur": 0.5
              }
          ]
      }
    '''
    def specAsObject = questionMultipleChoiceSpecificationService.getObjectFromSpecification(specAsString)
    assertTrue(specAsObject instanceof MultipleChoiceSpecification)
    assertEquals(LIBELLE_QUESTION_1, specAsObject.libelle)
    assertEquals(CORRECTION_QUESTION_1, specAsObject.correction)
    assertEquals(3, specAsObject.reponses.size())
    assertTrue(specAsObject.reponses[1].estUneBonneReponse)
    assertTrue(specAsObject.reponses[2].estUneBonneReponse)
    assertFalse(specAsObject.reponses[0].estUneBonneReponse)
    assertEquals(-0.5, specAsObject.reponses[0].valeur, 0.001)
  }
}
