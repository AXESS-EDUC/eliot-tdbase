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
package org.lilie.services.eliot.tdbase.impl.multiplechoice

import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.ReponseSpecification
import org.lilie.services.eliot.tdbase.ReponseSpecificationService

/**
 *
 * @author franck Silvestre
 */
class ReponseMultipleChoiceSpecificationService extends ReponseSpecificationService<ReponseMultipleChoiceSpecification> {

  @Override
  ReponseMultipleChoiceSpecification createSpecification(Map map) {
    new ReponseMultipleChoiceSpecification(map)
  }

  /**
   * @see ReponseSpecificationService
   */
  ReponseMultipleChoiceSpecification getObjectInitialiseFromSpecification(Question question) {
    def reponsesPossibles = question.specificationObject.reponses
    ReponseMultipleChoiceSpecification specObj = new ReponseMultipleChoiceSpecification()

    reponsesPossibles.each {
      if (it.estUneBonneReponse) {
        specObj.labelsReponsesCorrects << it.libelleReponse
      }
    }
    specObj
  }
}

/**
 * Représente un objet spécification pour une question de type MultipleChoice
 */
class ReponseMultipleChoiceSpecification implements ReponseSpecification {

  /**
   * Les réponses cochés.
   */
  List<String> labelsReponsesCoches = []

  /**
   * Les reponses corrects.
   */
  List<String> labelsReponsesCorrects = []

  @Override
  Map toMap() {
    [
            labelsReponsesCoches: labelsReponsesCoches,
            labelsReponsesCorrects: labelsReponsesCorrects,
    ]
  }

  /**
   * Si il n'y a aucune réponse explicite (pas de cases cochées), la notes est 0.
   * Si il y a au moins une réponse explicite (une case cochée), alors :
   * - pour chaque réponse juste on ajoute un point
   * - pour chaque réponse fausse on retranche un point
   * On effectue une règle de trois pour ramener la note correspondant au barême
   */
  float evaluate(float maximumPoints) {

    if (labelsReponsesCoches.isEmpty()) {
      return 0F
    }

    def points = 0
    labelsReponsesCorrects.each {
      if (labelsReponsesCoches.contains(it)) { points++ } else {points--}
    }



    points / labelsReponsesCorrects.size() * maximumPoints;
  }
}