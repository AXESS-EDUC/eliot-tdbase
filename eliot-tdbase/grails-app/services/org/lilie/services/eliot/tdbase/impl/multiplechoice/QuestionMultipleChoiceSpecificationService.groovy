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

import grails.validation.Validateable
import org.lilie.services.eliot.tdbase.QuestionSpecification
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tdbase.QuestionTypeEnum

/**
 *
 * @author franck Silvestre
 */
class QuestionMultipleChoiceSpecificationService extends QuestionSpecificationService<MultipleChoiceSpecification> {
  @Override
  MultipleChoiceSpecification createSpecification(Map map) {
    new MultipleChoiceSpecification(map)
  }
}

/**
 * Représente un objet spécification pour une question de type MultipleChoice
 */
@Validateable
class MultipleChoiceSpecification implements QuestionSpecification {

  /**
   * Le code du type de la question.
   */
  String questionTypeCode = QuestionTypeEnum.MultipleChoice.name()

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

  /**
   * Les reponses.
   */
  List<MultipleChoiceSpecificationReponsePossible> reponses = []

  /**
   * Constructeur par défaut.
   */
  MultipleChoiceSpecification() {
    super()
  }

  /**
   * Créer et initialise un nouvel objet de type MultipleChoiceSpecification
   * @param map la map permettant d'initialiser l'objet en cours
   * de création
   */
  MultipleChoiceSpecification(Map map) {
    libelle = map.libelle
    correction = map.correction
    reponses = map.reponses.collect {createReponsePossibles(it)}
    shuffled = map.shuffled
  }

  def Map toMap() {
    [questionTypeCode: questionTypeCode,
            libelle: libelle,
            correction: correction,
            reponses: reponses*.toMap(),
            shuffled: shuffled]
  }

  List<MultipleChoiceSpecificationReponsePossible> getReponsesAleatoires() {
    def result = reponses
    Collections.shuffle(result)
    result
  }

  static constraints = {
    libelle blank: false
    reponses minSize: 2 , validator: {
             if (!auMoinsUneReponsePossible(it)) {
               return  ['pasdebonnereponse']
             }
    }
  }

  private createReponsePossibles(MultipleChoiceSpecificationReponsePossible reponse) {
    reponse
  }

  private createReponsePossibles(Map params) {
    new MultipleChoiceSpecificationReponsePossible(params)
  }

  /**
   * Indique si au moins une réponse possible est bonne
   * @return true si il y a au moins une bonne reponse
   */
  private static boolean auMoinsUneReponsePossible(def reponsesPossibles) {
    def res = false
    if (reponsesPossibles) {
      for (int i = 0; i < reponsesPossibles.size(); i++) {
        if (reponsesPossibles[i].estUneBonneReponse) {
          res = true
          break
        }
      }
    }
    res
  }
}

/**
 * Représente un objet réponse possible de la spécification  pour une question de
 * type MultipleChoice
 */
class MultipleChoiceSpecificationReponsePossible {
  String libelleReponse
  boolean estUneBonneReponse
  String id

  MultipleChoiceSpecificationReponsePossible() {
    super()
  }

  /**
   * Créer et initialise un nouvel objet de type MultipleChoiceSpecificationReponsePossible
   * @param map la map permettant d'initialiser l'objet en cours
   * de création
   */
  MultipleChoiceSpecificationReponsePossible(Map map) {
    libelleReponse = map.libelleReponse
    estUneBonneReponse = map.estUneBonneReponse
    id = map.id
  }

  def toMap() {
    [libelleReponse: libelleReponse,
            estUneBonneReponse: estUneBonneReponse,
            id: id]
  }

}