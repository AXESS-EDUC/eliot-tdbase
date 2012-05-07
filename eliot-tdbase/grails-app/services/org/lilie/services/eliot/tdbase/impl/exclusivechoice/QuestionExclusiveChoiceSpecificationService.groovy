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

import grails.validation.Validateable
import org.lilie.services.eliot.tdbase.QuestionSpecification
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tdbase.QuestionTypeEnum

/**
 *
 * @author franck Silvestre
 */
class QuestionExclusiveChoiceSpecificationService extends QuestionSpecificationService<ExclusiveChoiceSpecification> {

  @Override
  ExclusiveChoiceSpecification createSpecification(Map map) {
    new ExclusiveChoiceSpecification(map)
  }

}

/**
 * Représente un objet spécification pour une question de type MultipleChoice
 */
@Validateable
class ExclusiveChoiceSpecification implements QuestionSpecification {
  /**
   * Le code du type de la question.
   */
  String questionTypeCode = QuestionTypeEnum.ExclusiveChoice.name()

  /**
   * Le libellé.
   */
  String libelle

  /**
   * La correction de la question.
   */
  String correction

  /**
   * Indique si les differents réponses doivent être presentés de manière aléatoire.
   */
  boolean shuffled = false

  String indexBonneReponse

  /**
   * La liste des réponses.
   */
  List<ExclusiveChoiceSpecificationReponsePossible> reponses = []

  /**
   * Constructeur par défaut.
   */
  ExclusiveChoiceSpecification() {
    super()
  }

  /**
   * Créer et initialise un nouvel objet de type ExclusiveChoiceSpecification
   * @param map la map permettant d'initialiser l'objet en cours
   * de création
   */
  ExclusiveChoiceSpecification(Map map) {
    libelle = map.libelle
    correction = map.correction
    indexBonneReponse = map.indexBonneReponse
    reponses = map.reponses.collect {createReponsePossibles it}
    shuffled = map.shuffled
    indexBonneReponse = map.indexBonneReponse
  }

  def Map toMap() {
    [questionTypeCode: questionTypeCode,
            libelle: libelle,
            correction: correction,
            reponses: reponses*.toMap(),
            indexBonneReponse: indexBonneReponse,
            shuffled: shuffled]
  }

  List<ExclusiveChoiceSpecificationReponsePossible> getReponsesAleatoires() {
    def result = reponses
    Collections.shuffle(result)
    result
  }

  static constraints = {
    libelle blank: false
    reponses minSize: 2, validator: { val, obj ->
      if (!obj.indexBonneReponse) {
        return ['pasdebonnereponse']
      }
    }
  }

  private createReponsePossibles(ExclusiveChoiceSpecificationReponsePossible reponse) {
    reponse
  }

  private createReponsePossibles(Map params) {
    new ExclusiveChoiceSpecificationReponsePossible(params)
  }
}

/**
 * Représente un objet réponse possible de la spécification  pour une question de
 * type MultipleChoice
 */
class ExclusiveChoiceSpecificationReponsePossible {
  /**
   * Libelle de la reponse
   */
  String libelleReponse

  /**
   * L'id de la reponse
   */
  String id

  /**
   * Constructeur par defaut.
   */
  ExclusiveChoiceSpecificationReponsePossible() {
    super()
  }

  /**
   * Créer et initialise un nouvel objet de type ExclusiveChoiceSpecificationReponsePossible
   * @param map la map permettant d'initialiser l'objet en cours
   * de création
   */
  ExclusiveChoiceSpecificationReponsePossible(Map map) {
    libelleReponse = map.libelleReponse
    id = map.id
  }

  def toMap() {
    [libelleReponse: libelleReponse,
            id: id]
  }
}