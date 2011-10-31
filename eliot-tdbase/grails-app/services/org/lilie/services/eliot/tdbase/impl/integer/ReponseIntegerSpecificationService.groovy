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

import groovy.json.JsonBuilder
import groovy.json.JsonSlurper
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.Reponse
import org.lilie.services.eliot.tdbase.ReponseSpecificationService
import org.springframework.transaction.annotation.Transactional

import org.lilie.services.eliot.tice.utils.NumberUtils
import org.lilie.services.eliot.tdbase.impl.decimal.DecimalSpecification

/**
 *
 * @author franck Silvestre
 */
class ReponseIntegerSpecificationService implements ReponseSpecificationService {

  static transactional = false

  /**
   *
   * @see ReponseSpecificationService
   */
  def getObjectFromSpecification(String specification) {
    if (!specification) {
      return new ReponseIntegerSpecification()
    }
    def slurper = new JsonSlurper()
    Map map = slurper.parseText(specification)
    return new ReponseIntegerSpecification(map)
  }

  /**
   *
   * @see ReponseSpecificationService
   */
  String getSpecificationFromObject(Object object) {

    assert(object instanceof ReponseIntegerSpecification)

    JsonBuilder builder = new JsonBuilder(object.toMap())
    return builder.toString()
  }

  /**
   *
   * @see ReponseSpecificationService
   */
  def updateReponseSpecificationForObject(Reponse reponse, Object object) {
    reponse.specification = getSpecificationFromObject(object)
    reponse.save()
  }

  /**
   * @see ReponseSpecificationService
   */
  def initialiseReponseSpecificationForQuestion(Reponse reponse,
                                                Question question) {
    def specObj = getObjectInitialiseFromSpecification(question)
    updateReponseSpecificationForObject(reponse, specObj)
  }

  /**
   * @see ReponseSpecificationService
   */
  def getObjectInitialiseFromSpecification(Question question) {

    assert(question.specificationObject instanceof IntegerSpecification)

    return new ReponseIntegerSpecification()
  }

  /**
   * Si il n'y a pas de réponse la note vaut 0
   * Si la valeur attendue est égale à la réponse la note vaut 1 sinon 0
   * On effectue une règle de trois pour ramener la note correspondant au barême
   *
   * @see ReponseSpecificationService
   */
  @Transactional
  Float evalueReponse(Reponse reponse) {
    def res = 0
    ReponseIntegerSpecification repSpecObj = reponse.specificationObject
    def val = repSpecObj.valeurReponse
    IntegerSpecification questSpecObj = reponse.sujetQuestion.question.specificationObject
    if (val == questSpecObj.valeur) {
        res = reponse.sujetQuestion.points
    }
    reponse.correctionNoteAutomatique = res
    reponse.save()
    return res
  }


}

/**
 * Représente un objet spécification pour une question de type Decimal
 */
class ReponseIntegerSpecification {

  Integer valeurReponse

  ReponseIntegerSpecification() {
    super()
  }

  /**
   * Créer et initialise un nouvel objet de type RepoonseDecimalSpecification
   * @param map la map permettant d'initialiser l'objet en cours
   * de création
   */
  ReponseIntegerSpecification(Map map) {
    valeurReponse = map.valeurReponse
  }



  def toMap() {
    [
            valeurReponse: valeurReponse
    ]
  }

}