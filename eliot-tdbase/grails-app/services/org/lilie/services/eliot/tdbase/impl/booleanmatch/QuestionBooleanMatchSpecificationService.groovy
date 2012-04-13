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

import grails.validation.Validateable
import org.lilie.services.eliot.tdbase.QuestionSpecification
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tdbase.QuestionTypeEnum

/**
 * Service des specifications de questions de type booléenne.
 */
class QuestionBooleanMatchSpecificationService extends QuestionSpecificationService<BooleanMatchSpecification> {

  @Override
  BooleanMatchSpecification createSpecification(Map map) {
    new BooleanMatchSpecification(map)
  }

}

/**
 * Représente un objet spécification pour une question de type booléenne.
 */
@Validateable
class BooleanMatchSpecification implements QuestionSpecification {
  String questionTypeCode = QuestionTypeEnum.BooleanMatch.name()
  /**
   * Le libellé.
   */
  String libelle

  /**
   * La correction.
   */
  String correction

  /**
   * Les reponses
   */
  List<String> reponses = []

  /**
   * Si vrai, alors toutes les reponses donnéés
   */
  boolean toutOuRien = false

  /**
   * Constructeur par défaut.
   */
  BooleanMatchSpecification() {
    super()
  }

  /**
   * Constructeur prennant une map de paramètres.
   * @param map la map permettant d'initialiser l'objet en cours
   * de création
   */
  BooleanMatchSpecification(Map map) {
    libelle = map.libelle
    correction = map.correction
    reponses = map.reponses
    toutOuRien = map.toutOuRien
  }

  @Override
  Map toMap() {
    [
            questionTypeCode: questionTypeCode,
            libelle: libelle,
            reponses: reponses,
            correction: correction,
            toutOuRien: toutOuRien
    ]
  }

  static constraints = {
    libelle blank: false
    reponses minSize: 1
  }

}