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

import grails.converters.JSON
import org.lilie.services.eliot.competence.Referentiel
import org.lilie.services.eliot.competence.ReferentielService
import org.lilie.services.eliot.tdbase.emaeval.EmaEvalService
import org.lilie.services.eliot.tdbase.importexport.ExportHelper
import org.lilie.services.eliot.tdbase.importexport.Format
import org.lilie.services.eliot.tdbase.importexport.QuestionExporterService
import org.lilie.services.eliot.tdbase.importexport.QuestionImporterService
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.ExportMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.factory.ExportMarshallerFactory
import org.lilie.services.eliot.tdbase.securite.SecuriteSessionService
import org.lilie.services.eliot.tdbase.xml.MoodleQuizExporterService
import org.lilie.services.eliot.tice.AttachementService
import org.lilie.services.eliot.tice.AttachementUploadException
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.nomenclature.MatiereBcn
import org.lilie.services.eliot.tice.scolarite.Niveau
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService
import org.lilie.services.eliot.tice.utils.Breadcrumps
import org.lilie.services.eliot.tice.utils.BreadcrumpsService
import org.springframework.web.multipart.MultipartFile

import java.util.zip.GZIPInputStream
import java.util.zip.GZIPOutputStream

class QuestionController {

  static scope = "singleton"

  static defaultAction = "recherche"

  private static final String QUESTION_EST_DEJA_INSEREE = "questionEstDejaInseree"

  BreadcrumpsService breadcrumpsServiceProxy
  SecuriteSessionService securiteSessionServiceProxy
  ProfilScolariteService profilScolariteService
  QuestionService questionService
  SujetService sujetService
  ArtefactAutorisationService artefactAutorisationService
  MoodleQuizExporterService moodleQuizExporterService
  AttachementService attachementService
  QuestionExporterService questionExporterService
  QuestionImporterService questionImporterService
  ReferentielService referentielService
  QuestionCompetenceService questionCompetenceService
  EmaEvalService emaEvalService

  /**
   *
   * Action ajoute element
   */
  def nouvelle() {
    breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "question.nouvelle.titre"))
    [
        liens                 : breadcrumpsServiceProxy.liens,
        typesQuestionSupportes: questionService.typesQuestionsInteractionSupportesPourCreation
    ]
  }

/**
 *
 * Action "edite"
 */
  def edite() {

    Question question
    boolean questionEnEdition = false
    Personne personne = authenticatedPersonne
    if (params.creation) {
      QuestionType questionType = QuestionType.get(params.questionTypeId)
      question = new Question(type: questionType, titre: "")
    } else {
      question = Question.get(params.id)
      questionEnEdition = true
    }

    if(question.id && question.estCollaboratif()) {
      boolean locked = questionService.creeVerrou(question, personne)
      if(!locked) {
        flash.errorMessage = 'question.enregistre.echec.verrou'
        redirect(
            action: 'detail',
            id: question.id
        )
        return
      }
    }

    if(question.termine) {
      flash.errorMessage = "question.enregistre.echec.termine"
      redirect(action: 'detail', id: question.id)
      return
    }

    def attachementsSujets = null
    Sujet sujet = null
    if (params.sujetId) {
      sujet = Sujet.get(params.sujetId)
      attachementsSujets = sujetService.findAttachementsDisponiblesForSujet(sujet, personne)
    }
    def questionEstDejaInseree = false
    if (questionEnEdition && sujet) {
      questionEstDejaInseree = true
    }
    breadcrumpsServiceProxy.manageBreadcrumps(
        params,
        message(code: "question.edite.titre"),
        [QUESTION_EST_DEJA_INSEREE: questionEstDejaInseree]
    )

    render(
        view: '/question/edite',
        model: [
            liens                  : breadcrumpsServiceProxy.liens,
            question               : question,
            matiereBcns            : question.matiereBcn != null ? [question.matiereBcn] : [],
            etablissements         : securiteSessionServiceProxy.etablissementList,
            niveaux                : question.niveau != null ? [question.niveau] : [],
            sujet                  : sujet,
            artefactHelper         : artefactAutorisationService,
            utilisateur            : personne,
            questionEnEdition      : questionEnEdition,
            attachementsSujets     : attachementsSujets,
            annulationNonPossible  : params.annulationNonPossible,
            referentielCompetence  : getRefentielCompetence(question),
            isAssociableACompetence: questionCompetenceService.isQuestionAssociableACompetence(question),
            competenceAssocieeList : question.allQuestionCompetence*.competence ?: []
        ]
    )
  }

  /**
   *
   * Action "detail"
   */
  def detail() {

    // Note JT : bricolage pour éviter d'avoir Détail > Modif > Détail
    if(breadcrumpsServiceProxy.liens.last().libelle != message(code: "question.detail.titre")) {
      breadcrumpsServiceProxy.manageBreadcrumps(
          params,
          message(code: "question.detail.titre")

      )
    }

    Question question
    question = Question.get(params.id)
    Personne personne = authenticatedPersonne
    Sujet sujet = null
    if (params.sujetId) {
      sujet = Sujet.get(params.sujetId)
    }
    render(
        view: '/question/detail',
        model: [
            liens                 : breadcrumpsServiceProxy.liens,
            question              : question,
            sujet                 : sujet,
            artefactHelper        : artefactAutorisationService,
            utilisateur           : personne,
            referentielCompetence : getRefentielCompetence(question),
            competenceAssocieeList: question.allQuestionCompetence*.competence
        ]
    )
  }

  /**
   * Action "Supprimer"
   */
  def supprime() {
    Personne personne = authenticatedPersonne
    Question question = Question.get(params.id)
    questionService.supprimeQuestion(question, personne)

    if (params.ajax) {
      render ([success: true]) as JSON
    }
    else {
      redirect(action: "mesItems", controller: "question",
          params: [bcInit: true])
    }
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
    params.annulationNonPossible = true
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
        params: [sujetId: sujetQuestion.sujet.id, annulationNonPossible: true])
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
      def ct = question.copyrightsType
      flash.messageArgs = [ct.logo, ct.presentation, ct.code]
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

    if(question && question.estCollaboratif() && question.estVerrouilleParAutrui(personne)) {
      flash.errorMessage = "question.enregistre.echec.verrou"
      redirect(action: 'detail', id: question.id)
      return
    }

    if(question && question.termine) {
      flash.errorMessage = "question.enregistre.echec.termine"
      redirect(action: 'detail', id: question.id)
      return
    }

    try {
      if (question) {
        questionService.updateProprietes(question, params, specifObject, personne)
      } else {
        question = questionService.createQuestion(params, specifObject, personne)
        questionEnEdition = false
      }
    }
    catch (AttachementUploadException e) {

      if (question) {
        question.errors.reject(e.message)
      } else {
        flash.errorMessage = g.message(code: e.message)

        redirect(
            controller: 'question',
            action: 'edite',
            params: [
                creation      : true,
                questionTypeId: params.type.id
            ]
        )
        return
      }
    }

    Sujet sujet = null
    if (params.sujetId) {
      sujet = Sujet.get(params.sujetId as Long)
    }
    if (question.hasErrors()) {
      render(
          view: '/question/edite',
          model: [
              liens            : breadcrumpsServiceProxy.liens,
              question         : question,
              matiereBcns      : question.matiereBcn != null ? [question.matiereBcn] : [],
              etablissements   : securiteSessionServiceProxy.etablissementList,
              niveaux          : question.niveau != null ? [question.niveau] : [],
              sujet            : sujet,
              questionEnEdition: questionEnEdition,
              artefactHelper   : artefactAutorisationService,
              utilisateur      : personne
          ]
      )
    } else {
      flash.messageCode = "question.enregistre.succes"
      def params = [:]
      if (sujet) {
        params.sujetId = sujet.id
      }

      // Retire le dernier élément du breadcrumbs
      breadcrumpsServiceProxy.removeLastLien()

      redirect(action: 'detail', id: question.id, params: params)
    }

  }

  /**
   *
   * Action "enregistreEtPoursuitEdition"
   */
  def enregistreEtPoursuisEdition() {
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
    if (sujet && question.id && !question.hasErrors()) {
      if (!breadcrumpsServiceProxy.getValeurPropriete(QUESTION_EST_DEJA_INSEREE)) {
        Integer rang = breadcrumpsServiceProxy.getValeurPropriete(SujetController.PROP_RANG_INSERTION)
        question = sujetService.insertQuestionInSujet(
            question,
            sujet,
            personne,
            new ReferentielSujetSequenceQuestions(
                rang: rang
            )
        ) ?: question // Note si l'insertion n'a pu être effectuée, la méthode retourne null ... On conserve dans ce cas la question non insérée pour la suite des traitements
        breadcrumpsServiceProxy.setValeurPropriete(QUESTION_EST_DEJA_INSEREE, true)
      }
    }
    render(
        view: '/question/edite',
        model: [
            liens            : breadcrumpsServiceProxy.liens,
            question         : question,
            matiereBcns      : question.matiereBcn != null ? [question.matiereBcn] : [],
            etablissements   : securiteSessionServiceProxy.etablissementList,
            niveaux          : question.niveau != null ? [question.niveau] : [],
            sujet            : sujet,
            questionEnEdition: questionEnEdition,
            artefactHelper   : artefactAutorisationService,
            utilisateur      : personne
        ]
    )
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
    Integer rang = breadcrumpsServiceProxy.getValeurPropriete(SujetController.PROP_RANG_INSERTION)
    boolean questionEnEdition = false

    if(sujet.estCollaboratif() && sujet.estVerrouilleParAutrui(personne)) {
      flash.errorMessage = 'sujet.enregistre.echec.verrou'
      redirect(
          controller: 'sujet',
          action: 'teste',
          id: sujet.id
      )
      return
    }

    Question question = questionService.createQuestionAndInsertInSujet(
        params,
        specifObject,
        sujet,
        personne,
        new ReferentielSujetSequenceQuestions(
            rang: rang
        )
    )

    if (question.hasErrors()) {
      render(
          view: '/question/edite',
          model: [
              liens            : breadcrumpsServiceProxy.liens,
              question         : question,
              sujet            : sujet,
              matiereBcns      : question.matiereBcn != null ? [question.matiereBcn] : [],
              etablissements   : securiteSessionServiceProxy.etablissementList,
              niveaux          : question.niveau != null ? [question.niveau] : [],
              artefactHelper   : artefactAutorisationService,
              questionEnEdition: questionEnEdition,
              utilisateur      : personne
          ]
      )
      return
    } else {
      flash.messageCode = "question.enregistre.succes"
      breadcrumpsServiceProxy.setValeurPropriete(QUESTION_EST_DEJA_INSEREE, true)

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

    if(sujet.estCollaboratif() && sujet.estVerrouilleParAutrui(personne)) {
      flash.errorMessage = 'sujet.enregistre.echec.verrou'
      redirect(
          controller: 'sujet',
          action: 'teste',
          id: sujet.id
      )
      return
    }

    Integer rang = breadcrumpsServiceProxy.getValeurPropriete(SujetController.PROP_RANG_INSERTION)
    question = sujetService.insertQuestionInSujet(
        question,
        sujet,
        personne,
        new ReferentielSujetSequenceQuestions(
            rang: rang
        )
    )
    if (sujet.hasErrors() || !question) {
      render(
          view: '/sujet/edite',
          model: [
              liens             : breadcrumpsServiceProxy.liens,
              titreSujet        : sujet.titre,
              sujet             : sujet,
              sujetEnEdition    : true,
              peutSupprimerSujet: artefactAutorisationService.utilisateurPeutSupprimerArtefact(personne, sujet),
              peutPartagerSujet : artefactAutorisationService.utilisateurPeutPartageArtefact(personne, sujet),
              artefactHelper    : artefactAutorisationService,
              utilisateur       : personne
          ]
      )
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
    def maxItems = grailsApplication.config.eliot.listes.maxrecherche
    params.max = Math.min(params.max ? params.int('max') : maxItems, 100)
    breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "question.recherche.titre"))
    Personne personne = authenticatedPersonne
    def rechercheUniquementQuestionsChercheur = false
    def moiLabel = message(code: "eliot.label.me").toString().toUpperCase()
    def patternAuteur = rechCmd.patternAuteur
    if (!artefactAutorisationService.partageArtefactCCActive || moiLabel == rechCmd.patternAuteur?.toUpperCase()) {
      rechercheUniquementQuestionsChercheur = true
      patternAuteur = null
    }
    Sujet sujet = Sujet.get(rechCmd.sujetId)
    def afficheLiensModifier = true
    def exclusComposite = false
    def typesQuestions = questionService.typesQuestionsSupportes
    if (sujet) {
      afficheLiensModifier = false
      if (sujet.estUnExercice()) {
        typesQuestions = questionService.typesQuestionsSupportesHorsComposite
        exclusComposite = true
      }
    }
    boolean affichePager = false

    MatiereBcn matiereBcn = MatiereBcn.get(rechCmd.matiereId)
    Niveau niveau = Niveau.get(rechCmd.niveauId)
    Boolean afficheQuestionMasquee = rechCmd.afficheQuestionMasquee != null ? rechCmd.afficheQuestionMasquee : false

    def questions = questionService.findQuestions(personne,
        rechCmd.patternTitre,
        patternAuteur,
        rechCmd.patternSpecification,
        new ReferentielEliot(
            matiereBcn: matiereBcn,
            niveau: Niveau.get(rechCmd.niveauId)
        ),
        QuestionType.get(rechCmd.typeId),
        exclusComposite,
        rechercheUniquementQuestionsChercheur,
        params,
        afficheQuestionMasquee)

    if (questions.totalCount > maxItems) {
      affichePager = true
    }
    [liens                  : breadcrumpsServiceProxy.liens,
     afficheFormulaire      : true,
     typesQuestion          : typesQuestions,
     matiereBcns            : matiereBcn != null ? [matiereBcn] : [],
     niveaux                : niveau != null ? [niveau] : [],
     questions              : questions,
     rechercheCommand       : rechCmd,
     sujet                  : sujet,
     afficheLiensModifier   : afficheLiensModifier,
     afficherPager          : affichePager,
     artefactHelper         : artefactAutorisationService,
     utilisateur            : personne,
     questionsMasqueesIds   : afficheQuestionMasquee ? questionService.listIdsQuestionsMasquees(personne, questions) : [],
     afficheQuestionMasquee: afficheQuestionMasquee]
  }

  def mesItems() {
    def maxItems = grailsApplication.config.eliot.listes.max
    params.max = Math.min(params.max ? params.int('max') : maxItems, 100)
    breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "question.mesitems.titre"))
    Personne personne = authenticatedPersonne
    def questions = questionService.findQuestionsForProprietaire(personne,
        params)
    boolean afficheLiensModifier = true
    boolean affichePager = false
    if (questions.totalCount > maxItems) {
      affichePager = true
    }
    def model = [liens               : breadcrumpsServiceProxy.liens,
                 afficheFormulaire   : false,
                 questions           : questions,
                 afficheLiensModifier: afficheLiensModifier,
                 afficherPager       : affichePager,
                 artefactHelper      : artefactAutorisationService,
                 utilisateur         : personne]
    render(view: "recherche", model: model)
  }

/**
 * Action pour exporter une question.
 * @return
 */
  def exporter(String format) {

    Question question = Question.get(params.id)
    if (!question) {
      throw new IllegalStateException(
          "Il n'existe pas de question d'id '${params.id}'"
      )
    }

    switch (format) {
      case Format.NATIF_JSON.name():

        JSON json = getQuestionAsJson(question)
        response.setHeader("Content-disposition", "attachment; filename=${ExportHelper.getFileName(question, Format.NATIF_JSON)}")

        response.setCharacterEncoding('UTF-8')
        response.contentType = 'application/tdbase'
        GZIPOutputStream zipOutputStream = new GZIPOutputStream(response.outputStream)
        json.render(new OutputStreamWriter(zipOutputStream, 'UTF-8'))
        break

      case Format.MOODLE_XML.name():
        def xml = moodleQuizExporterService.toMoodleQuiz(question)
        response.setHeader("Content-disposition", "attachment; filename=export.xml")
        render(text: xml, contentType: "text/xml", encoding: "UTF-8")
        break

      default:
        throw new IllegalArgumentException(
            "Le format '$format' est inconnu."
        )
    }
  }

  /**
   * Action donnant accès au formulaire d'import natif eliot-tdbase d'une question
   */
  def editeImportQuestionNatifTdBase() {
    breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "importexport.NATIF_JSON.import.question.libelle"))
    Personne proprietaire = authenticatedPersonne
    [
        liens         : breadcrumpsServiceProxy.liens,
        etablissements: securiteSessionServiceProxy.etablissementList,
        fichierMaxSize: grailsApplication.config.eliot.fichiers.importexport.maxsize.mega ?:
            grailsApplication.config.eliot.fichiers.maxsize.mega ?: 10
    ]
  }

  /**
   * Action déclenchant l'import du fichier question JSON au format natif eliot-tdbase
   */
  def importQuestionNatifTdBase(Long matiereId, Long niveauId) {
    Personne proprietaire = authenticatedPersonne
    MultipartFile fichier = request.getFile("fichierImport")
    def maxSizeEnMega = grailsApplication.config.eliot.fichiers.importexport.maxsize.mega ?:
        grailsApplication.config.eliot.fichiers.maxsize.mega ?: 10

    boolean importSuccess = true
    if (!fichier || fichier.isEmpty()) {
      flash.errorMessageCode = "question.document.fichier.vide"
      importSuccess = false
    } else if (!fichier.name) {
      flash.errorMessageCode = "question.document.fichier.nom.null"
      importSuccess = false
    } else if (fichier.size > 1024 * 1024 * maxSizeEnMega) {
      flash.errorMessageCode = "question.document.fichier.tropgros"
      importSuccess = false
    }

    Question question = null
    if (importSuccess) {
      try {
        question = questionImporterService.importeQuestion(
            ExportMarshaller.parse(
                JSON.parse(
                    new GZIPInputStream(
                        new ByteArrayInputStream(fichier.bytes)
                    ),
                    'UTF-8'
                )
            ).question,
            null,
            proprietaire,
            new ReferentielEliot(
                matiereBcn: MatiereBcn.load(matiereId),
                niveau: Niveau.load(niveauId)
            )
        )
      } catch (Exception e) {
        log.error("Une erreur s'est produite durant l'import de la question", e)
        flash.errorMessageCode = "Format de fichier incorrect (cause: ${e.message})"
        importSuccess = false
      }
    }
    flash.liens = breadcrumpsServiceProxy.liens
    if (importSuccess) {
      flash.messageCode = "La question a été correctement importée."
      redirect(action: 'detail', id: question.id)
    } else {
      redirect(action: 'editeImportQuestionNatifTdBase')
    }
  }

  def creeVerrou(Long id) {
    Question question = Question.get(id)
    questionService.creeVerrou(question, authenticatedPersonne)
    render question as JSON
  }

  def supprimeVerrou(Long id) {
    Question question = Question.get(id)
    questionService.supprimeVerrou(question, authenticatedPersonne)
    redirect(action: 'detail', id: id)
  }

  def masque(Long id) {
    Question question = Question.get(id)
    Personne personne = authenticatedPersonne
    QuestionMasquee questionMasquee = questionService.masque(personne, question)
    render questionMasquee as JSON
  }

  def annuleMasque(Long id) {
    Question question = Question.get(id)
    Personne personne = authenticatedPersonne
    questionService.annuleMasque(personne, question)
    render question as JSON
  }

  private JSON getQuestionAsJson(Question question) {
    question = questionExporterService.getQuestionPourExport(question, authenticatedPersonne)
    ExportMarshallerFactory exportMarshallerFactory = new ExportMarshallerFactory()
    ExportMarshaller exportMarshaller = exportMarshallerFactory.newInstance(attachementService)

    return exportMarshaller.marshall(
        question,
        new Date(),
        authenticatedPersonne
    ) as JSON
  }

/**
 *
 * @param params les paramètres de la requête
 * @return l'objet représentant la spécification
 */
  protected def getSpecificationObjectFromParams(Map params) {}

  private Referentiel getRefentielCompetence(Question question) {
    if (!emaEvalService.isLiaisonReady()) {
      return null
    }

    if (!questionCompetenceService.isQuestionAssociableACompetence(question)) {
      return null
    }

    // Récupère le référentiel de compétence
    return referentielService.fetchReferentielByNom(emaEvalService.defautReferentielNom)
  }
}


class RechercheQuestionCommand {
  String patternTitre
  String patternAuteur
  String patternSpecification

  Long matiereId
  Long typeId
  Long niveauId
  Long sujetId

  Boolean afficheQuestionMasquee

  Map toParams() {
    [
        patternAuteur         : patternAuteur,
        patternTitre          : patternTitre,
        patternPresentation   : patternSpecification,
        matiereId             : matiereId,
        typeId                : typeId,
        niveauId              : niveauId,
        sujetId               : sujetId,
        afficheQuestionMasquee: afficheQuestionMasquee
    ]
  }

}