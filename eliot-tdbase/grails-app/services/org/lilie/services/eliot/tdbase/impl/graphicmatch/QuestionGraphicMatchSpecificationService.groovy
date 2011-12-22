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

package org.lilie.services.eliot.tdbase.impl.graphicmatch

import org.lilie.services.eliot.tice.Attachement
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.multipart.MultipartFile
import org.lilie.services.eliot.tdbase.*

/**
 * Service des specifications de questions de type graphique à compléter. 
 */
class QuestionGraphicMatchSpecificationService extends QuestionSpecificationService<GraphicMatchSpecification> {

  /**
   * Le service qui gère les pieces jointes à une question.
   */
  QuestionAttachementService questionAttachementService

  @Override
  def createSpecification(Object map) {
    new GraphicMatchSpecification(map)
  }

  @Transactional
  @Override
  def updateQuestionSpecificationForObject(Question question, GraphicMatchSpecification spec) {

    def oldQuestAttId = question.specificationObject?.attachmentId
    if (spec.fichier && !spec.fichier.empty) {
      def questionAttachement = questionAttachementService.createAttachementForQuestion(
              spec.fichier, question)

      if (oldQuestAttId) {
        questionAttachementService.deleteQuestionAttachement(
                QuestionAttachement.get(oldQuestAttId))
      }

      spec.attachmentId = questionAttachement.id
    }

    super.updateQuestionSpecificationForObject(question, spec)
  }
}

/**
 * Représente un objet de spécification pour une question de type graphique à completer
 */
class GraphicMatchSpecification implements QuestionSpecification {

  /**
   * Le libellé.
   */
  String libelle

  /**
   * La correction.
   */
  String correction

  /**
   * La liste des text fields.
   */
  List<TextField> textFields = []

  /**
   * Identifiant de l'attachement de fichier graphique à la question.
   */
  Long attachmentId

  /**
   * L'objet du fichier. Le fichier n'est pas mappé.
   * Il ne sert que pour l'echange entre IHM et controlleur.
   */
  MultipartFile fichier // dont map this

  /**
   * Constructeur par defaut.
   */
  GraphicMatchSpecification() {
    super()
  }

  /**
   * Constructeur prennant une map de paramètres.
   */
  GraphicMatchSpecification(Map params) {
    libelle = params.libelle
    correction = params.correction
    textFields = params.textFields.collect {new TextField(it)}
    attachmentId = params.attachmentId
  }

  @Override
  Map toMap() {
    [
            libelle: libelle,
            correction: correction,
            textFields: textFields.collect {it.toMap()},
            attachmentId: attachmentId
    ]
  }

  /**
   * Retourne l'attachement correspondant
   * @return l'attachement
   */
  Attachement getAttachement() {
    if (attachmentId) {
      return QuestionAttachement.get(attachmentId).attachement
    }
    null
  }
}

/**
 * Class qui represente un champ de text au sein d'un graphique 
 * à compléter.
 */
class TextField {

  /**
   * La distance de la bordure en haut de l'image.
   */
  int topDistance = 0

  /**
   * La distance de la bordure à la gauche de l'image.
   */
  int leftDistance = 0

  /**
   * La taille horizontale.
   */
  int hSize = 100

  /**
   * La taille verticale.
   */
  int vSize = 50

  /**
   * Le texte de l'element.
   */
  String text

  Map toMap() {
    [topDistance: topDistance, leftDistance: leftDistance, hSize: hSize, vSize: vSize, text: text]
  }

  @Override
  boolean equals(Object object) {
    if (object != null && object instanceof TextField) {
      TextField theOther = object
      return text == theOther.text
    }
    false
  }

  @Override
  int hashCode() {
    31 + (text == null ? 0 : text.hashCode())
  }

}