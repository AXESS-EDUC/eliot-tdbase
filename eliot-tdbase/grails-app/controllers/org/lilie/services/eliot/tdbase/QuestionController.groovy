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

import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService
import org.lilie.services.eliot.tice.utils.BreadcrumpsService

class QuestionController {

  static defaultAction = "recherche"


  BreadcrumpsService breadcrumpsService
  ProfilScolariteService profilScolariteService
  QuestionService questionService
  SujetService sujetService
  ArtefactAutorisationService artefactAutorisationService

  /**
   *
   * Action ajoute element
   */
  def nouvelle() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "question.nouvelle.titre"))
    [
            liens: breadcrumpsService.liens,
            typesQuestionSupportes: questionService.typesQuestionsInteractionSupportesPourCreation
    ]
  }

/**
 *
 * Action "edite"
 */
  def edite() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "question.edite.titre"))
    Question question
    boolean questionEnEdition = false
    Personne personne = authenticatedPersonne
    if (params.creation) {
      QuestionType questionType = QuestionType.get(params.questionTypeId)
      question = new Question(type: questionType, titre: message(code: 'question.nouveau.titre'))
    } else {
      question = Question.get(params.id)
      questionEnEdition = true
    }
    def attachementsSujets = null
    Sujet sujet = null
    if (params.sujetId) {
      sujet = Sujet.get(params.sujetId)
      attachementsSujets = sujetService.findAttachementsDisponiblesForSujet(sujet,personne)
    }
    render(view: '/question/edite', model: [
            liens: breadcrumpsService.liens,
            lienRetour: breadcrumpsService.lienRetour(),
            question: question,
            matieres: profilScolariteService.findMatieresForPersonne(personne),
            niveaux: profilScolariteService.findNiveauxForPersonne(personne),
            sujet: sujet,
            artefactHelper: artefactAutorisationService,
            utilisateur: personne,
            questionEnEdition: questionEnEdition,
            attachementsSujets: attachementsSujets
    ])
  }

  /**
   *
   * Action "detail"
   */
  def detail() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "question.detail.titre"))
    Question question
    question = Question.get(params.id)
    Personne personne = authenticatedPersonne
    Sujet sujet = null
    if (params.sujetId) {
      sujet = Sujet.get(params.sujetId)
    }
    render(view: '/question/detail', model: [
            liens: breadcrumpsService.liens,
            lienRetour: breadcrumpsService.lienRetour(),
            question: question,
            sujet: sujet,
            artefactHelper: artefactAutorisationService,
            utilisateur: personne
    ])
  }

  /**
   * Action "Supprimer"
   */
  def supprime() {
    Personne personne = authenticatedPersonne
    Question question = Question.get(params.id)
    questionService.supprimeQuestion(question, personne)
    def lien = breadcrumpsService.lienRetour()
    redirect(action: lien.action,
             controller: lien.controller,
             params: lien.params)

  }

  /**
   *
   * Action "Dupliquer"
   */
  def duplique() {
    Personne personne = authenticatedPersonne
    Question question = Question.get(params.id)
    Question nvelleQuestion = questionService.recopieQuestion(question, personne)
    params.id = nvelleQuestion.id
    redirect(action: 'edite', id: nvelleQuestion.id, params: params)
  }

  /**
   *
   * Action "Dupliquer" depuis un sujet
   */
  def dupliqueDansSujet() {
    Personne personne = authenticatedPersonne
    SujetSequenceQuestions sujetQuestion = SujetSequenceQuestions.get(params.id)
    Question nvelleQuestion = questionService.recopieQuestionDansSujet(sujetQuestion, personne)
    redirect(action: 'edite', id: nvelleQuestion.id,
             params: [sujetId: sujetQuestion.sujet.id])
  }

  /**
   * Action "Partager"
   */
  def partage() {
    Personne personne = authenticatedPersonne
    Question question = Question.get(params.id)
    if (!question.estPartage()) {
      questionService.partageQuestion(question, personne)
    }
    if (!question.hasErrors()) {
      flash.messageCode = "question.partage.succes"
      flash.messageArgs = [question.copyrightsType.presentation]
    }
    redirect(action: 'detail', id: question.id)

  }

  /**
   * supprime l'attachement d'une question
   */
  def supprimePrincipalAttachement() {
    Question question = Question.get(params.id)
    question.doitSupprimerPrincipalAttachement = true
    question.principalAttachementEstInsereDansLaQuestion = null
    render(template: "/question/QuestionEditionFichier", model: [question: question])
  }

  /**
   *
   * Action "enregistre"
   */
  def enregistre() {

    Personne personne = authenticatedPersonne
    def specifObject = getSpecificationObjectFromParams(params)
    boolean questionEnEdition = true
    Question question = Question.get(params.id)
    if (question) {
      questionService.updateProprietes(question, params, specifObject, personne)
    } else {
      question = questionService.createQuestion(params, specifObject, personne)
      questionEnEdition = false
    }
    Sujet sujet = null
    if (params.sujetId) {
      sujet = Sujet.get(params.sujetId as Long)
    }
    if (question.hasErrors()) {
      render(view: '/question/edite', model: [
              liens: breadcrumpsService.liens,
              lienRetour: breadcrumpsService.lienRetour(),
              question: question,
              matieres: profilScolariteService.findMatieresForPersonne(personne),
              niveaux: profilScolariteService.findNiveauxForPersonne(personne),
              sujet: sujet,
              questionEnEdition: questionEnEdition,
              artefactHelper: artefactAutorisationService,
              utilisateur: personne
      ])
    } else {
      flash.messageCode = "question.enregistre.succes"
      def params = [:]
      if (sujet) {
        params.sujetId = sujet.id
      }
      redirect(action: 'detail', id: question.id, params: params)
    }

  }

  /**
   *
   * Action "enregistreInsertNouvelItem"
   */
  def enregistreInsertNouvelItem() {
    Personne personne = authenticatedPersonne
    def specifObject = getSpecificationObjectFromParams(params)
    Long sujetId = params.sujetId as Long
    Sujet sujet = Sujet.get(sujetId)
    Integer rang = breadcrumpsService.getValeurPropriete(
            SujetController.PROP_RANG_INSERTION)
    boolean questionEnEdition = false
    Question question = questionService.createQuestionAndInsertInSujet(
            params,
            specifObject,
            sujet,
            personne,
            rang)

    if (question.hasErrors()) {
      render(view: '/question/edite', model: [
              liens: breadcrumpsService.liens,
              lienRetour: breadcrumpsService.lienRetour(),
              question: question,
              sujet: sujet,
              matieres: profilScolariteService.findMatieresForPersonne(personne),
              niveaux: profilScolariteService.findNiveauxForPersonne(personne),
              sujet: sujet,
              peutSupprimer: false,
              questionEnEdition: questionEnEdition,
              peutPartagerQuestion: false
      ])
    } else {
      flash.messageCode = "question.enregistre.succes"
      redirect(action: 'detail', id: question.id, params: [sujetId: sujet.id])
    }


  }

/**
 *
 * Action "insert"
 */
  def insert() {
    Personne personne = authenticatedPersonne
    Long sujetId = params.sujetId as Long
    Sujet sujet = Sujet.get(sujetId)
    Question question = Question.get(params.id)
    Integer rang = breadcrumpsService.getValeurPropriete(
            SujetController.PROP_RANG_INSERTION)
    sujetService.insertQuestionInSujet(question, sujet, personne, rang)
    if (sujet.hasErrors()) {
      render(view: '/sujet/edite', model: [
              liens: breadcrumpsService.liens,
              titreSujet: sujet.titre,
              sujet: sujet,
              sujetEnEdition: true,
              peutSupprimerSujet: artefactAutorisationService.utilisateurPeutSupprimerArtefact(personne, sujet),
              peutPartagerSujet: artefactAutorisationService.utilisateurPeutPartageArtefact(personne, sujet),
              artefactHelper: artefactAutorisationService,
              utilisateur: personne
      ])
    } else {
      flash.messageCode = "question.enregistreinsert.succes"
      redirect(action: 'detail', id: question.id, params: [sujetId: sujet.id])
    }

  }

  /**
   *
   * Action "recherche"
   */
  def recherche(RechercheQuestionCommand rechCmd) {
    params.max = Math.min(params.max ? params.int('max') : 5, 100)
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
    Sujet sujet = Sujet.get(rechCmd.sujetId)
    boolean afficheLiensModifier = true
    if (sujet) {
      afficheLiensModifier = false
    }
    [
            liens: breadcrumpsService.liens,
            afficheFormulaire: true,
            typesQuestion: questionService.getTypesQuestionsSupportes(),
            matieres: profilScolariteService.findMatieresForPersonne(personne),
            niveaux: profilScolariteService.findNiveauxForPersonne(personne),
            questions: questions,
            rechercheCommand: rechCmd,
            sujet: sujet,
            afficheLiensModifier: afficheLiensModifier,
            artefactHelper: artefactAutorisationService,
            utilisateur: personne
    ]
  }

  def mesItems() {
    params.max = Math.min(params.max ? params.int('max') : 5, 100)
    breadcrumpsService.manageBreadcrumps(params, message(code: "question.recherche.titre"))
    Personne personne = authenticatedPersonne
    def questions = questionService.findQuestionsForProprietaire(
            personne,
            params
    )
    boolean afficheLiensModifier = true
    def model = [
            liens: breadcrumpsService.liens,
            afficheFormulaire: false,
            questions: questions,
            afficheLiensModifier: afficheLiensModifier,
            artefactHelper: artefactAutorisationService,
            utilisateur: personne
    ]
    render(view: "recherche", model: model)
  }

  /**
   *
   * @param params les paramètres de la requête
   * @return l'objet représentant la spécification
   */
  protected def getSpecificationObjectFromParams(Map params) {}

}


class RechercheQuestionCommand {
  String patternTitre
  Boolean estAutonome
  String patternAuteur
  String patternSpecification

  Long matiereId
  Long typeId
  Long niveauId
  Long sujetId

  Map toParams() {
    [
            patternTitre: patternTitre,
            estAutonome: estAutonome,
            patternPresentation: patternSpecification,
            matiereId: matiereId,
            typeId: typeId,
            niveauId: niveauId,
            sujetId: sujetId
    ]
  }

}