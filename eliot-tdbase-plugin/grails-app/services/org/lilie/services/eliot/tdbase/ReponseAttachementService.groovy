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

import org.lilie.services.eliot.tice.AttachementService
import org.springframework.transaction.annotation.Propagation
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.multipart.MultipartFile

/**
 * Service de gestion des attachements de réponse
 * @author franck silvestre
 */
class ReponseAttachementService {

  static transactional = false

  AttachementService attachementService

  /**
   * Creer un attachement pour une question
   * @param fichier le fichier issu de la requête
   * @param reponse la reponse
   * @param proprietaire le proprietaire
   * @param rang le rang
   * @return l'objet de type ReponseAttachement
   */
  @Transactional(propagation = Propagation.REQUIRED)
  ReponseAttachement createAttachementForResponse(MultipartFile fichier,
                                                  Reponse reponse,
                                                  Integer rang = 1) {
    def attachement = attachementService.createAttachementForMultipartFile(
            fichier
    )
    ReponseAttachement reponseAttachement = new ReponseAttachement(
            reponse: reponse,
            attachement: attachement,
            rang: rang
    )
    reponseAttachement.save()
    // si l'attachement est OK, on passe l'attachement "aSupprimer" à false
    attachement.aSupprimer = false
    reponse.addToReponseAttachements(reponseAttachement)
    reponse.save()
    return reponseAttachement
  }

  /**
   * Supprime le reponse attachement
   * @param reponseAttachement l'objet représentant l'attachement à la reponse
   */
  @Transactional
  def deleteReponseAttachement(ReponseAttachement reponseAttachement) {
    def reponse = reponseAttachement.reponse
    def attachement = reponseAttachement.attachement
    reponse.removeFromReponseAttachements(reponseAttachement)
    reponseAttachement.delete(flush: true)
    def refCount = ReponseAttachement.countByAttachement(reponseAttachement.attachement)
    if (refCount == 0) {
      attachement.delete()
    }
  }

}


