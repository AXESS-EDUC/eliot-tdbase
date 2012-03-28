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








package org.lilie.services.eliot.tdbase.impl.fileupload

import grails.validation.Validateable
import org.lilie.services.eliot.tice.Attachement
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.multipart.MultipartFile
import org.lilie.services.eliot.tdbase.*

/**
 *
 * @author franck Silvestre
 */
class QuestionFileUploadSpecificationService extends QuestionSpecificationService<FileUploadSpecification> {

  QuestionAttachementService questionAttachementService

  /**
   *
   * @see QuestionSpecificationService
   */
  @Override
  FileUploadSpecification createSpecification(Map map) {
    return new FileUploadSpecification(map)
  }

  @Transactional
  @Override
  def updateQuestionSpecificationForObject(Question question, FileUploadSpecification spec) {

    def oldQuestAttId = question.specificationObject?.questionAttachementId
    // l'appel à "super" est necessaire avant pour la gestion d'une
    // nouvelle question
    super.updateQuestionSpecificationForObject(question, spec)

    if (spec.fichier && !spec.fichier.empty) {
      def questionAttachement = questionAttachementService.createAttachementForQuestionFromMultipartFile(
              spec.fichier, question,false)
      if (oldQuestAttId) {
        questionAttachementService.deleteQuestionAttachement(
                QuestionAttachement.get(oldQuestAttId))
      }
      spec.questionAttachementId = questionAttachement.id
    }
    // l'appel à super est nécessaire après pour prise en compte du
    // questionAttachementId
    super.updateQuestionSpecificationForObject(question, spec)
  }
}

/**
 * Représente un objet spécification pour une question de type Open
 */
@Validateable
class FileUploadSpecification implements QuestionSpecification {
  String questionTypeCode = QuestionTypeEnum.FileUpload.name()
  String libelle
  String correction
  Long questionAttachementId
  MultipartFile fichier

  FileUploadSpecification() {
    super()
  }

  /**
   * Créer et initialise un nouvel objet de type FileUploadSpecification
   * @param map la map permettant d'initialiser l'objet en cours
   * de création
   */
  FileUploadSpecification(Map map) {
    libelle = map.libelle
    correction = map.correction
    questionAttachementId = map.questionAttachementId
  }

  def Map toMap() {
    [
            questionTypeCode: questionTypeCode,
            libelle: libelle,
            questionAttachementId: questionAttachementId,
            correction: correction
    ]
  }

  static constraints = {
    libelle blank: false

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