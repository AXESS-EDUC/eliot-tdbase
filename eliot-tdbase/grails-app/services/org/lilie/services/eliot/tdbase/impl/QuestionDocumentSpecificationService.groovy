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
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tice.utils.StringUtils
import org.lilie.services.eliot.tdbase.Question
import org.springframework.web.multipart.MultipartFile
import org.lilie.services.eliot.tdbase.QuestionAttachementService
import org.lilie.services.eliot.tdbase.QuestionAttachement
import org.springframework.transaction.annotation.Transactional
import org.springframework.transaction.annotation.Propagation
import org.lilie.services.eliot.tice.Attachement

/**
 *
 * @author franck Silvestre
 */
class QuestionDocumentSpecificationService implements QuestionSpecificationService {

  static transactional = false
  QuestionAttachementService questionAttachementService

  /**
   *
   * @see QuestionSpecificationService
   */
  def getObjectFromSpecification(String specification) {
    if (!specification) {
      return new DocumentSpecification()
    }
    def slurper = new JsonSlurper()
    Map map = slurper.parseText(specification)
    return new DocumentSpecification(map)
  }

  /**
   *
   * @see QuestionSpecificationService
   */
  String getSpecificationFromObject(Object object) {
    if (!(object instanceof DocumentSpecification)) {
      throw new IllegalArgumentException(
              "objet ${object} n'est pas de type DocumentSpecification")
    }
    DocumentSpecification spec = object
    JsonBuilder builder = new JsonBuilder(spec.toMap())
    return builder.toString()
  }

  /**
   *
   * @see QuestionSpecificationService
   */
  String getSpecificationNormaliseFromObject(Object object) {
    if (!(object instanceof DocumentSpecification)) {
      throw new IllegalArgumentException(
              "objet ${object} n'est pas de typeDocumentSpecification")
    }
    DocumentSpecification spec = object
    String toNormalise = spec.presentation
    if (toNormalise) {
      return StringUtils.normalise(toNormalise)
    }
    return null
  }

  /**
   *
   * @see QuestionSpecificationService
   */
  @Transactional
  def updateQuestionSpecificationForObject(Question question, Object object) {
     if (!(object instanceof DocumentSpecification)) {
      throw new IllegalArgumentException(
              "objet ${object} n'est pas de type DocumentSpecification")
    }
    DocumentSpecification spec = object
    if (spec.fichier) {
       def questionAttachement = questionAttachementService.createAttachementForQuestion(
               spec.fichier,question)
      def oldQuestAttId = question.specificationObject?.questionAttachementId
      if (oldQuestAttId) {
        questionAttachementService.deleteQuestionAttachement(
                QuestionAttachement.get(oldQuestAttId))
      }
      spec.questionAttachementId = questionAttachement.id
    }

    question.specification = getSpecificationFromObject(object)
    question.specificationNormalise = getSpecificationNormaliseFromObject(object)
    question.save()
  }


}

/**
 * Représente un objet spécification pour une question de type Document
 */
class DocumentSpecification {
  String auteur
  String source
  String presentation
  String type
  String urlExterne
  Long questionAttachementId
  boolean estInsereDansLeSujet
  MultipartFile fichier

  DocumentSpecification() {
    super()
  }

  DocumentSpecification(Map map) {
    this.auteur = map.auteur
    this.source = map.source
    this.presentation = map.presentation
    this.type = map.type
    this.urlExterne = map.urlExterne
    this.questionAttachementId = map.questionAttachementId
    this.estInsereDansLeSujet = map.estInsereDansLeSujet
  }

  Map toMap() {
    [
            auteur: auteur,
            source: source,
            presentation: presentation,
            type: type,
            urlExterne: urlExterne,
            questionAttachementId: questionAttachementId,
            estInsereDansLeSujet: estInsereDansLeSujet
    ]
  }

  /**
   * Retourne l'attachement correspondant
   * @return l'attachement
   */
  Attachement getAttachement() {
    if (questionAttachementId) {
      QuestionAttachement questionAttachement = QuestionAttachement.get(questionAttachementId)
      return questionAttachement.attachement
    } else {
      return null
    }
  }

}

enum DocumentTypeEnum {
  TEXTE,
  GRAPHIQUE,
  TABLEAU,
  APPLET

  String getName() {
    return name()
  }
}
