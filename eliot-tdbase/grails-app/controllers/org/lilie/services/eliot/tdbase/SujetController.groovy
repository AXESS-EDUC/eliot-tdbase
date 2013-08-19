package org.lilie.services.eliot.tdbase

import grails.converters.JSON
import org.lilie.services.eliot.tdbase.importexport.ExportHelper
import org.lilie.services.eliot.tdbase.importexport.Format
import org.lilie.services.eliot.tdbase.importexport.QuestionImporterService
import org.lilie.services.eliot.tdbase.importexport.SujetImporterService
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.ExportMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.SujetMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.factory.SujetMarshallerFactory
import org.lilie.services.eliot.tdbase.xml.MoodleQuizExporterService
import org.lilie.services.eliot.tdbase.xml.MoodleQuizImportReport
import org.lilie.services.eliot.tdbase.xml.MoodleQuizImporterService
import org.lilie.services.eliot.tice.AttachementService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService
import org.lilie.services.eliot.tice.scolarite.ScolariteService
import org.lilie.services.eliot.tice.utils.BreadcrumpsService
import org.lilie.services.eliot.tice.utils.NumberUtils
import org.springframework.web.multipart.MultipartFile

class SujetController {

  static defaultAction = "mesSujets"
  private static final String PARAM_DIRECTION_AVANT = 'avant'
  static final String PROP_RANG_INSERTION = 'rangInsertion'

  SujetService sujetService
  QuestionService questionService
  CopieService copieService
  ReponseService reponseService
  ProfilScolariteService profilScolariteService
  BreadcrumpsService breadcrumpsService
  MoodleQuizImporterService moodleQuizImporterService
  ArtefactAutorisationService artefactAutorisationService
  MoodleQuizExporterService moodleQuizExporterService
  ScolariteService scolariteService
  QuestionImporterService questionImporterService
  SujetImporterService sujetImporterService
  AttachementService attachementService

  /**
   *
   * Action "recherche"
   */
  def recherche(RechercheSujetCommand rechCmd) {
    def maxItems = grailsApplication.config.eliot.listes.maxrecherche
    params.max = Math.min(params.max ? params.int('max') : maxItems, 100)
    breadcrumpsService.manageBreadcrumps(params, message(code: "sujet.recherche.titre"))
    Personne personne = authenticatedPersonne
    def rechercheUniquementSujetsChercheur = false
    def moiLabel = message(code: "eliot.label.me").toString().toUpperCase()
    def patternAuteur = rechCmd.patternAuteur
    if (moiLabel == rechCmd.patternAuteur?.toUpperCase()) {
      rechercheUniquementSujetsChercheur = true
      patternAuteur = null
    }
    def sujets = sujetService.findSujets(personne,
        rechCmd.patternTitre,
        patternAuteur,
        rechCmd.patternPresentation,
        Matiere.get(rechCmd.matiereId),
        Niveau.get(rechCmd.niveauId),
        SujetType.get(rechCmd.typeId),
        rechercheUniquementSujetsChercheur,
        params)
    boolean affichePager = false
    if (sujets.totalCount > maxItems) {
      affichePager = true
    }

    [liens: breadcrumpsService.liens,
        afficheFormulaire: true,
        affichePager: affichePager,
        typesSujet: sujetService.getAllSujetTypes(),
        matieres: profilScolariteService.findMatieresForPersonne(personne),
        niveaux: profilScolariteService.findNiveauxForPersonne(personne),
        sujets: sujets,
        rechercheCommand: rechCmd,
        artefactHelper: artefactAutorisationService,
        utilisateur: personne]
  }

  /**
   *
   * Action "mesSujets"
   */
  def mesSujets() {
    def maxItems = grailsApplication.config.eliot.listes.max
    params.max = Math.min(params.max ? params.int('max') : maxItems, 100)
    breadcrumpsService.manageBreadcrumps(params, message(code: "sujet.messujets.titre"))
    Personne personne = authenticatedPersonne
    def sujets = sujetService.findSujetsForProprietaire(personne, params)
    boolean affichePager = false
    if (sujets.totalCount > maxItems) {
      affichePager = true
    }
    def model = [liens: breadcrumpsService.liens,
        afficheFormulaire: false,
        affichePager: affichePager,
        sujets: sujets,
        artefactHelper: artefactAutorisationService,
        utilisateur: personne]
    render(view: "recherche", model: model)
  }

  /**
   *
   * Action "nouveau"
   */
  def nouveau() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "sujet.nouveau.titre"))
    Personne proprietaire = authenticatedPersonne
    render(view: "editeProprietes", model: [liens: breadcrumpsService.liens,
        sujet: new Sujet(),
        typesSujet: sujetService.getAllSujetTypes(),
        matieres: profilScolariteService.findMatieresForPersonne(proprietaire),
        niveaux: profilScolariteService.findNiveauxForPersonne(proprietaire)])
  }

  /**
   *
   * Action "editeProprietes"
   */
  def editeProprietes() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "sujet.editeproprietes.titre"))
    Sujet sujet = Sujet.get(params.id)
    Personne proprietaire = authenticatedPersonne
    render(view: "editeProprietes", model: [liens: breadcrumpsService.liens,
        sujet: sujet,
        typesSujet: sujetService.getAllSujetTypes(),
        matieres: profilScolariteService.findMatieresForPersonne(proprietaire),
        niveaux: profilScolariteService.findNiveauxForPersonne(proprietaire)])
  }

  /**
   *
   * Action "edite"
   */
  def edite() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "sujet.edite.titre"))
    Personne personne = authenticatedPersonne
    Sujet sujet = Sujet.get(params.id)
    [liens: breadcrumpsService.liens,
        titreSujet: sujet.titre,
        sujet: sujet,
        sujetEnEdition: true,
        peutSupprimerSujet: artefactAutorisationService.utilisateurPeutSupprimerArtefact(personne, sujet),
        peutPartagerSujet: artefactAutorisationService.utilisateurPeutPartageArtefact(personne, sujet),
        artefactHelper: artefactAutorisationService,
        utilisateur: personne]
  }

  /**
   *
   * Action "enregistrerPropriete
   */
  def enregistrePropriete() {
    Sujet sujet = Sujet.get(params.id)
    if (!sujet) {
      sujet = new Sujet()
    }
    Personne proprietaire = authenticatedPersonne
    sujet = sujetService.updateProprietes(sujet, params, proprietaire)
    if (!sujet.hasErrors()) {
      flash.messageCode = "sujet.enregistre.succes"
      redirect(action: 'detailProprietes', id: sujet.id)
      return
    }
    render(view: "editeProprietes", model: [liens: breadcrumpsService.liens,
        sujet: sujet,
        typesSujet: sujetService.getAllSujetTypes(),
        matieres: profilScolariteService.findMatieresForPersonne(proprietaire),
        niveaux: profilScolariteService.findNiveauxForPersonne(proprietaire)])
  }

  /**
   *
   */
  def detailProprietes() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "sujet.detailproprietes.titre"))
    Personne personne = authenticatedPersonne
    Sujet sujet = Sujet.get(params.id)
    [liens: breadcrumpsService.liens,
        sujet: sujet,
        peutSupprimerSujet: artefactAutorisationService.utilisateurPeutSupprimerArtefact(personne, sujet),
        peutPartagerSujet: artefactAutorisationService.utilisateurPeutPartageArtefact(personne, sujet),
        artefactHelper: artefactAutorisationService,
        utilisateur: personne]
  }

  /**
   *
   * Action "Dupliquer"
   */
  def duplique() {
    Personne personne = authenticatedPersonne
    Sujet sujet = Sujet.get(params.id)
    Sujet nveauSujet = sujetService.recopieSujet(sujet, personne)
    redirect(action: 'edite', id: nveauSujet.id)
  }

  /**
   * Action "Partager"
   */
  def partage() {
    Personne personne = authenticatedPersonne
    Sujet sujet = Sujet.get(params.id)
    if (!sujet.estPartage()) {
      sujetService.partageSujet(sujet, personne)
    }

    if (!sujet.hasErrors()) {
      flash.messageCode = "sujet.partage.succes"
      def ct = sujet.copyrightsType
      flash.messageArgs = [ct.logo, ct.presentation, ct.code]
      redirect(action: 'edite', id: sujet.id)
      return
    }
    render(view: '/sujet/edite', model: [liens: breadcrumpsService.liens,
        titreSujet: sujet.titre,
        sujet: sujet,
        sujetEnEdition: true,
        peutSupprimerSujet: artefactAutorisationService.utilisateurPeutSupprimerArtefact(personne, sujet),
        peutPartagerSujet: artefactAutorisationService.utilisateurPeutPartageArtefact(personne, sujet),
        artefactHelper: artefactAutorisationService,
        utilisateur: personne])

  }

  /**
   * Action "Supprimer"
   */
  def supprime() {
    Personne personne = authenticatedPersonne
    Sujet sujet = Sujet.get(params.id)
    sujetService.supprimeSujet(sujet, personne)
    redirect(action: "mesSujets",
        params: [bcInit: true])

  }

  /**
   * Action "teste"
   */
  def teste() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "sujet.teste.titre"))
    Personne personne = authenticatedPersonne
    Sujet sujet = Sujet.get(params.id)
    Copie copie = copieService.getCopieTestForSujetAndPersonne(sujet, personne)
    [liens: breadcrumpsService.liens,
        copie: copie,
        afficheCorrection: false,
        sujet: sujet,
        artefactHelper: artefactAutorisationService,
        utilisateur: personne]
  }

  /**
   *
   * Action "reinitialiseCopieTest"
   */
  def reinitialiseCopieTest() {
    Copie copie = Copie.get(params.id)
    copieService.supprimeCopieJetableForPersonne(copie, authenticatedPersonne)
    redirect(action: 'teste', params: [id: copie.sujet.id])
  }

  /**
   *
   * Action rend la copie
   */
  def rendLaCopie() {
    Copie copie = Copie.get(params.copie.id)
    def nombreReponses = params.nombreReponsesNonVides as Integer
    ListeReponsesCopie reponsesCopie = new ListeReponsesCopie()
    nombreReponses.times {
      reponsesCopie.listeReponses << new ReponseCopie()
    }
    bindData(reponsesCopie, params, "reponsesCopie")

    reponsesCopie.listeReponses.each { ReponseCopie reponseCopie ->
      def reponse = Reponse.get(reponseCopie.reponse.id)
      reponseCopie.reponse = reponse
      reponseCopie.specificationObject = reponseService.getSpecificationReponseInitialisee(reponse)
    }
    bindData(reponsesCopie, params, "reponsesCopie")
    Personne eleve = authenticatedPersonne
    copieService.updateCopieRemiseForListeReponsesCopie(copie,
        reponsesCopie.listeReponses,
        eleve)
    request.messageCode = "copie.remise.succes"

    render(view: '/sujet/teste', model: [liens: breadcrumpsService.liens,
        copie: copie,
        afficheCorrection: true,
        sujet: copie.sujet,
        artefactHelper: artefactAutorisationService,
        utilisateur: eleve])
  }

  /**
   *
   * Action enregistre la copie (sans remise)
   */
  def enregistreLaCopie() {
    Copie copie = Copie.get(params.copie.id)
    def nombreReponses = params.nombreReponsesNonVides as Integer
    ListeReponsesCopie reponsesCopie = new ListeReponsesCopie()
    nombreReponses.times {
      reponsesCopie.listeReponses << new ReponseCopie()
    }
    bindData(reponsesCopie, params, "reponsesCopie")

    reponsesCopie.listeReponses.each { ReponseCopie reponseCopie ->
      def reponse = Reponse.get(reponseCopie.reponse.id)
      reponseCopie.reponse = reponse
      reponseCopie.specificationObject = reponseService.getSpecificationReponseInitialisee(reponse)
    }
    bindData(reponsesCopie, params, "reponsesCopie")
    Personne eleve = authenticatedPersonne
    copieService.updateCopieForListeReponsesCopie(copie,
        reponsesCopie.listeReponses,
        eleve)

    if (request.xhr) {
      render copie.dateEnregistrement?.format(message(code: 'default.date.format'))
    } else {
      request.messageCode = "copie.enregistre.succes"
      render(view: '/sujet/teste', model: [liens: breadcrumpsService.liens,
          copie: copie,
          afficheCorrection: copie.dateRemise,
          sujet: copie.sujet,
          artefactHelper: artefactAutorisationService,
          utilisateur: eleve])
    }
  }

  /**
   *
   * Action supprime element
   */
  def supprimeFromSujet() {
    SujetSequenceQuestions sujetQuestion = SujetSequenceQuestions.get(params.id)
    Personne proprietaire = authenticatedPersonne
    Sujet sujet = sujetService.supprimeQuestionFromSujet(sujetQuestion, proprietaire)
    render(view: '/sujet/edite', model: [sujet: sujet,
        titreSujet: sujet.titre,
        sujetEnEdition: true,
        liens: breadcrumpsService.liens,
        artefactHelper: artefactAutorisationService,
        utilisateur: proprietaire])
  }

/**
 *
 * Action remonte element
 */
  def remonteElement() {
    SujetSequenceQuestions sujetQuestion = SujetSequenceQuestions.get(params.id)
    Personne proprietaire = authenticatedPersonne
    Sujet sujet = sujetService.inverseQuestionAvecLaPrecedente(sujetQuestion, proprietaire)
    render(view: '/sujet/edite', model: [sujet: sujet,
        titreSujet: sujet.titre,
        sujetEnEdition: true,
        liens: breadcrumpsService.liens,
        artefactHelper: artefactAutorisationService,
        utilisateur: proprietaire])
  }

  /**
   *
   * Action remonte element
   */
  def descendElement() {
    SujetSequenceQuestions sujetQuestion = SujetSequenceQuestions.get(params.id)
    Personne proprietaire = authenticatedPersonne
    Sujet sujet = sujetService.inverseQuestionAvecLaSuivante(sujetQuestion, proprietaire)
    render(view: '/sujet/edite', model: [sujet: sujet,
        titreSujet: sujet.titre,
        sujetEnEdition: true,
        liens: breadcrumpsService.liens,
        artefactHelper: artefactAutorisationService,
        utilisateur: proprietaire])
  }

  /**
   *
   * Action ajoute element
   */
  def ajouteElement() {
    def props = null
    if (params.rang) {
      def rang = params.rang as Integer
      props = [:]
      if (PARAM_DIRECTION_AVANT == params.direction) {
        props."${PROP_RANG_INSERTION}" = rang
      } else {
        props."${PROP_RANG_INSERTION}" = rang + 1
      }
    }
    breadcrumpsService.manageBreadcrumps(params, message(code: "sujet.ajouteelement.titre"), props)
    Sujet sujet = Sujet.get(params.id)

    [sujet: sujet,
        liens: breadcrumpsService.liens,
        typesQuestionSupportes: questionService.typesQuestionsInteractionSupportes,
        typesQuestionSupportesPourCreation: questionService.typesQuestionsInteractionSupportesPourCreation]
  }

  /**
   * Action ajoute séance
   */
  def ajouteSeance() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "sujet.ajouteseance.titre"))
    Personne personne = authenticatedPersonne
    Sujet sujet = Sujet.get(params.id)
    def modaliteActivite = new ModaliteActivite(enseignant: personne,
        sujet: sujet)
    def proprietesScolarite = profilScolariteService.findProprietesScolariteWithStructureForPersonne(personne)
    def etablissements = profilScolariteService.findEtablissementsForPersonne(personne)
    def niveaux = scolariteService.findNiveauxForEtablissement(etablissements)
    render(view: '/seance/edite', model: [liens: breadcrumpsService.liens,
        etablissements: etablissements,
        niveaux: niveaux,
        afficheLienCreationDevoir: false,
        afficheLienCreationActivite: false,
        afficheActiviteCreee: false,
        afficheDevoirCree: false,
        modaliteActivite: modaliteActivite,
        proprietesScolarite: proprietesScolarite])
  }

  /**
   *
   * Action pour mettre à jour le nombre de  points associé à une question
   */
  def updatePoints(UpdatePointsCommand pointsCommand) {
    try {
      // deduit l'id de l'objet SujetSequenceQuestions à modifier
      def id = pointsCommand.element_id - "SujetSequenceQuestions-" as Long
      def sujetQuestion = SujetSequenceQuestions.get(id)
      // récupère la nouvelle valeur
      def points = pointsCommand.update_value
      // met à jour
      sujetService.updatePointsForQuestion(points,
          sujetQuestion,
          authenticatedPersonne)
      render NumberUtils.formatFloat(points)
    } catch (Exception e) {
      log.info(e.message)
      render params.original_html
    }
  }

  /**
   * Action pour exporter un sujet en XML.
   * @return
   */
  def exporter(String format) {
    Sujet sujet = Sujet.get(params.id)

    switch (format) {
      case Format.NATIF_JSON.name():
        // TODO Gestion sécurité + service pour la paternité ?

        SujetMarshallerFactory sujetMarshallerFactory = new SujetMarshallerFactory()
        SujetMarshaller sujetMarshaller = sujetMarshallerFactory.newInstance(attachementService)
        ExportMarshaller exportMarshaller = new ExportMarshaller(sujetMarshaller: sujetMarshaller)

        def converter = exportMarshaller.marshall(
            sujet,
            new Date(),
            authenticatedPersonne
        ) as JSON
        response.setHeader("Content-disposition", "attachment; filename=${ExportHelper.getFileName(sujet, Format.NATIF_JSON)}")
        render(text: converter.toString(false), contentType: "application/json", encoding: "UTF-8")

        break

      case Format.MOODLE_XML.name():
        // TODO gestion d'erreur à mettre en commun
        def xml = sujet ? moodleQuizExporterService.toMoodleQuiz(sujet) :
          message(code: 'xml.export.sujet.inexistant', args: [params.id])
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
   * Action donnant accès au formulaire d'import d'un fichier moodle XML
   */
  def editeImportMoodleXML() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "sujet.importmoodlexml.titre"))
    Sujet sujet = Sujet.get(params.id)
    Personne proprietaire = authenticatedPersonne
    [
        liens: breadcrumpsService.liens,
        sujet: sujet,
        matieres: profilScolariteService.findMatieresForPersonne(proprietaire),
        niveaux: profilScolariteService.findNiveauxForPersonne(proprietaire)
    ]

  }

  /**
   * Action déclenchant l'import du fichier XML
   */
  def importMoodleXML(ImportDansSujetCommand importCommand) {
    Sujet sujet = Sujet.get(importCommand.sujetId)
    Matiere matiere = Matiere.get(importCommand.matiereId)
    Niveau niveau = Niveau.get(importCommand.niveauId)
    Personne proprietaire = authenticatedPersonne
    MultipartFile fichier = request.getFile("fichierImport")
    def maxSizeEnMega = grailsApplication.config.eliot.fichiers.maxsize.mega
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
    if (importSuccess) {
      try {
        MoodleQuizImportReport report = moodleQuizImporterService.importMoodleQuiz(fichier.bytes,
            sujet,
            matiere,
            niveau,
            proprietaire)
        flash.report = report
      } catch (Exception e) {
        log.error("Une erreur s'est produite durant l'import du quizz Moodle", e)
        flash.errorMessageCode = e.message
        importSuccess = false
      }
    }
    flash.liens = breadcrumpsService.liens
    if (importSuccess) {
      redirect(action: 'rapportImportMoodleXML')
    } else {
      redirect(action: 'editeImportMoodleXML', id: sujet.id)
    }
  }

  /**
   * Action présentant le rapport d'importMoodle XML
   */
  def rapportImportMoodleXML() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "sujet.rapportmoodlexml.titre"))
  }

  /**
   * Action donnant accès au formulaire d'import natif eliot-tdbase d'une question
   */
  def editeImportQuestionNatifTdBase() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "importexport.NATIF_JSON.import.question.libelle"))
    Sujet sujet = Sujet.get(params.id)
    Personne proprietaire = authenticatedPersonne
    [
        liens: breadcrumpsService.liens,
        sujet: sujet,
        matieres: profilScolariteService.findMatieresForPersonne(proprietaire),
        niveaux: profilScolariteService.findNiveauxForPersonne(proprietaire)
    ]
  }

  /**
   * Action déclenchant l'import du fichier question JSON au format natif eliot-tdbase
   */
  def importQuestionNatifTdBase(ImportDansSujetCommand importCommand) {
    Sujet sujet = Sujet.load(importCommand.sujetId)
    Personne proprietaire = authenticatedPersonne
    MultipartFile fichier = request.getFile("fichierImport")
    def maxSizeEnMega = grailsApplication.config.eliot.fichiers.maxsize.mega
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
    if (importSuccess) {
      try {
        questionImporterService.importeQuestion(
            ExportMarshaller.parse(
                JSON.parse(new ByteArrayInputStream(fichier.bytes), 'UTF-8')
            ).question,
            sujet,
            proprietaire,
            new ReferentielEliot(
                matiere: Matiere.load(importCommand.matiereId),
                niveau: Niveau.load(importCommand.niveauId)
            )
        )
      } catch (Exception e) {
        log.error("Une erreur s'est produite durant l'import de la question", e)
        flash.errorMessageCode = e.message
        importSuccess = false
        // TODO tester le comportement en cas d'erreur
      }
    }
    flash.liens = breadcrumpsService.liens
    if (importSuccess) {
      flash.messageCode = "La question a été correctement importée."
      redirect(action: 'edite', id: sujet.id)
    } else {
      redirect(action: 'editeImportQuestionNatifTdBase', id: sujet.id)
    }
  }

  /**
   * Action donnant accès au formulaire d'import natif eliot-tdbase d'un sujet
   */
  def editeImportSujetNatifTdBase() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "importexport.NATIF_JSON.import.sujet.libelle"))
    Personne proprietaire = authenticatedPersonne
    [
        liens: breadcrumpsService.liens,
        matieres: profilScolariteService.findMatieresForPersonne(proprietaire),
        niveaux: profilScolariteService.findNiveauxForPersonne(proprietaire)
    ]
  }

  /**
   * Action déclenchant l'import du fichier sujet JSON au format natif eliot-tdbase
   */
  def importSujetNatifTdBase(Long matiereId, Long niveauId) {
    Personne proprietaire = authenticatedPersonne
    MultipartFile fichier = request.getFile("fichierImport")
    def maxSizeEnMega = grailsApplication.config.eliot.fichiers.maxsize.mega
    boolean importSuccess = true
    if (!fichier || fichier.isEmpty()) {
      flash.errorMessageCode = "question.document.fichier.vide"
      importSuccess = false
    } else if (!fichier.name) {
      flash.errorMessageCode = "question.document.fichier.nom.null"
      importSuccess = false
    }
    // TODO: que faire de la limite de taille pour un sujet ?
//    else if (fichier.size > 1024 * 1024 * maxSizeEnMega) {
//      flash.errorMessageCode = "question.document.fichier.tropgros"
//      importSuccess = false
//    }

    Sujet sujet = null
    if (importSuccess) {
      try {
        sujet = sujetImporterService.importeSujet(
            ExportMarshaller.parse(
                JSON.parse(new ByteArrayInputStream(fichier.bytes), 'UTF-8')
            ).sujet,
            proprietaire,
            new ReferentielEliot(
                matiere: Matiere.load(matiereId),
                niveau: Niveau.load(niveauId)
            )
        )
      } catch (Exception e) {
        log.error("Une erreur s'est produite durant l'import du sujet", e)
        flash.errorMessageCode = e.message
        importSuccess = false
        // TODO tester le comportement en cas d'erreur
      }
    }
    flash.liens = breadcrumpsService.liens
    if (importSuccess) {
      flash.messageCode = "Le sujet a été correctement importé."
      redirect(action: 'edite', id: sujet.id)
    } else {
      redirect(action: 'editeImportSujetNatifTdBase')
    }
  }
}

class ImportDansSujetCommand {
  Long sujetId
  Long matiereId
  Long niveauId
}

class UpdatePointsCommand {
  String element_id
  Float update_value
}


class RechercheSujetCommand {
  String patternTitre
  String patternAuteur
  String patternPresentation

  Long matiereId
  Long typeId
  Long niveauId

  Map toParams() {
    [patternTitre: patternTitre,
        patternAuteur: patternAuteur,
        patternPresentation: patternPresentation,
        matiereId: matiereId,
        typeId: typeId,
        niveauId: niveauId]
  }

}