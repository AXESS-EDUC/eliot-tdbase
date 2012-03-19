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

import org.lilie.services.eliot.tice.Attachement
import org.lilie.services.eliot.tice.AttachementService
import org.lilie.services.eliot.tice.ImageIds
import org.springframework.transaction.annotation.Propagation
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.multipart.MultipartFile

/**
 * Service de gestion des attachements questions
 * @author franck silvestre
 */
class QuestionAttachementService {

  static transactional = false

  AttachementService attachementService

  /**
   * Creer un attachement pour une question
   * @param fichier le fichier issu de la requête
   * @param question la question
   * @param proprietaire le proprietaire
   * @param rang le rang
   * @return l'objet de type QuestionAttachement
   */
  @Transactional(propagation = Propagation.REQUIRED)
  QuestionAttachement createAttachementForQuestionFromMultipartFile(MultipartFile fichier,
                                                                    Question question,
                                                                    Boolean estInsereDansLaQuestion,
                                                                    Integer rang = 1) {
    def attachement = attachementService.createAttachementForMultipartFile(
            fichier
    )
    return createAttachementForQuestion(attachement, question,
                                        estInsereDansLaQuestion, rang)
  }

  /**
   * Creer un attachement pour une question
   * @param fichier le fichier
   * @param question la question
   * @param proprietaire le proprietaire
   * @param rang le rang
   * @return l'objet de type QuestionAttachement
   */
  @Transactional(propagation = Propagation.REQUIRED)
  QuestionAttachement createAttachementForQuestionFromImageIds(ImageIds fichier,
                                                               Question question,
                                                               Boolean estInsereDansLaQuestion = true,
                                                               Integer rang = 1) {
    def attachement = attachementService.createAttachementForImageIds(
            fichier
    )
    return createAttachementForQuestion(attachement, question,
                                        estInsereDansLaQuestion, rang)
  }

  /**
   * Creer un attachement pour une question
   * @param fichier le fichier issu de la requête
   * @param question la question
   * @param proprietaire le proprietaire
   * @param rang le rang
   * @return l'objet de type QuestionAttachement
   */
  @Transactional(propagation = Propagation.REQUIRED)
  QuestionAttachement createAttachementForQuestion(Attachement attachement,
                                                   Question question,
                                                   Boolean estInsereDansLaQuestion = true,
                                                   Integer rang = 1) {
    QuestionAttachement questionAttachement = new QuestionAttachement(
            question: question,
            attachement: attachement,
            estInsereDansLaQuestion: estInsereDansLaQuestion,
            rang: rang
    )
    questionAttachement.save()
    // si l'attachement est OK, on passe l'attachement "aSupprimer" à false
    attachement.aSupprimer = false
    question.addToQuestionAttachements(questionAttachement)
    question.lastUpdated = new Date()
    question.save()
    return questionAttachement
  }

  /**
   * Supprime le question attachement
   * @param questionAttachement l'objet représentant l'attachement à la question
   */
  @Transactional
  def deleteQuestionAttachement(QuestionAttachement questionAttachement) {
    def question = questionAttachement.question
    def attachement = questionAttachement.attachement
    question.removeFromQuestionAttachements(questionAttachement)
    questionAttachement.delete(flush: true)
    def refCount = QuestionAttachement.countByAttachement(questionAttachement.attachement)
    if (refCount == 0) {
      attachement.delete()
    }
  }

  /**
   * Creer un attachement pour une question
   * @param fichier le fichier issu de la requête
   * @param question la question
   * @param proprietaire le proprietaire
   * @param rang le rang
   * @return l'objet de type Question
   */
  @Transactional(propagation = Propagation.REQUIRED)
  Question createPrincipalAttachementForQuestionFromMultipartFile(MultipartFile fichier,
                                                                  Question question) {
    def attachement = attachementService.createAttachementForMultipartFile(
            fichier
    )
    return createPrincipalAttachementForQuestion(attachement, question)
  }

  /**
   * Creer un attachement pour une question
   * @param fichier le fichier
   * @param question la question
   * @param proprietaire le proprietaire
   * @param rang le rang
   * @return l'objet de type Question
   */
  @Transactional(propagation = Propagation.REQUIRED)
  Question createPrincipalAttachementForQuestionFromImageIds(ImageIds fichier,
                                                             Question question) {
    def attachement = attachementService.createAttachementForImageIds(
            fichier
    )

    return createPrincipalAttachementForQuestion(attachement, question)
  }

  /**
   * Creer un attachement pour une question
   * @param fichier le fichier issu de la requête
   * @param question la question
   * @param proprietaire le proprietaire
   * @param rang le rang
   * @return l'objet de type Question
   */
  @Transactional(propagation = Propagation.REQUIRED)
  Question createPrincipalAttachementForQuestion(Attachement attachement,
                                                 Question question) {
    question.principalAttachement = attachement
    // si l'attachement est OK, on passe l'attachement "aSupprimer" à false
    attachement.aSupprimer = false
    question.lastUpdated = new Date()
    if (question.principalAttachementEstInsereDansLaQuestion == null) {
      question.principalAttachementEstInsereDansLaQuestion = true
    }
    question.save()
    return question
  }

  /**
   * Supprime le question attachement
   * @param question l'objet représentant l'attachement à la question
   */
  @Transactional
  def deletePrincipalAttachementForQuestion(Question question) {
    def attachement = question.principalAttachement
    question.principalAttachement = null
    question.lastUpdated = new Date()
    question.principalAttachementEstInsereDansLaQuestion = null
    question.save()
    def refCount = Question.countByPrincipalAttachement(attachement)
    if (refCount == 0) {
      attachement.delete()
    }
  }

}


