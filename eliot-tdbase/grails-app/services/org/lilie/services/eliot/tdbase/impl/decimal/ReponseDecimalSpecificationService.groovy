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

package org.lilie.services.eliot.tdbase.impl.decimal

import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.Reponse
import org.lilie.services.eliot.tdbase.ReponseSpecification
import org.lilie.services.eliot.tdbase.ReponseSpecificationService
import org.lilie.services.eliot.tice.utils.NumberUtils
import org.springframework.transaction.annotation.Transactional
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.QuestionSpecification

/**
 *
 * @author franck Silvestre
 */
class ReponseDecimalSpecificationService extends ReponseSpecificationService<ReponseDecimalSpecification> {

  @Override
  ReponseDecimalSpecification createSpecification(Map map) {
    new ReponseDecimalSpecification(map)
  }

  @Override
  ReponseDecimalSpecification getObjectInitialiseFromSpecification(QuestionSpecification questionSpecification) {
    return createSpecification(valeurCorrecte: questionSpecification.valeur,
                               precision: questionSpecification.precision)
  }
}

/**
 * Représente un objet spécification pour une question de type Decimal.
 */
class ReponseDecimalSpecification implements ReponseSpecification {
  String questionTypeCode = QuestionTypeEnum.Decimal.name()
  /**
   * La valeur de la reponse.
   */
  Float valeurReponse

  /**
   * La valeur correcte de la reponse.
   */
  Float valeurCorrecte

  /**
   *    La plage de tollerance par rapport de laquelle la reponse peut être
   *    considerée comme correcte.
   */
  Float precision = 0F

  Map toMap() {
    [
            questionTypeCode: questionTypeCode,
            valeurReponse: valeurReponse,
            valeurCorrecte: valeurCorrecte,
            precision: precision
    ]
  }

  String getValeurReponseAffichage() {
    if (valeurReponse != null) {
      return NumberUtils.formatFloat(valeurReponse)
    }
    return null
  }

  /*Si il n'y a pas de réponse la note vaut 0
  * Si la valeur attendue est comprise entre la réponse - la précision et la
  * réponse + la précision, la note vaut 1
  * On effectue une règle de trois pour ramener la note correspondant au barême
  */

  float evaluate(float maximumPoints) {
    if (valeurReponse != null && valeurCorrecte != null) {
      if (NumberUtils.egaliteAvecPrecision(valeurCorrecte, valeurReponse, precision)) {
        return maximumPoints
      }
    }
    0F
  }
}