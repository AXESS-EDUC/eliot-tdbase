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

import grails.validation.Validateable
import org.lilie.services.eliot.tdbase.QuestionSpecification
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tice.utils.NumberUtils

/**
 *
 * @author franck Silvestre
 */
class QuestionDecimalSpecificationService extends QuestionSpecificationService<DecimalSpecification> {

  @Override
  DecimalSpecification createSpecification(Map map) {
    new DecimalSpecification(map)
  }

}

/**
 * Représente un objet spécification pour une question de type Decimal
 */
@Validateable
class DecimalSpecification implements QuestionSpecification {
  String questionTypeCode = QuestionTypeEnum.Decimal.name()
  String libelle
  Float valeur
  String unite
  Float precision = 0
  String correction


  DecimalSpecification() {
    super()
  }

  /**
   * Créer et initialise un nouvel objet de type MultipleChoiceSpecification
   * @param map la map permettant d'initialiser l'objet en cours
   * de création
   */
  DecimalSpecification(Map map) {
    libelle = map.libelle
    valeur = map.valeur
    unite = map.unite
    precision = map.precision
    correction = map.correction
  }

  Map toMap() {
    [
            questionTypeCode: questionTypeCode,
            libelle: libelle,
            valeur: valeur,
            unite: unite,
            precision: precision,
            correction: correction
    ]
  }

  String getValeurAffichage() {
    if (valeur != null) {
      return NumberUtils.formatFloat(valeur)
    }
    return null
  }

  String getPrecisionAffichage() {
    if (precision != null) {
      return NumberUtils.formatFloat(precision)
    }
    return null
  }

  static constraints = {
    libelle blank: false
    valeur nullable: false
  }

}