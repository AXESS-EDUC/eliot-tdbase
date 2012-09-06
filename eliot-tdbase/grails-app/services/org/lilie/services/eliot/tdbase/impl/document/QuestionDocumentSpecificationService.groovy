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
package org.lilie.services.eliot.tdbase.impl.document

import grails.validation.Validateable
import org.lilie.services.eliot.tice.Attachement
import org.lilie.services.eliot.tice.utils.StringUtils
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.multipart.MultipartFile
import org.lilie.services.eliot.tdbase.*

/**
 *
 * @author franck Silvestre
 */
class QuestionDocumentSpecificationService extends QuestionSpecificationService<DocumentSpecification> {

  QuestionAttachementService questionAttachementService

  @Override
  DocumentSpecification createSpecification(Map map) {
    return new DocumentSpecification(map);
  }

  String getSpecificationNormaliseFromObject(DocumentSpecification specification) {
    specification?.presentation ? StringUtils.normalise(specification.presentation) : null
  }

  @Transactional
  @Override
  def updateQuestionSpecificationForObject(Question question, DocumentSpecification spec) {

    def oldQuestAttId = question.specificationObject?.questionAttachementId
    def oldQuestAttach = QuestionAttachement.get(oldQuestAttId)
    if (oldQuestAttId && !oldQuestAttach) {
      // cela peut se produire quand un problème de validation est survenu
      question.specificationObject.questionAttachementId = null
    }
    spec.fichierEstVide = false
    // l'appel à "super" est necessaire avant pour la gestion d'une
    // nouvelle question
    super.updateQuestionSpecificationForObject(question, spec)

    if (spec.fichier && !spec.fichier.empty) {
      spec.urlExterne = null

      def questionAttachement = questionAttachementService.createAttachementForQuestionFromMultipartFile(
              spec.fichier, question, spec.estInsereDansLeSujet)
      if (oldQuestAttach) {
        questionAttachementService.deleteQuestionAttachement(
                oldQuestAttach)
      }
      spec.questionAttachementId = questionAttachement.id

    } else if (spec.urlExterne) {
      spec.validate()
      if (oldQuestAttach && !spec.hasErrors()) {
        questionAttachementService.deleteQuestionAttachement(
                oldQuestAttach)
      }
    }

    if (!spec.urlExterne && !spec.questionAttachementId) {
      spec.fichierEstVide = true
    }

    // l'appel à super est nécessaire après pour prise en compte du
    // questionAttachementId
    super.updateQuestionSpecificationForObject(question, spec)
  }
}

/**
 * Représente un objet spécification pour une question de type Document
 */
@Validateable
class DocumentSpecification implements QuestionSpecification {
  String questionTypeCode = QuestionTypeEnum.Document.name()

  String auteur
  String source
  String presentation
  String type
  String urlExterne
  Long questionAttachementId
  boolean estInsereDansLeSujet
  MultipartFile fichier
  boolean fichierEstVide

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
    this.fichierEstVide = map.fichierEstVide
  }

  Map toMap() {
    [
            questionTypeCode: questionTypeCode,
            auteur: auteur,
            source: source,
            presentation: presentation,
            type: type,
            urlExterne: urlExterne,
            questionAttachementId: questionAttachementId,
            estInsereDansLeSujet: estInsereDansLeSujet,
            fichierEstVide: fichierEstVide
    ]
  }

  /**
   * Retourne l'attachement correspondant
   * @return l'attachement
   */
  Attachement getAttachement() {
    if (questionAttachementId) {
      QuestionAttachement questionAttachement = QuestionAttachement.get(questionAttachementId)
      return questionAttachement?.attachement
    } else {
      return null
    }
  }

  static constraints = {
    auteur blank: false
    source blank: false
    urlExterne(nullable: true, url: true)
    fichierEstVide(validator: { val ->
      if (val) {
        return "question.document.fichier.vide"
      }
    })
  }

}

enum DocumentTypeEnum {
  TEXTE,
  GRAPHIQUE,
  TABLEAU,
  APPLET,
  JMOL

  String getName() {
    return name()
  }
}