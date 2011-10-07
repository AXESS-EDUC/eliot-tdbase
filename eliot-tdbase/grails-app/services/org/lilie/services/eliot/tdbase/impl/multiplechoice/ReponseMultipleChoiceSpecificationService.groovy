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

import groovy.json.JsonBuilder
import groovy.json.JsonSlurper
import org.gcontracts.annotations.Requires
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.Reponse
import org.lilie.services.eliot.tdbase.ReponseSpecificationService
import org.springframework.transaction.annotation.Transactional

/**
 *
 * @author franck Silvestre
 */
class ReponseMultipleChoiceSpecificationService implements ReponseSpecificationService {

  static transactional = false

  /**
   *
   * @see ReponseSpecificationService
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
   * @see ReponseSpecificationService
   */
  @Requires({object instanceof ReponseMultipleChoiceSpecification})
  String getSpecificationFromObject(Object object) {
    ReponseMultipleChoiceSpecification spec = object
    JsonBuilder builder = new JsonBuilder(spec.toMap())
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
  @Requires({question.specificationObject instanceof MultipleChoiceSpecification})
  def getObjectInitialiseFromSpecification(Question question) {
    def questSpecObj = question.specificationObject
    def reponsesPossibles = questSpecObj.reponses
    ReponseMultipleChoiceSpecification specObj = new ReponseMultipleChoiceSpecification()
    reponsesPossibles.each {
      specObj.reponses << new MultipleChoiceSpecificationReponsePossible(
              libelleReponse: it.libelleReponse,
              estUneBonneReponse: false
      )
    }
    return specObj
  }

  /**
   * Si il n'y a aucune réponse explicite (pas de cases cochées), la notes est 0.
   * Si il y a au moins une réponse explicite (une case cochée), alors :
   * - pour chaque réponse juste on ajoute un point
   * - pour chaque réponse fausse on retranche un point
   * On effectue une règle de trois pour ramener la note correspondant au barême
   *
   * @see ReponseSpecificationService
   */
  @Transactional
  Float evalueReponse(Reponse reponse) {
    def res = 0
    boolean aucuneReponse = true
    ReponseMultipleChoiceSpecification repSpecObj = reponse.specificationObject
    MultipleChoiceSpecification questSpecObj = reponse.sujetQuestion.question.specificationObject
    def nbRepPos = repSpecObj.reponses.size()
    for (int i = 0; i < nbRepPos; i++) {
      MultipleChoiceSpecificationReponsePossible repPos = repSpecObj.reponses[i]
      MultipleChoiceSpecificationReponsePossible repPosQ = questSpecObj.reponses[i]
      if (repPos.libelleReponse != repPosQ.libelleReponse) {
        log.info("Libelles reponses incohérent : ${repPos.libelleReponse} <> ${repPosQ.libelleReponse}")
      }
      if (repPos.estUneBonneReponse) {
        aucuneReponse = false
      }
      if (repPos.estUneBonneReponse == repPosQ.estUneBonneReponse) {
        res +=  1
      } else {
        res += -1
      }
    }
    if (aucuneReponse) { // si aucune reponse, l'eleve n'a pas repondu, il a 0
      res = 0
    } else { // sinon on décompte avec points positifs et/ou négatifs
      res = (res / nbRepPos) * reponse.sujetQuestion.points
    }
    reponse.correctionNoteAutomatique = res
    reponse.save()
    return res
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



  def toMap() {
    [
            reponses: reponses*.toMap()
    ]
  }

}