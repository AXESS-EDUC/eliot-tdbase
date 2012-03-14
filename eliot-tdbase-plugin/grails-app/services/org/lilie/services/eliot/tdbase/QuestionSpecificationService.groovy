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

import groovy.json.JsonBuilder
import groovy.json.JsonSlurper
import org.lilie.services.eliot.tice.utils.StringUtils

/**
 * Abstract classe décrivant le service pour la specification d'une question
 * @author franck Silvestre
 */
abstract class QuestionSpecificationService<QS extends QuestionSpecification> {

  static transactional = false

  /**
   * Récupère la specification d'une question à partir d'un objet
   * @param object l'objet encapsulant la specification
   * @return la specification
   */
  String getSpecificationFromObject(QS object) {
    new JsonBuilder(object.toMap()).toString()
  }

  /**
   * Récupère l'objet d'une spécification à partir d'un string json
   * @param specification le string en json
   * @return l'objet
   */
  QS getObjectFromSpecification(String specification) {
    if (!specification) {
      createSpecification(new HashMap())
    } else {
      createSpecification((Map) (new JsonSlurper().parseText(specification)))
    }
  }

  /**
   * Met à jour et persiste l'entité de question avec les informations de sa specification.
   * @param question l'entité de question à mettre à jour
   * @param specification la specification.
   * @return la question mise à jour.
   */
  def updateQuestionSpecificationForObject(Question question, QS specification) {
    question.specification = getSpecificationFromObject(specification)
    question.specificationNormalise = getSpecificationNormaliseFromObject(specification)
    question.save()
    return question
  }

  /**
   * Crée une spécification
   * @return la spécification
   */
  abstract QS createSpecification(Map params)

  /**
   * Récupère la specification normalisée d'une question à partir d'un objet
   * @param specification l'objet encapsulant la specification
   * @return la specification
   */
  def getSpecificationNormaliseFromObject(QS specification) {
    specification?.libelle ? StringUtils.normalise(specification.libelle) : null
  }

}