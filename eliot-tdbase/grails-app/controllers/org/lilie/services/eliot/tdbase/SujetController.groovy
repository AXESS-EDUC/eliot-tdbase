package org.lilie.services.eliot.tdbase

import grails.converters.JSON
import org.lilie.services.eliot.tdbase.importexport.ExportHelper
import org.lilie.services.eliot.tdbase.importexport.Format
import org.lilie.services.eliot.tdbase.importexport.QuestionImporterService
import org.lilie.services.eliot.tdbase.importexport.SujetExporterService
import org.lilie.services.eliot.tdbase.importexport.SujetImporterService
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.ExportMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.factory.ExportMarshallerFactory
import org.lilie.services.eliot.tdbase.preferences.PreferenceEtablissementService
import org.lilie.services.eliot.tdbase.securite.SecuriteSessionService
import org.lilie.services.eliot.tdbase.xml.MoodleQuizExporterService
import org.lilie.services.eliot.tdbase.xml.MoodleQuizImportReport
import org.lilie.services.eliot.tdbase.xml.MoodleQuizImporterService
import org.lilie.services.eliot.tice.AttachementService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.groupe.GroupeService
import org.lilie.services.eliot.tice.annuaire.groupe.GroupeType
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.Fonction
import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.lilie.services.eliot.tice.scolarite.FonctionService
import org.lilie.services.eliot.tice.nomenclature.MatiereBcn
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService
import org.lilie.services.eliot.tice.scolarite.RecherchePersonneResultat
import org.lilie.services.eliot.tice.util.Pagination
import org.lilie.services.eliot.tice.utils.BreadcrumpsService
import org.lilie.services.eliot.tice.utils.NumberUtils
import org.springframework.web.multipart.MultipartFile
import java.util.zip.GZIPInputStream
import java.util.zip.GZIPOutputStream

class SujetController {

  static scope = "singleton"

  static defaultAction = "mesSujets"
  private static final String PARAM_DIRECTION_AVANT = 'avant'
  static final String PROP_RANG_INSERTION = 'rangInsertion'

  SujetService sujetService
  QuestionService questionService
  CopieService copieService
  ReponseService reponseService
  ProfilScolariteService profilScolariteService
  BreadcrumpsService breadcrumpsServiceProxy
  MoodleQuizImporterService moodleQuizImporterService
  ArtefactAutorisationService artefactAutorisationService
  MoodleQuizExporterService moodleQuizExporterService
  QuestionImporterService questionImporterService
  SujetImporterService sujetImporterService
  SujetExporterService sujetExporterService
  AttachementService attachementService
  SecuriteSessionService securiteSessionServiceProxy
  FonctionService fonctionService
  PreferenceEtablissementService preferenceEtablissementService
  GroupeService groupeService

  /**
   *
   * Action "recherche"
   */
  def recherche(RechercheSujetCommand rechCmd) {
    def maxItems = grailsApplication.config.eliot.listes.maxrecherche
    params.max = Math.min(params.max ? params.int('max') : maxItems, 100)
    breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "sujet.recherche.titre"))
    Personne personne = authenticatedPersonne
    def rechercheUniquementSujetsChercheur = false
    def moiLabel = message(code: "eliot.label.me").toString().toUpperCase()
    def patternAuteur = rechCmd.patternAuteur
    if (!artefactAutorisationService.partageArtefactCCActive || moiLabel == rechCmd.patternAuteur?.toUpperCase()) {
      rechercheUniquementSujetsChercheur = true
      patternAuteur = null
    }

    MatiereBcn matiereBcn = MatiereBcn.get(rechCmd.matiereId)
    Niveau niveau = Niveau.get(rechCmd.niveauId)
    Boolean afficheSujetMasque = rechCmd.afficheSujetMasque != null ? rechCmd.afficheSujetMasque : false

    def sujets = sujetService.findSujets(personne,
        rechCmd.patternTitre,
        patternAuteur,
        rechCmd.patternPresentation,
        new ReferentielEliot(
            matiereBcn: matiereBcn,
            niveau: Niveau.get(rechCmd.niveauId)
        ),
        SujetType.get(rechCmd.typeId),
        rechercheUniquementSujetsChercheur,
        params,
        afficheSujetMasque)
    boolean affichePager = false
    if (sujets.totalCount > maxItems) {
      affichePager = true
    }

    [liens              : breadcrumpsServiceProxy.liens,
     afficheFormulaire  : true,
     affichePager       : affichePager,
     typesSujet         : sujetService.getAllSujetTypes(),
     matiereBcns        : matiereBcn != null ? [matiereBcn] : [],
     niveaux            : niveau != null ? [niveau] : [],
     sujets             : sujets,
     rechercheCommand   : rechCmd,
     artefactHelper     : artefactAutorisationService,
     utilisateur        : personne,
     sujetsMasquesIds   : afficheSujetMasque ? sujetService.listIdsSujetsMasques(personne, sujets) : [],
     afficheSujetMasque : afficheSujetMasque]
  }

  /**
   *
   * Action "mesSujets"
   */
  def mesSujets() {
    def maxItems = grailsApplication.config.eliot.listes.max
    params.max = Math.min(params.max ? params.int('max') : maxItems, 100)
    breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "sujet.messujets.titre"))
    Personne personne = authenticatedPersonne
    def sujets = sujetService.findSujetsForProprietaire(personne, params)
    boolean affichePager = false
    if (sujets.totalCount > maxItems) {
      affichePager = true
    }
    def model = [liens            : breadcrumpsServiceProxy.liens,
                 afficheFormulaire: false,
                 affichePager     : affichePager,
                 sujets           : sujets,
                 artefactHelper   : artefactAutorisationService,
                 utilisateur      : personne]
    render(view: "recherche", model: model)
  }

  /**
   *
   * Action "nouveau"
   */
  def nouveau() {
    breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "sujet.nouveau.titre"))
    Personne proprietaire = authenticatedPersonne
    Etablissement currentEtablissement = securiteSessionServiceProxy.currentEtablissement

    render(
        view: "editeProprietes",
        model: [
            liens                   : breadcrumpsServiceProxy.liens,
            sujet                   : new Sujet(),
            typesSujet              : sujetService.getAllSujetTypes(),
            artefactHelper          : artefactAutorisationService,
            matiereBcns             : [],
            etablissements          : securiteSessionServiceProxy.etablissementList,
            niveaux                 : [],
            currentEtablissement    : currentEtablissement,
            fonctionList            : preferenceEtablissementService.getFonctionListForRoleFormateur(
                proprietaire,
                currentEtablissement
            ),
            peutAjouterContributeur : true
        ]
    )
  }

  def matiereBcns() {
    String recherche = '%' + params.recherche + '%'

    def matiereBcns = MatiereBcn.withCriteria {
      or {
        ilike('libelleCourt', recherche)
        ilike('libelleEdition', recherche)
      }
      order('libelleLong', 'asc')
    }

    render matiereBcns as JSON
  }

  def niveaux() {
    String recherche = '%' + params.recherche + '%'

    def niveaux = Niveau.withCriteria {
      or {
        ilike('libelleCourt', recherche)
        ilike('libelleEdition', recherche)
        ilike('libelleLong', recherche)
      }
      order('libelleLong', 'asc')
    }

    render niveaux as JSON
  }

  /**
   *
   * Action "editeProprietes"
   */
  def editeProprietes() {
    breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "sujet.editeproprietes.titre"))
    Sujet sujet = Sujet.get(params.id)
    Personne proprietaire = authenticatedPersonne
    Etablissement currentEtablissement = securiteSessionServiceProxy.currentEtablissement

    if(sujet.estCollaboratif()) {
      // Pose un verrou avant de permettre la modification du sujet
      boolean locked = sujetService.creeVerrou(sujet, authenticatedPersonne)
      if(!locked) {
        redirect(
            action: 'teste',
            id: sujet.id
        )
        return
      }
    }

    assert artefactAutorisationService.utilisateurPeutModifierPropriete(proprietaire, sujet)

    // Note : on ne doit pas pouvoir transformer un exercice collaboratif en sujet
    boolean peutAjouterContributeur = true
    List<SujetType> sujetTypeList
    if(sujet.estCollaboratif() && sujet.estUnExercice()) {
      sujetTypeList = [SujetTypeEnum.Exercice.sujetType]
      peutAjouterContributeur = false
    }
    else {
      sujetTypeList = sujetService.getAllSujetTypes()
    }

    render(
        view: "editeProprietes",
        model: [
            liens               : breadcrumpsServiceProxy.liens,
            sujet               : sujet,
            artefactHelper      : artefactAutorisationService,
            typesSujet          : sujetTypeList,
            matiereBcns         : sujet.matiereBcn != null ? [sujet.matiereBcn] : [],
            etablissements      : securiteSessionServiceProxy.etablissementList,
            niveaux             : sujet.niveau != null ? [sujet.niveau] : [],
            currentEtablissement: currentEtablissement,
            fonctionList        : preferenceEtablissementService.getFonctionListForRoleFormateur(
                proprietaire,
                currentEtablissement
            ),
            peutAjouterContributeur: peutAjouterContributeur
        ]
    )
  }

  /**
   *
   * Visualise les prorpiétés d'un sujet
   */
  def proprietes() {
    breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "sujet.proprietes.titre"))
    Sujet sujet = Sujet.get(params.id)
    Personne proprietaire = authenticatedPersonne
    Etablissement currentEtablissement = securiteSessionServiceProxy.currentEtablissement

    assert artefactAutorisationService.utilisateurPeutAfficherPropriete(proprietaire, sujet)

    render(
        view: "proprietes",
        model: [
            liens               : breadcrumpsServiceProxy.liens,
            sujet               : sujet,
            artefactHelper      : artefactAutorisationService,
            etablissements      : securiteSessionServiceProxy.etablissementList,
            currentEtablissement: currentEtablissement,
            fonctionList        : preferenceEtablissementService.getFonctionListForRoleFormateur(
                proprietaire,
                currentEtablissement
            )
        ]
    )
  }

  def rechercheContributeur(RechercheContributeurCommand command) {
    Personne personne = authenticatedPersonne
    Etablissement etablissement
    if (command.etablissementId) {
      etablissement = Etablissement.get(command.etablissementId)
    } else {
      etablissement = securiteSessionServiceProxy.currentEtablissement
      command.etablissementId = etablissement.id
    }

    List<Fonction> fonctionList =
        preferenceEtablissementService.getFonctionListForRoleFormateur(
            personne,
            etablissement
        )

    Fonction fonction
    if(command.fonctionId) {
      fonction = Fonction.get(command.fonctionId)
    }
    else {
      fonction = FonctionEnum.ENS.fonction
    }

    RecherchePersonneResultat resultat =
        profilScolariteService.rechercheAllPersonneForEtablissementAndFonctionIn(
            personne,
            etablissement,
            [fonction],
            command.patternCode,
            command.pagination
        )

    render(
        view: "/sujet/_selectContributeur",
        model: [
            rechercheContributeurCommand: command,
            etablissements              : securiteSessionServiceProxy.etablissementList,
            fonctionList                : fonctionList,
            resultat                    : resultat
        ]
    )
  }

  def updateFonctionList() {
    Personne personne = authenticatedPersonne
    Etablissement etablissement = Etablissement.load(params.etablissementId)

    List<Fonction> fonctionList =
        preferenceEtablissementService.getFonctionListForRoleFormateur(
            personne,
            etablissement
        )

    Fonction fonction = fonctionList.contains(fonctionService.fonctionEleve()) ?
        fonctionService.fonctionEleve() :
        fonctionList.first()

    render(
        view: "/seance/_selectFonction",
        model: [
            fonctionList: fonctionList,
            fonctionId  : fonction.id
        ]
    )
  }

  /**
   *
   * Action "edite"
   */
  def edite() {
    breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "sujet.edite.titre"))
    Personne personne = authenticatedPersonne
    Sujet sujet = Sujet.get(params.id)

    if(sujet.estCollaboratif()) {
      // Pose un verrou avant de permettre la modification du sujet
      boolean locked = sujetService.creeVerrou(sujet, authenticatedPersonne)
      if(!locked) {
        flash.errorMessage = 'sujet.enregistre.echec.verrou'
        redirect(
            action: 'teste',
            id: sujet.id
        )
        return
      }
    }

    [
        liens             : breadcrumpsServiceProxy.liens,
        titreSujet        : sujet.titre,
        sujet             : sujet,
        sujetEnEdition    : true,
        peutSupprimerSujet: artefactAutorisationService.utilisateurPeutSupprimerArtefact(personne, sujet),
        peutPartagerSujet : artefactAutorisationService.utilisateurPeutPartageArtefact(personne, sujet),
        artefactHelper    : artefactAutorisationService,
        utilisateur       : personne
    ]
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
    Etablissement currentEtablissement = securiteSessionServiceProxy.currentEtablissement

    params["contributeurIds"] = params.list("contributeurId")?.collect { Long.parseLong(it) }

    if(sujet.estCollaboratif() && sujet.estVerrouilleParAutrui(proprietaire)) {
      flash.erreurMessage = "sujet.enregistre.echec.verrou"
      redirect(action: 'detailProprietes', id: sujet.id)
      return
    }

    sujet = sujetService.updateProprietes(sujet, params, proprietaire)

    if (!sujet.hasErrors()) {
      flash.messageCode = "sujet.enregistre.succes"
      redirect(action: 'detailProprietes', id: sujet.id)
      return
    }
    render(
        view: "editeProprietes",
        model: [
            liens               : breadcrumpsServiceProxy.liens,
            sujet               : sujet,
            typesSujet          : sujetService.getAllSujetTypes(),
            etablissements      : securiteSessionServiceProxy.etablissementList,
            artefactHelper      : artefactAutorisationService,
            currentEtablissement: currentEtablissement,
            fonctionList        : preferenceEtablissementService.getFonctionListForRoleFormateur(
                proprietaire,
                currentEtablissement
            )
        ]
    )
  }

  /**
   *
   */
  def detailProprietes() {
    breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "sujet.detailproprietes.titre"))
    Personne personne = authenticatedPersonne
    Sujet sujet = Sujet.get(params.id)
    [liens             : breadcrumpsServiceProxy.liens,
     sujet             : sujet,
     peutSupprimerSujet: artefactAutorisationService.utilisateurPeutSupprimerArtefact(personne, sujet),
     peutPartagerSujet : artefactAutorisationService.utilisateurPeutPartageArtefact(personne, sujet),
     artefactHelper    : artefactAutorisationService,
     utilisateur       : personne]
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
    render(view: '/sujet/edite', model: [liens             : breadcrumpsServiceProxy.liens,
                                         titreSujet        : sujet.titre,
                                         sujet             : sujet,
                                         sujetEnEdition    : true,
                                         peutSupprimerSujet: artefactAutorisationService.utilisateurPeutSupprimerArtefact(personne, sujet),
                                         peutPartagerSujet : artefactAutorisationService.utilisateurPeutPartageArtefact(personne, sujet),
                                         artefactHelper    : artefactAutorisationService,
                                         utilisateur       : personne])

  }

  /**
   * Action "Supprimer"
   */
  def supprime() {
    Personne personne = authenticatedPersonne
    Sujet sujet = Sujet.get(params.id)
    sujetService.supprimeSujet(sujet, personne)

    if (params.ajax) {
      render ([success: true]) as JSON
    }
    else {
      redirect(action: "mesSujets",
          params: [bcInit: true])
    }
  }

  /**
   * Action "teste"
   */
  def teste() {
    breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "sujet.teste.titre"))
    Personne personne = authenticatedPersonne
    Sujet sujet = Sujet.get(params.id)
    Copie copie = copieService.getCopieTestForSujetAndPersonne(sujet, personne)
    [liens            : breadcrumpsServiceProxy.liens,
     copie            : copie,
     afficheCorrection: false,
     sujet            : sujet,
     artefactHelper   : artefactAutorisationService,
     utilisateur      : personne]
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

    render(view: '/sujet/teste',
        model: [
            liens            : breadcrumpsServiceProxy.liens,
            copie            : copie,
            afficheCorrection: true,
            sujet            : copie.sujet,
            artefactHelper   : artefactAutorisationService,
            utilisateur      : eleve
        ]
    )
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
      render(view: '/sujet/teste', model: [liens            : breadcrumpsServiceProxy.liens,
                                           copie            : copie,
                                           afficheCorrection: copie.dateRemise,
                                           sujet            : copie.sujet,
                                           artefactHelper   : artefactAutorisationService,
                                           utilisateur      : eleve])
    }
  }

  /**
   *
   * Action supprime element
   */
  def supprimeFromSujet() {
    SujetSequenceQuestions sujetQuestion = SujetSequenceQuestions.get(params.id)
    Sujet sujet = sujetQuestion.sujet
    Personne proprietaire = authenticatedPersonne

    if(sujet.estCollaboratif() && sujet.estVerrouilleParAutrui(proprietaire)) {
      flash.errorMessage = 'sujet.enregistre.echec.verrou'
      redirect(
          controller: 'sujet',
          action: 'teste',
          id: sujet.id
      )
      return
    }

    sujet = sujetService.supprimeQuestionFromSujet(sujetQuestion, proprietaire)
    render(view: '/sujet/edite', model: [sujet         : sujet,
                                         titreSujet    : sujet.titre,
                                         sujetEnEdition: true,
                                         liens         : breadcrumpsServiceProxy.liens,
                                         artefactHelper: artefactAutorisationService,
                                         utilisateur   : proprietaire])
  }

/**
 *
 * Action remonte element
 */
  def remonteElement() {
    SujetSequenceQuestions sujetQuestion = SujetSequenceQuestions.get(params.id)
    Sujet sujet = sujetQuestion.sujet
    Personne proprietaire = authenticatedPersonne

    if(sujet.estCollaboratif() && sujet.estVerrouilleParAutrui(proprietaire)) {
      flash.errorMessage = 'sujet.enregistre.echec.verrou'
      redirect(
          controller: 'sujet',
          action: 'teste',
          id: sujet.id
      )
      return
    }

    sujet = sujetService.inverseQuestionAvecLaPrecedente(sujetQuestion, proprietaire)
    render(view: '/sujet/edite', model: [sujet         : sujet,
                                         titreSujet    : sujet.titre,
                                         sujetEnEdition: true,
                                         liens         : breadcrumpsServiceProxy.liens,
                                         artefactHelper: artefactAutorisationService,
                                         utilisateur   : proprietaire])
  }

  /**
   *
   * Action remonte element
   */
  def descendElement() {
    SujetSequenceQuestions sujetQuestion = SujetSequenceQuestions.get(params.id)
    Sujet sujet = sujetQuestion.sujet
    Personne proprietaire = authenticatedPersonne

    if(sujet.estCollaboratif() && sujet.estVerrouilleParAutrui(proprietaire)) {
      flash.errorMessage = 'sujet.enregistre.echec.verrou'
      redirect(
          controller: 'sujet',
          action: 'teste',
          id: sujet.id
      )
      return
    }

    sujet = sujetService.inverseQuestionAvecLaSuivante(sujetQuestion, proprietaire)
    render(view: '/sujet/edite',
        model: [
            sujet         : sujet,
            titreSujet    : sujet.titre,
            sujetEnEdition: true,
            liens         : breadcrumpsServiceProxy.liens,
            artefactHelper: artefactAutorisationService,
            utilisateur   : proprietaire
        ]
    )
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
    breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "sujet.ajouteelement.titre"), props)

    Personne utilisateur = authenticatedPersonne
    Sujet sujet = Sujet.get(params.id)

    if(sujet.estCollaboratif()) {
      // Pose un verrou avant de permettre la modification du sujet
      boolean locked = sujetService.creeVerrou(sujet, authenticatedPersonne)
      if(!locked) {
        flash.errorMessage = 'sujet.enregistre.echec.verrou'
        redirect(
            action: 'teste',
            id: sujet.id
        )
        return
      }
    }



    assert artefactAutorisationService.utilisateurPeutAjouterItem(utilisateur, sujet)

    [
        sujet                             : sujet,
        liens                             : breadcrumpsServiceProxy.liens,
        typesQuestionSupportes            : questionService.typesQuestionsInteractionSupportes,
        typesQuestionSupportesPourCreation: questionService.typesQuestionsInteractionSupportesPourCreation
    ]
  }

  /**
   * Action ajoute séance
   */
  // TODO Cette action duplique une partie de la logique de construction du modèle de l'action SeanceController.edite ; il faut voir s'il est possible de passer par un chain
  def ajouteSeance() {
    breadcrumpsServiceProxy.manageBreadcrumps(
        params,
        message(code: "sujet.ajouteseance.titre")
    )

    Personne personne = authenticatedPersonne
    Sujet sujet = Sujet.get(params.id)

    assert (artefactAutorisationService.utilisateurPeutCreerSeance(personne, sujet))

    def modaliteActivite = new ModaliteActivite(
        enseignant: personne,
        sujet: sujet
    )
    def etablissements = securiteSessionServiceProxy.etablissementList
    def structureEnseignementList =
        profilScolariteService.findProprietesScolariteWithStructureForPersonne(
            personne,
            etablissements
        )*.structureEnseignement.unique {a, b -> a.id <=> b.id }.sort { it.nomAffichage }

    List<Fonction> fonctionList =
        preferenceEtablissementService.getFonctionListForRoleApprenant(
            personne,
            securiteSessionServiceProxy.currentEtablissement
        )

    List<GroupeType> groupeTypeList =
        groupeService.hasGroupeEnt(securiteSessionServiceProxy.currentEtablissement) ?
            [GroupeType.SCOLARITE, GroupeType.ENT] :
            [GroupeType.SCOLARITE]

    render(
        view: '/seance/edite',
        model: [
            liens                      : breadcrumpsServiceProxy.liens,
            currentEtablissement       : securiteSessionServiceProxy.currentEtablissement,
            etablissements             : etablissements,
            fonctionList               : fonctionList,
            groupeTypeList             : groupeTypeList,
            afficheLienCreationDevoir  : false,
            afficheLienCreationActivite: false,
            afficheActiviteCreee       : false,
            afficheDevoirCree          : false,
            modaliteActivite           : modaliteActivite,
            structureEnseignementList  : structureEnseignementList,
            competencesEvaluables      : modaliteActivite.sujet.hasCompetence()
        ]
    )
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
      Sujet sujet = sujetQuestion.sujet

      if(sujet.estCollaboratif() && sujet.estVerrouilleParAutrui(authenticatedPersonne)) {
        flash.errorMessage = 'sujet.enregistre.echec.verrou'
        redirect(
            controller: 'sujet',
            action: 'teste',
            id: sujet.id
        )
        return
      }

      // récupère la nouvelle valeur
      def points = pointsCommand.update_value
      // met à jour
      sujetService.updatePointsForQuestion(
          points,
          sujetQuestion,
          authenticatedPersonne
      )
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
    Personne personne = authenticatedPersonne
    Format parsedFormat = Format.valueOf(format)
    assert (artefactAutorisationService.utilisateurPeutExporterArtefact(personne, sujet, parsedFormat))

    if (!sujet) {
      throw new IllegalStateException(
          "Il n'existe pas de sujet d'id '${params.id}'"
      )
    }

    switch (parsedFormat) {
      case Format.NATIF_JSON:
        JSON json = getSujetAsJson(sujet)
        response.setHeader("Content-disposition", "attachment; filename=${ExportHelper.getFileName(sujet, Format.NATIF_JSON)}")

        response.setCharacterEncoding('UTF-8')
        response.contentType = 'application/tdbase'
        GZIPOutputStream zipOutputStream = new GZIPOutputStream(response.outputStream)
        json.render(new OutputStreamWriter(zipOutputStream, 'UTF-8'))
        break

      case Format.MOODLE_XML:
        def xml = moodleQuizExporterService.toMoodleQuiz(sujet)
        response.setHeader("Content-disposition", "attachment; filename=export.xml")
        render(text: xml, contentType: "text/xml", encoding: "UTF-8")
        break

      default:
        throw new IllegalArgumentException(
            "Le format '$format' n'est pas supporté."
        )
    }
  }

  private JSON getSujetAsJson(Sujet sujet) {
    sujet = sujetExporterService.getSujetPourExport(sujet, authenticatedPersonne)

    ExportMarshallerFactory exportMarshallerFactory = new ExportMarshallerFactory()
    ExportMarshaller exportMarshaller = exportMarshallerFactory.newInstance(attachementService)

    return exportMarshaller.marshall(
        sujet,
        new Date(),
        authenticatedPersonne
    ) as JSON
  }

  /**
   * Action donnant accès au formulaire d'import d'un fichier moodle XML
   */
  def editeImportMoodleXML() {
    breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "sujet.importmoodlexml.titre"))
    Sujet sujet = Sujet.get(params.id)
    Personne proprietaire = authenticatedPersonne
    [
        liens         : breadcrumpsServiceProxy.liens,
        sujet         : sujet,
        etablissements: securiteSessionServiceProxy.etablissementList,
        fichierMaxSize: grailsApplication.config.eliot.fichiers.importexport.maxsize.mega ?:
            grailsApplication.config.eliot.fichiers.maxsize.mega ?: 10
    ]

  }

  /**
   * Action déclenchant l'import du fichier XML
   */
  def importMoodleXML(ImportDansSujetCommand importCommand) {
    Sujet sujet = Sujet.get(importCommand.sujetId)
    MatiereBcn matiere = MatiereBcn.get(importCommand.matiereId)
    Niveau niveau = Niveau.get(importCommand.niveauId)
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
    if (importSuccess) {
      try {
        MoodleQuizImportReport report = moodleQuizImporterService.importMoodleQuiz(
            fichier.bytes,
            sujet,
            new ReferentielEliot(
                matiereBcn: matiere,
                niveau: niveau
            ),
            proprietaire
        )
        flash.report = report
      } catch (Exception e) {
        log.error("Une erreur s'est produite durant l'import du quizz Moodle", e)
        flash.errorMessageCode = e.message
        importSuccess = false
      }
    }
    flash.liens = breadcrumpsServiceProxy.liens
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
    breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "sujet.rapportmoodlexml.titre"))
  }

  /**
   * Action donnant accès au formulaire d'import natif eliot-tdbase d'une question
   */
  def editeImportQuestionNatifTdBase() {
    breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "importexport.NATIF_JSON.import.question.libelle"))
    Sujet sujet = Sujet.get(params.id)
    Personne proprietaire = authenticatedPersonne
    [
        liens         : breadcrumpsServiceProxy.liens,
        sujet         : sujet,
        etablissements: securiteSessionServiceProxy.etablissementList,
        fichierMaxSize: grailsApplication.config.eliot.fichiers.importexport.maxsize.mega ?:
            grailsApplication.config.eliot.fichiers.maxsize.mega ?: 10
    ]
  }

  /**
   * Action déclenchant l'import du fichier question JSON au format natif eliot-tdbase
   * dans un sujet
   */
  def importQuestionNatifTdBase(ImportDansSujetCommand importCommand) {
    Sujet sujet = Sujet.load(importCommand.sujetId)
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
    if (importSuccess) {
      try {
        questionImporterService.importeQuestion(
            ExportMarshaller.parse(
                JSON.parse(
                    new GZIPInputStream(
                        new ByteArrayInputStream(fichier.bytes)
                    ),
                    'UTF-8'
                )
            ).question,
            sujet,
            proprietaire,
            new ReferentielEliot(
                matiereBcn: MatiereBcn.load(importCommand.matiereId),
                niveau: Niveau.load(importCommand.niveauId)
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
      redirect(action: 'edite', id: sujet.id)
    } else {
      redirect(action: 'editeImportQuestionNatifTdBase', id: sujet.id)
    }
  }

  /**
   * Action donnant accès au formulaire d'import natif eliot-tdbase d'un sujet
   */
  def editeImportSujetNatifTdBase() {
    breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "importexport.NATIF_JSON.import.sujet.libelle"))
    Personne proprietaire = authenticatedPersonne
    [
        liens         : breadcrumpsServiceProxy.liens,
        etablissements: securiteSessionServiceProxy.etablissementList,
        fichierMaxSize: grailsApplication.config.eliot.fichiers.importexport.maxsize.mega ?:
            grailsApplication.config.eliot.fichiers.maxsize.mega ?: 10
    ]
  }

  /**
   * Action déclenchant l'import du fichier sujet JSON au format natif eliot-tdbase
   */
  def importSujetNatifTdBase(Long matiereId, Long niveauId) {
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

    Sujet sujet = null
    if (importSuccess) {
      try {
        sujet = sujetImporterService.importeSujet(
            ExportMarshaller.parse(
                JSON.parse(
                    new GZIPInputStream(
                        new ByteArrayInputStream(fichier.bytes)
                    ),
                    'UTF-8'
                )
            ).sujet,
            proprietaire,
            new ReferentielEliot(
                matiereBcn: MatiereBcn.load(matiereId),
                niveau: Niveau.load(niveauId)
            )
        )
      } catch (Exception e) {
        log.error("Une erreur s'est produite durant l'import du sujet", e)
        flash.errorMessageCode = "Format de fichier incorrect (cause: ${e.message})"
        importSuccess = false
      }
    }
    flash.liens = breadcrumpsServiceProxy.liens
    if (importSuccess) {
      flash.messageCode = "Le sujet a été correctement importé."
      redirect(action: 'edite', id: sujet.id)
    } else {
      redirect(action: 'editeImportSujetNatifTdBase')
    }
  }

  def creeVerrou(Long id) {
    Sujet sujet = Sujet.get(id)
    sujetService.creeVerrou(sujet, authenticatedPersonne)
    render sujet as JSON
  }

  def supprimeVerrou(Long id) {
    Sujet sujet = Sujet.get(id)
    sujetService.supprimeVerrou(sujet, authenticatedPersonne)
    redirect(action: 'teste', id: id)
  }

  def masque(Long id) {
    Sujet sujet = Sujet.get(id)
    Personne personne = authenticatedPersonne
    SujetMasque sujetMasque = sujetService.masque(personne, sujet)
    render sujetMasque as JSON
  }

  def annuleMasque(Long id) {
    Sujet sujet = Sujet.get(id)
    Personne personne = authenticatedPersonne
    sujetService.annuleMasque(personne, sujet)
    render sujet as JSON
  }


  def finalise(Long id) {
    Sujet sujet = Sujet.get(id)
    sujetService.finalise(sujet, new Date(params.long('lastUpdated')), authenticatedPersonne)

    if (sujet.termine) {
      sujetService.supprimeVerrou(sujet, authenticatedPersonne)
      redirect(action: 'teste', id: id)
    }
    else {
      flash.errorMessageCode = "Le sujet n'a pas pu être finalisé car celui-ci vient d'être modifié."
      redirect(action: 'edite', id: id)
    }

  }

  def annuleFinalisation(Long id) {
    Sujet sujet = Sujet.get(id)
    sujetService.annuleFinalise(sujet, authenticatedPersonne)

    if (sujet.termine) {
      flash.errorMessageCode = "La finalisation du sujet n'a pas pu être annulée."
    }
    redirect(action: 'teste', id: id)
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

  Boolean afficheSujetMasque

  Map toParams() {
    [patternTitre       : patternTitre,
     patternAuteur      : patternAuteur,
     patternPresentation: patternPresentation,
     matiereId          : matiereId,
     typeId             : typeId,
     niveauId           : niveauId,
     afficheSujetMasque : afficheSujetMasque]
  }

}

class RechercheContributeurCommand {
  String patternCode
  Long etablissementId
  Long fonctionId

  Long offset
  Long max

  Pagination getPagination() {
    if(!offset && !max) {
      return null
    }

    return new Pagination(
        max: max,
        offset: offset
    )
  }
}

class RechercheContributeurResultat {
  Long nombreTotal = 0
  Long offset = 0
  List<Personne> formateurList = []
}