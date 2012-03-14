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
import org.springframework.transaction.annotation.Transactional

/**
 * Interface décrivant le service pour la specification d'une réponse
 * @author franck Silvestre
 */
public abstract class ReponseSpecificationService<R extends ReponseSpecification> {

  static transactional = false

  /**
   * Récupère la specification d'une réponse à partir d'un objet
   * @param reponseSpecObject l'objet encapsulant la specification
   * @return la specification
   */
  String getSpecificationFromObject(R reponseSpecObject) {
    new JsonBuilder(reponseSpecObject.toMap()).toString()
  }

  /**
   * Récupère l'objet encapsulant la specification d'une réponse à partir de
   * la spécification
   * @param specification la specification
   * @return l'objet encapsulant la specification
   */
  R getObjectFromSpecification(String specification) {
    if (!specification) {
      createSpecification(new HashMap())
    } else {
      createSpecification new JsonSlurper().parseText(specification)
    }
  }

  /**
   * Crée une spécification
   * @return la spécification
   */
  abstract R createSpecification(Map map)

  /**
   * Récupère un objet specification de réponse initialisé à partir d'une
   * question
   * @param question la question
   * @return l'objet specification initialisé
   */
  R getObjectInitialiseFromSpecification(QuestionSpecification questionSpecification) {
    return createSpecification(new HashMap())
  }

  /**
   * Met à jour la specification de la question
   * @param reponse la reponse
   * @param reponseSpecObject l'objet encapsulant la specification
   */
  Reponse updateReponseSpecificationForObject(Reponse reponse, R reponseSpecObject) {
    reponse.specification = getSpecificationFromObject(reponseSpecObject)
    reponse.save()
    return reponse
  }

  /**
   * Initialisele spécification d'une réponse à partir d'une question
   * @param reponse la réponse
   * @param question la question
   * @return
   */
  Reponse initialiseReponseSpecificationForQuestion(Reponse reponse,
                                                    Question question) {
    updateReponseSpecificationForObject(reponse, getObjectInitialiseFromSpecification(question.specificationObject))
  }

  /**
   * Calcule le nombre de points obtenu par la réponse et met à jour la note
   * issue de la correction automatique de la réponse
   * @param reponse la réponse à évaluer
   * @return le nombre de points obtenus pour cette réponse
   */
  @Transactional
  Float evalueReponse(Reponse reponse) {
    R repSpecObj = reponse.specificationObject
    reponse.correctionNoteAutomatique = repSpecObj.evaluate(reponse.sujetQuestion.points)
    reponse.save()
    return reponse.correctionNoteAutomatique
  }
}