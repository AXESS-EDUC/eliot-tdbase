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

package org.lilie.services.eliot.tdbase.impl.associate

import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.ReponseSpecification
import org.lilie.services.eliot.tdbase.ReponseSpecificationService
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.QuestionSpecification

/**
 * Service pour les specifications de reponses de type associate.
 */
class ReponseAssociateSpecificationService extends ReponseSpecificationService<ReponseAssociateSpecification> {


  @Override
  ReponseAssociateSpecification createSpecification(Map map) {
    new ReponseAssociateSpecification(map)
  }

  @Override
  ReponseAssociateSpecification getObjectInitialiseFromSpecification(QuestionSpecification questionSpecification) {

    AssociateSpecification specification = questionSpecification
    List<Association> valeursReponse = []
    def association

    specification.associations.each {
      if (specification.montrerColonneAGauche) {
        association = new Association()
        association.participant1 = it.participant1
        association.participant2 = ''
        valeursReponse << association
      } else {
        valeursReponse << new Association()
      }
    }

    new ReponseAssociateSpecification(valeursDeReponse: valeursReponse, reponsesPossibles: specification.associations)
  }
}

/**
 * Specifications de reponses de type associate.
 */
class ReponseAssociateSpecification implements ReponseSpecification {

  String questionTypeCode = QuestionTypeEnum.Associate.name()

  /**
   * Liste d'associations fournis comme reponse à la question.
   */
  List<Association> valeursDeReponse = []

  /**
   * Liste d'associations qui forment une reponse correcte.
   */
  List<Association> reponsesPossibles = []

  /**
   * Constructeur par defaut
   */
  ReponseAssociateSpecification() {
    super()
  }

  ReponseAssociateSpecification(Map params) {
    valeursDeReponse = params.valeursDeReponse.collect {createAssociation(it)}
    reponsesPossibles = params.reponsesPossibles.collect {createAssociation(it)}
  }

  @Override
  Map toMap() {
    [
            questionTypeCode: questionTypeCode,
            valeursDeReponse: valeursDeReponse,
            reponsesPossibles: reponsesPossibles
    ]
  }

  private createAssociation(Association association) {
    association
  }

  private createAssociation(Map params) {
    new Association(params)
  }

  @Override
  float evaluate(float maximumPoints) {
    int reponsesCorrects = 0
    int numberRes = valeursDeReponse.size()

    def localReponsesPossibles = []
    localReponsesPossibles.addAll(reponsesPossibles)

    valeursDeReponse.each {
      if (localReponsesPossibles.contains(it)) {
        reponsesCorrects++
        localReponsesPossibles.remove(it)
      }
    }
    reponsesCorrects / numberRes * maximumPoints
  }
}