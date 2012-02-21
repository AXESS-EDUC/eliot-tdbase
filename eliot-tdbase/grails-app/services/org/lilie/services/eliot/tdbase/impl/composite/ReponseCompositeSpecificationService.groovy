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

package org.lilie.services.eliot.tdbase.impl.composite

import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionType
import org.lilie.services.eliot.tdbase.ReponseSpecification
import org.lilie.services.eliot.tdbase.ReponseSpecificationService
import org.springframework.context.ApplicationContext
import org.springframework.context.ApplicationContextAware
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.QuestionSpecification

/**
 *
 * @author franck Silvestre
 */
class ReponseCompositeSpecificationService extends ReponseSpecificationService<ReponseCompositeSpecification>
implements ApplicationContextAware {

  ApplicationContext applicationContext

  /**
   * Récupère le service de gestion de spécification de réponse correspondant
   * au type de question passé en paramètre
   * @param questionType le type de question
   * @return le service ad-hoc pour le type de question
   */
  ReponseSpecificationService reponseSpecificationServiceForQuestionType(QuestionType questionType) {
    return applicationContext.getBean("reponse${questionType.code}SpecificationService")
  }

  @Override
  ReponseCompositeSpecification createSpecification(Map map) {
    new ReponseCompositeSpecification(map)
  }

  @Override
  ReponseCompositeSpecification getObjectInitialiseFromSpecification(QuestionSpecification questionSpecification) {
    CompositeSpecification compositeSpecification = questionSpecification
    def repCompositeSpec = new ReponseCompositeSpecification()
    compositeSpecification.questionSpecificationList.each {
      // il faut le type d'item dans la reponseSpec et dans la questionSpec
      def repSpecService = reponseSpecificationServiceForQuestionType(it.questionTypeCode)
      repCompositeSpec.reponseSpecificationList << repSpecService.getObjectInitialiseFromSpecification(it)
    }
    repCompositeSpec
  }
}

/**
 * Représente un objet spécification pour une question de type Composite.
 */
class ReponseCompositeSpecification implements ReponseSpecification {
  
  String questionTypeCode = QuestionTypeEnum.Composite.name()

  List<ReponseSpecification> reponseSpecificationList = []

  /**
   * Constructeur par defaut
   */
  ReponseCompositeSpecification() {}

  /**
   * Créer et initialise un nouvel objet de type Specification
   * @param map la map permettant d'initialiser l'objet en cours
   * de création
   */
  ReponseCompositeSpecification(Map map) {
    def reponses = map.reponses
    reponses.each {
      def constructor = Class.forName(it.reponseClassName).
              getConstructor([Map] as Class[])
      def repSpec = constructor.newInstance(it.reponseMap)
      reponseSpecificationList << repSpec
    }
  }

  Map toMap() {
    def reponseMaps = []
    reponseSpecificationList.each {
      def reponseMap = [reponseClassName: it.class.name, reponseMap: it.toMap()]
      reponseMaps << reponseMap
    }
    [reponses: reponseMaps]
  }

  /*On fait la somme des evaluations des reponses imbriquées
  */

  float evaluate(float maximumPoints) {
    def val = 0F
    reponseSpecificationList.each {
      val += it.evaluate(1)
    }
    val * maximumPoints
  }
}