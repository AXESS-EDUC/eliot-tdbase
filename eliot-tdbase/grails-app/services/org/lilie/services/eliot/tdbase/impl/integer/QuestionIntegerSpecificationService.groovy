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




package org.lilie.services.eliot.tdbase.impl.integer

import grails.validation.Validateable
import org.lilie.services.eliot.tdbase.QuestionSpecification
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tdbase.QuestionTypeEnum

/**
 *
 * @author franck Silvestre
 */
class QuestionIntegerSpecificationService extends QuestionSpecificationService<IntegerSpecification> {

  /**
   *
   * @see QuestionSpecificationService
   */
  @Override
  IntegerSpecification createSpecification(Map map) {
    return new IntegerSpecification(map)
  }
}

/**
 * Représente un objet spécification pour une question de type Integer
 */
@Validateable
class IntegerSpecification implements QuestionSpecification {
  String questionTypeCode = QuestionTypeEnum.Integer.name()
  String libelle
  Integer valeur
  String unite
  String correction


  IntegerSpecification() {
    super()
  }

  /**
   * Créer et initialise un nouvel objet de type MultipleChoiceSpecification
   * @param map la map permettant d'initialiser l'objet en cours
   * de création
   */
  IntegerSpecification(Map map) {
    libelle = map.libelle
    valeur = map.valeur
    unite = map.unite
    correction = map.correction
  }

  def Map toMap() {
    [
            questionTypeCode: questionTypeCode,
            libelle: libelle,
            valeur: valeur,
            unite: unite,
            correction: correction
    ]
  }

  static constraints = {
    libelle blank: false
    valeur nullable: false
  }

}