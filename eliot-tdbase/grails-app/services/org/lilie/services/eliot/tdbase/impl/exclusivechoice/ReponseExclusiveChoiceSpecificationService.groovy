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
package org.lilie.services.eliot.tdbase.impl.exclusivechoice

import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.ReponseSpecification
import org.lilie.services.eliot.tdbase.ReponseSpecificationService
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.QuestionSpecification

/**
 *
 * @author franck Silvestre
 */
class ReponseExclusiveChoiceSpecificationService extends ReponseSpecificationService<ReponseExclusiveChoiceSpecification> {

  @Override
  ReponseExclusiveChoiceSpecification createSpecification(Map map) {
    new ReponseExclusiveChoiceSpecification(map)
  }

  @Override
  ReponseExclusiveChoiceSpecification getObjectInitialiseFromSpecification(QuestionSpecification questionSpecification) {

    def specObj = questionSpecification

    return createSpecification(indexBonneReponse: specObj.indexBonneReponse,
                               numberReponsesPossibles: specObj.reponses.size())
  }
}

/**
 * Représente un objet spécification pour une question de type MultipleChoice
 */
class ReponseExclusiveChoiceSpecification implements ReponseSpecification {
  String questionTypeCode = QuestionTypeEnum.ExclusiveChoice.name()
  /**
   * L'indexe de la reponse
   */
  String indexReponse

  /**
   * L'indexe de la bonne reponse
   */
  String indexBonneReponse

  /**
   * Le nombre de reponses possibles 
   */
  Integer numberReponsesPossibles = 0

  @Override
  Map toMap() {
    [
            questionTypeCode: questionTypeCode,
            indexReponse: indexReponse,
            indexBonneReponse: indexBonneReponse,
            numberReponsesPossibles: numberReponsesPossibles
    ]
  }

  /**
   * Si il n'y a aucune réponse explicite (pas de bouton coché), la notes est 0.
   * Si il y a au moins une réponse explicite (un bouton cochée), alors :
   * - si réponse juste on ajoute un point
   * - si réponse fausse on retranche un point
   * On effectue une règle de trois pour ramener la note correspondant au barême
   * @param maximumPoints
   * @return
   */
  float evaluate(float maximumPoints) {
    def res = 0
    if (indexReponse == indexBonneReponse) {
      res = maximumPoints
    } else if (indexReponse != null) {

      // on décompte avec points positifs et/ou négatifs
      res = (-1 / numberReponsesPossibles) * maximumPoints
    }
    res
  }
}