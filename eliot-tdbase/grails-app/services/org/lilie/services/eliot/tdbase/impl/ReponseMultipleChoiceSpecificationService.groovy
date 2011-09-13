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

import groovy.json.JsonBuilder
import groovy.json.JsonSlurper
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tice.utils.StringUtils
import org.lilie.services.eliot.tdbase.ReponseSpecificationService
import org.lilie.services.eliot.tdbase.Reponse

/**
 *
 * @author franck Silvestre
 */
class ReponseMultipleChoiceSpecificationService implements ReponseSpecificationService{

  static transactional = false


  /**
   *
   * @see QuestionSpecificationService
   */
  def getObjectFromSpecification(String specification) {
    if (!specification) {
      return new ReponseMultipleChoiceSpecification()
    }
    def slurper = new JsonSlurper()
    Map map = slurper.parseText(specification)
    return new ReponseMultipleChoiceSpecification(map)
  }

  /**
   *
   * @see QuestionSpecificationService
   */
  String getSpecificationFromObject(Object object) {
    if (!(object instanceof ReponseMultipleChoiceSpecification)) {
      throw new IllegalArgumentException(
              "objet ${object} n'est pas de type ReponseMultipleChoiceSpecification")
    }
    ReponseMultipleChoiceSpecification spec = object
    JsonBuilder builder = new JsonBuilder(spec.toMap())
    return builder.toString()
  }



  /**
   *
   * @see QuestionSpecificationService
   */
  def updateReponseSpecificationForObject(Reponse reponse, Object object) {
    reponse.specification = getSpecificationFromObject(object)
    reponse.save()
  }

}

/**
 * Représente un objet spécification pour une question de type MultipleChoice
 */
class ReponseMultipleChoiceSpecification {

  List<MultipleChoiceSpecificationReponsePossible> reponses = []

  ReponseMultipleChoiceSpecification() {
    super()
  }

  /**
   * Créer et initialise un nouvel objet de type RepoonseMultipleChoiceSpecification
   * @param map la map permettant d'initialiser l'objet en cours
   * de création
   */
  ReponseMultipleChoiceSpecification(Map map) {
    reponses = map.reponses.collect {
      if (it instanceof MultipleChoiceSpecificationReponsePossible) {
        it
      } else {
        new MultipleChoiceSpecificationReponsePossible(it)
      }
    }
  }

  /**
   * Détermine si une réponse est contenue dans la liste des réponses
   * @param libelleReponsePossible   le libelle de la réponse possible
   * @return  true si la liste des réponses contient la reponse possible
   */
  boolean contientReponsePossible(String libelleReponsePossible) {
    return libelleReponsePossible in reponses*.libelleReponse
  }

  def toMap() {
    [
            reponses: reponses*.toMap()
    ]
  }

}