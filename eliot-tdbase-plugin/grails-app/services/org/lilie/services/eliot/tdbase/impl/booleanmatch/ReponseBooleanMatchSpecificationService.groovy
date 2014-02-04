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

package org.lilie.services.eliot.tdbase.impl.booleanmatch

import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.ReponseSpecification
import org.lilie.services.eliot.tdbase.ReponseSpecificationService
import org.lilie.services.eliot.tice.utils.StringUtils
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.QuestionSpecification

/**
 * Service pour les specifications de reponses de type booléenne.
 */
class ReponseBooleanMatchSpecificationService extends ReponseSpecificationService<ReponseBooleanMatchSpecification> {

  @Override
  ReponseBooleanMatchSpecification createSpecification(Map map) {
    new ReponseBooleanMatchSpecification(map)
  }

  @Override
  ReponseBooleanMatchSpecification getObjectInitialiseFromSpecification(QuestionSpecification questionSpecification) {

    BooleanMatchSpecification specification = questionSpecification;

    return createSpecification(reponsesPossibles: specification.reponses,
                               toutOuRien: specification.toutOuRien)
  }
}

/**
 * Représente un objet spécification pour une question de booléenne.
 */
class ReponseBooleanMatchSpecification implements ReponseSpecification {
  String questionTypeCode = QuestionTypeEnum.BooleanMatch.name()
  /**
   * La valeur de la reponse.
   */
  String valeurDeReponse

  /**
   * La valeur correcte de la reponse.
   */
  List<String> reponsesPossibles = []

  /**
   * Influence sur le mode d'evaluation.
   */
  boolean toutOuRien

  Map toMap() {
    [
            questionTypeCode: questionTypeCode,
            valeurDeReponse: valeurDeReponse,
            reponsesPossibles: reponsesPossibles,
            toutOuRien: toutOuRien
    ]
  }

  /**
   *
   * @param maximumPoints
   * @return
   */
  float evaluate(float maximumPoints) {

    List<String> valeursreponseList = new ArrayList<String>(valeurDeReponse.split("\\s").collect {StringUtils.normalise(it)})
    List<String> normalisedPossibleReponseList = reponsesPossibles.collect {StringUtils.normalise(it)}

    float points = 0F

    if (toutOuRien) {
      if (valeursreponseList.containsAll(normalisedPossibleReponseList)) {
        points = maximumPoints
      }
    } else {
      def intesection = normalisedPossibleReponseList.intersect(valeursreponseList)
      points = intesection.size() / normalisedPossibleReponseList.size() * maximumPoints
    }
    points
  }
}