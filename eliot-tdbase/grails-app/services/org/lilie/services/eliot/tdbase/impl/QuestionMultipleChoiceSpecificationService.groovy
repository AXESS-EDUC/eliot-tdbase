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



package org.lilie.services.eliot.tdbase.impl

import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tice.utils.StringUtils
import groovy.json.JsonSlurper
import groovy.json.JsonBuilder

/**
 * 
 * @author franck Silvestre
 */
class QuestionMultipleChoiceSpecificationService implements QuestionSpecificationService {

  static transactional = false

  /**
   *
   * @see QuestionSpecificationService
   */
  def getObjectFromSpecification(String specification) {
    if (!specification) {
      return new MultipleChoiceSpecification()
    }
    def slurper = new JsonSlurper()
    Map map = slurper.parseText(specification)
    return new MultipleChoiceSpecification(map)
  }

  /**
   *
   * @see QuestionSpecificationService
   */
  String getSpecificationFromObject(Object object) {
    if (!(object instanceof MultipleChoiceSpecification)) {
      throw new IllegalArgumentException(
              "objet ${object} n'est pas de type MultipleChoiceSpecification")
    }
    MultipleChoiceSpecification spec = object
    JsonBuilder builder = new JsonBuilder(spec.toMap())
    return builder.toPrettyString()
  }

  /**
   *
   * @see QuestionSpecificationService
   */
  String getSpecificationNormaliseFromObject(Object object) {
    if (!(object instanceof MultipleChoiceSpecification)) {
      throw new IllegalArgumentException(
              "objet ${object} n'est pas de type MultipleChoiceSpecification")
    }
    MultipleChoiceSpecification spec = object
    String toNormalise = spec.libelle
    if (toNormalise) {
      return StringUtils.normalise(toNormalise)
    }
    return null
  }

}

class MultipleChoiceSpecification {
  String libelle
  String correction
  List<MultipleChoiceSpecificationReponse> reponses = []

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
    reponses = map.reponses.collect {
      if (it instanceof MultipleChoiceSpecificationReponse) {
        it
      } else {
        new MultipleChoiceSpecificationReponse(it)
      }
    }
  }

  def toMap() {
    [
            libelle: libelle,
            correction: correction,
            reponses : reponses*.toMap()
    ]
  }

}

class MultipleChoiceSpecificationReponse {
  String libelleReponse
  boolean estUneBonneReponse
  Float rang

  MultipleChoiceSpecificationReponse() {
    super()
  }

  /**
   * Créer et initialise un nouvel objet de type MultipleChoiceSpecificationReponse
   * @param map la map permettant d'initialiser l'objet en cours
   * de création
   */
  MultipleChoiceSpecificationReponse(Map map) {
    libelleReponse = map.libelleReponse
    estUneBonneReponse = map.estUneBonneReponse
    rang = map.rang
  }

  def toMap() {
    [
            libelleReponse: libelleReponse,
            estUneBonneReponse: estUneBonneReponse,
            rang: rang
    ]
  }
}