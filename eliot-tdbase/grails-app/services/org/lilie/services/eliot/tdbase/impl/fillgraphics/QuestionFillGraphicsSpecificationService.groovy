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
package org.lilie.services.eliot.tdbase.impl.fillgraphics

import grails.validation.Validateable
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.multipart.MultipartFile
import org.lilie.services.eliot.tdbase.*

/**
 * Service des specifications de questions de type graphique à compléter. 
 */
class QuestionFillGraphicsSpecificationService extends QuestionSpecificationService<FillGraphicsSpecification> {

  /**
   * Le service qui gère les pieces jointes à une question.
   */
  QuestionAttachementService questionAttachementService

  @Override
  def createSpecification(Object map) {
    new FillGraphicsSpecification(map)
  }

  @Transactional
  @Override
  def updateQuestionSpecificationForObject(Question question, FillGraphicsSpecification spec) {
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

    super.updateQuestionSpecificationForObject(question, spec)
  }
}

/**
 * Représente un objet de spécification pour une question de graphique à compléter.
 */
@Validateable
class FillGraphicsSpecification implements QuestionSpecification {

  /**
   * Le libellé.
   */
  String libelle

  /**
   * La correction.
   */
  String correction

  /**
   * La liste des zones de texte.
   */
  List<TextZone> textZones = []

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
  FillGraphicsSpecification() {
    super()
  }

  /**
   * Constructeur prennant une map de paramètres.
   */
  FillGraphicsSpecification(Map params) {
    libelle = params.libelle
    correction = params.correction
    attachmentId = params.attachmentId
    textZones = params.textZones.collect {new TextZone(it)}
  }

  @Override
  Map toMap() {
    [
            libelle: libelle,
            correction: correction,
            textZones: textZones.collect {it.toMap()}
    ]
  }

  /**
   * Contraintes de validation.
   */
  static constraints = {
    libelle blank: false
    textZones minSize: 1
  }
}

/**
 * Text zone qui est calqué sur l'image d'arrière plan.
 */
@Validateable
class TextZone {

  /**
   * L'identifiant. 
   */
  String id = ""

  /**
   * La distance du hotspot de la bordure en haut de l'image d'arrière plan.
   */
  int topDistance = 0

  /**
   * La distance du hotspot de la bordure à la gauche de l'image d'arrière plan.
   */
  int leftDistance = 0

  /**
   * La largeur de la zone de text.
   */
  int width = 50

  /**
   * La hauteur de la zone de text.
   */
  int height = 30

  /**
   * Le texte que cette zone doit afficher.
   */
  String text = ""

  /**
   * Constructeur par defaut.
   */
  TextZone() {super()}

  /**
   * Conversion de l'objet en map.
   * @return une map des attributs de l'objet.
   */
  Map toMap() {
    [
            id: id,
            topDistance: topDistance,
            leftDistance: leftDistance,
            width: width,
            height: height,
            text: text
    ]
  }

  /**
   * Contraintes de validation.
   */
  static constraints = {
    id blank: false
  }
}