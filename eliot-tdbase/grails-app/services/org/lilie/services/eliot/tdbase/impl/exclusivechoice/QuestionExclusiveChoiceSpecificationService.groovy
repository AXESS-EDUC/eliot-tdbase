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

import groovy.json.JsonBuilder
import groovy.json.JsonSlurper
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tice.utils.StringUtils
import org.lilie.services.eliot.tdbase.Question
import org.gcontracts.annotations.Requires

/**
 *
 * @author franck Silvestre
 */
class QuestionExclusiveChoiceSpecificationService implements QuestionSpecificationService {

  static transactional = false


  /**
   *
   * @see QuestionSpecificationService
   */
  def getObjectFromSpecification(String specification) {
    if (!specification) {
      return new ExclusiveChoiceSpecification()
    }
    def slurper = new JsonSlurper()
    Map map = slurper.parseText(specification)
    return new ExclusiveChoiceSpecification(map)
  }

  /**
   *
   * @see QuestionSpecificationService
   */
  @Requires({object instanceof ExclusiveChoiceSpecification})
  String getSpecificationFromObject(Object object) {
    JsonBuilder builder = new JsonBuilder(object.toMap())
    return builder.toString()
  }

  /**
   *
   * @see QuestionSpecificationService
   */
  @Requires({object instanceof ExclusiveChoiceSpecification})
  String getSpecificationNormaliseFromObject(Object object) {
    String toNormalise = object.libelle
    if (toNormalise) {
      return StringUtils.normalise(toNormalise)
    }
    return null
  }

  /**
   *
   * @see QuestionSpecificationService
   */
  def updateQuestionSpecificationForObject(Question question, Object object) {
    question.specification = getSpecificationFromObject(object)
    question.specificationNormalise = getSpecificationNormaliseFromObject(object)
    question.save()
  }

}

/**
 * Représente un objet spécification pour une question de type MultipleChoice
 */
class ExclusiveChoiceSpecification {
  String libelle
  String correction
  List<ExclusiveChoiceSpecificationReponsePossible> reponses = []
  Integer indexBonneReponse

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
    reponses = map.reponses.collect {
      if (it instanceof ExclusiveChoiceSpecificationReponsePossible) {
        it
      } else {
        new ExclusiveChoiceSpecificationReponsePossible(it)
      }
    }
  }

  def toMap() {
    [
            libelle: libelle,
            correction: correction,
            reponses: reponses*.toMap(),
            indexBonneReponse: indexBonneReponse
    ]
  }

}

/**
 * Représente un objet réponse possible de la spécification  pour une question de
 * type MultipleChoice
 */
class ExclusiveChoiceSpecificationReponsePossible {
  String libelleReponse
  Float rang

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
    rang = map.rang
  }

  def toMap() {
    [
            libelleReponse: libelleReponse,
            rang: rang
    ]
  }
}