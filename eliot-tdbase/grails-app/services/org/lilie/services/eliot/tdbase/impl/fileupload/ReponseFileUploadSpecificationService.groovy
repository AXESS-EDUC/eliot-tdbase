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

import org.lilie.services.eliot.tice.Attachement
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.multipart.MultipartFile
import org.lilie.services.eliot.tdbase.*

/**
 *
 * @author franck Silvestre
 */
class ReponseFileUploadSpecificationService extends ReponseSpecificationService<ReponseFileUploadSpecification> {

  ReponseAttachementService reponseAttachementService

  /**
   *
   * @see ReponseSpecificationService
   */
  @Override
  ReponseFileUploadSpecification createSpecification(Map map) {
    new ReponseFileUploadSpecification(map)
  }

  @Transactional
  @Override
  Reponse updateReponseSpecificationForObject(Reponse reponse, ReponseFileUploadSpecification spec) {

    def oldRepAttId = reponse.specificationObject?.reponseAttachementId
    // l'appel à "super" est necessaire avant pour la gestion d'une
    // nouvelle question
    super.updateReponseSpecificationForObject(reponse, spec)

    if (spec.fichier && !spec.fichier.empty) {
      def reponseAttachement = reponseAttachementService.createAttachementForResponse(
              spec.fichier, reponse)
      if (oldRepAttId) {
        reponseAttachementService.deleteReponseAttachement(
                ReponseAttachement.get(oldRepAttId))
      }
      spec.reponseAttachementId = reponseAttachement.id
    }
    // l'appel à super est nécessaire après pour prise en compte du
    // questionAttachementId
    super.updateReponseSpecificationForObject(reponse, spec)
  }

  /**
   * Pas de notation automatique
   *
   * @see ReponseSpecificationService
   */
  Float evalueReponse(Reponse reponse) {
    return null
  }
}

/**
 * Représente un objet spécification pour une question de type Decimal
 */
class ReponseFileUploadSpecification implements ReponseSpecification {
  String questionTypeCode = QuestionTypeEnum.FileUpload.name()

  Long reponseAttachementId
  MultipartFile fichier

  Map toMap() {
    [
            questionTypeCode: questionTypeCode,
            reponseAttachementId: reponseAttachementId
    ]
  }

  float evaluate(float maximumPoints) {
    return 0F
  }

  /**
   * Retourne l'attachement correspondant
   * @return l'attachement
   */
  Attachement getAttachement() {
    if (reponseAttachementId) {
      ReponseAttachement reponseAttachement = ReponseAttachement.get(reponseAttachementId)
      return reponseAttachement.attachement
    } else {
      return null
    }
  }

}