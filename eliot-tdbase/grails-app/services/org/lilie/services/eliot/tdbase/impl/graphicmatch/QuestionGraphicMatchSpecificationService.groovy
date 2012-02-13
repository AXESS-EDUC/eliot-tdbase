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

import grails.validation.Validateable
import org.lilie.services.eliot.tice.Attachement
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.multipart.MultipartFile
import org.lilie.services.eliot.tdbase.*

/**
 * Service des specifications de questions de type glisser-déposer.
 */
class QuestionGraphicMatchSpecificationService extends QuestionSpecificationService<GraphicMatchSpecification> {

  /**
   * Le service qui gère les pieces jointes à une question.
   */
  QuestionAttachementService questionAttachementService

  @Override
  def createSpecification(Map map) {
    new GraphicMatchSpecification(map)
  }

  @Transactional
  @Override
  def updateQuestionSpecificationForObject(Question question, GraphicMatchSpecification spec) {

    question.save()
    def oldImageId = question.specificationObject?.attachmentId
    if (spec.fichier && !spec.fichier.empty) {
      def questionAttachement = questionAttachementService.createAttachementForQuestion(
              spec.fichier, question)

      if (oldImageId) {
        questionAttachementService.deleteQuestionAttachement(
                QuestionAttachement.get(oldImageId))
      }
      spec.attachmentId = questionAttachement.id
    }

    spec.icons.each {
      def iconImageId = it.attachmentId
      if (it.fichier && !it.fichier.empty) {
        def questionAttachement = questionAttachementService.createAttachementForQuestion(
                it.fichier, question)

        if (iconImageId) {
          questionAttachementService.deleteQuestionAttachement(
                  QuestionAttachement.get(iconImageId))
        }
        it.attachmentId = questionAttachement.id
      }
    }

    super.updateQuestionSpecificationForObject(question, spec)
  }
}

/**
 * Représente un objet de spécification pour une question de type glisser-déposer.
 */
@Validateable
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
   * La liste des hotspots.
   */
  List<Hotspot> hotspots = []

  /**
   * La liste des icones associés à la question.
   */
  List<MatchIcon> icons = []

  /**
   * Un map qui lie les icones avec les hotspots.
   * [matchIconId:hotspotId]
   */
  Map<String, String> graphicMatches = [:]

  /**
   * Identifiant du fichier de l'image d'arrière plan joint à la question.
   */
  Long attachmentId

  /**
   * L'objet du fichier. Le fichier n'est pas mappé.
   * Il ne sert que pour l'echange entre IHM et controlleur.
   */
  MultipartFile fichier

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
    graphicMatches = params.graphicMatches
    attachmentId = params.attachmentId
    hotspots = params.hotspots.collect {new Hotspot(it)}
    icons = params.icons.collect {new MatchIcon(it)}
  }

  @Override
  Map toMap() {
    [
            libelle: libelle,
            correction: correction,
            graphicMatches: graphicMatches,
            attachmentId: attachmentId,
            hotspots: hotspots.collect {it.toMap()},
            icons: icons.collect {it.toMap()},
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
 * Un hotspot dans lequel une icone peut-être glissée.
 */
class Hotspot {

  /**
   * L'identifiant.
   */
  String id

  /**
   * La distance du hotspot de la bordure en haut de l'image d'arrière plan.
   */
  int topDistance = 0

  /**
   * La distance du hotspot de la bordure à la gauche de l'image d'arrière plan.
   */
  int leftDistance = 0

  /**
   * Constructeur par defaut.
   */
  Hotspot() { super()}

  /**
   * Conversion de l'objet en map.
   * @return une map des attributs de l'objet.
   */
  Map toMap() {
    [
            topDistance: topDistance,
            leftDistance: leftDistance,
            id: id
    ]
  }
}

/**
 * Une icone que l'on peut glisser dans un hotspot.
 */
class MatchIcon {

  /**
   * L'identifiant de l'icone.
   */
  String id

  Long attachmentId

  /**
   * L'objet du fichier de l'image. Cet attribut n'est pas mappé.
   * Il ne sert que pour l'echange entre IHM et controlleur.
   */
  MultipartFile fichier

  /**
   * Conversion de l'objet en map.
   * @return une map des attributs de l'objet.
   */
  Map toMap() {[id: id, attachmentId: attachmentId]}

  /**
   * Retourne l'attachement correspondant
   * @return l'attachement
   */
  Attachement getAttachment() {
    if (attachmentId) {
      return QuestionAttachement.get(attachmentId).attachement
    }
    null
  }
}