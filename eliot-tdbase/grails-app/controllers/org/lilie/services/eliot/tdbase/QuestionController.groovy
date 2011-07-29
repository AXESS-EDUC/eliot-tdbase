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

import org.lilie.services.eliot.tice.utils.BreadcrumpsService
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Niveau
import org.lilie.services.eliot.tice.scolarite.Matiere

class QuestionController {

  static defaultAction = "recherche"

  BreadcrumpsService breadcrumpsService
  ProfilScolariteService profilScolariteService
  QuestionService questionService

  /**
   *
   * Action "edite"
   */
  def edite() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "question.edite.titre"))
    Question question
    if (params.creation) {
      QuestionType questionType = QuestionType.get(params.questionTypeId)
      question = new Question(type: questionType, titre: message(code:'question.nouveau.titre'))
    } else {
      question = Question.get(params.id)
    }
    Personne personne = authenticatedPersonne
    [
            liens: breadcrumpsService.liens,
            lienRetour: breadcrumpsService.lienRetour(),
            question: question,
            matieres: profilScolariteService.findMatieresForPersonne(personne),
            niveaux: profilScolariteService.findNiveauxForPersonne(personne)
    ]
  }

  /**
   *
   * Action "enregistre"
   */
  def enregistre() {
    Question question
    Personne personne = authenticatedPersonne
    if (params.id) {
      question = Question.get(params.id)
      questionService.updateProprietes(question,params,personne)
    } else {
      question = questionService.createQuestion(params, personne)
    }
    if (!question.hasErrors()) {
      request.messageCode = "question.enregistre.succes"
    }
    render(view: 'edite', model: [
           liens: breadcrumpsService.liens,
           lienRetour: breadcrumpsService.lienRetour(),
           question: question
           ])
  }

  /**
   *
   * Action "recherche"
   */
  def recherche(RechercheQuestionCommand rechCmd) {
    params.max = Math.min(params.max ? params.int('max') : 10, 100)
    breadcrumpsService.manageBreadcrumps(params, message(code: "question.recherche.titre"))
    Personne personne = authenticatedPersonne
    def questions = questionService.findQuestions(
            personne,
            rechCmd.patternTitre,
            rechCmd.patternAuteur,
            rechCmd.patternSpecification,
            rechCmd.estAutonome,
            Matiere.get(rechCmd.matiereId),
            Niveau.get(rechCmd.niveauId),
            QuestionType.get(rechCmd.typeId),
            params
    )
    [
            liens: breadcrumpsService.liens,
            afficheFormulaire: true,
            typesQuestion: questionService.getAllQuestionTypes(),
            matieres: profilScolariteService.findMatieresForPersonne(personne),
            niveaux: profilScolariteService.findNiveauxForPersonne(personne),
            questions: questions,
            rechercheCommand: rechCmd
    ]
  }

}


class RechercheQuestionCommand {
  String patternTitre
  Boolean estAutonome
  String patternAuteur
  String patternSpecification

  Long matiereId
  Long typeId
  Long niveauId

  Map toParams() {
    [
            patternTitre: patternTitre,
            estAutonome: estAutonome,
            patternPresentation: patternSpecification,
            matiereId: matiereId,
            typeId: typeId,
            niveauId: niveauId
    ]
  }

}