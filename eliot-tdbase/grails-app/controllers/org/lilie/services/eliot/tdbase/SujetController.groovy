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
import org.lilie.services.eliot.tdbase.securite.RoleApplicatif
import org.lilie.services.eliot.tdbase.securite.SecuriteSessionService
import org.lilie.services.eliot.tdbase.xml.MoodleQuizExporterService
import org.lilie.services.eliot.tdbase.xml.MoodleQuizImportReport
import org.lilie.services.eliot.tdbase.xml.MoodleQuizImporterService
import org.lilie.services.eliot.tice.AttachementService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Fonction
import org.lilie.services.eliot.tice.scolarite.FonctionService
import org.lilie.services.eliot.tice.nomenclature.MatiereBcn
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService
import org.lilie.services.eliot.tice.scolarite.ScolariteService
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
                params)
        boolean affichePager = false
        if (sujets.totalCount > maxItems) {
            affichePager = true
        }

        [liens            : breadcrumpsServiceProxy.liens,
         afficheFormulaire: true,
         affichePager     : affichePager,
         typesSujet       : sujetService.getAllSujetTypes(),
         matiereBcns      : matiereBcn != null ? [matiereBcn] : [],
         niveaux          : profilScolariteService.findNiveauxForPersonne(personne),
         sujets           : sujets,
         rechercheCommand : rechCmd,
         artefactHelper   : artefactAutorisationService,
         utilisateur      : personne]
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
        render(view: "editeProprietes", model: [liens         : breadcrumpsServiceProxy.liens,
                                                sujet         : new Sujet(),
                                                typesSujet    : sujetService.getAllSujetTypes(),
                                                artefactHelper: artefactAutorisationService,
                                                matieres      : profilScolariteService.findMatieresForPersonne(proprietaire),
                                                matiereBcns   : [],
                                                etablissements     : securiteSessionServiceProxy.etablissementList,
                                                niveaux       : profilScolariteService.findNiveauxForPersonne(proprietaire)])
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

    /**
     *
     * Action "editeProprietes"
     */
    def editeProprietes() {
        breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "sujet.editeproprietes.titre"))
        Sujet sujet = Sujet.get(params.id)
        Personne proprietaire = authenticatedPersonne
        render(view: "editeProprietes", model: [liens         : breadcrumpsServiceProxy.liens,
                                                sujet         : sujet,
                                                artefactHelper: artefactAutorisationService,
                                                typesSujet    : sujetService.getAllSujetTypes(),
                                                matieres      : profilScolariteService.findMatieresForPersonne(proprietaire),
                                                matiereBcns   : sujet.matiereBcn != null ? [sujet.matiereBcn] : [],
                                                etablissements     : securiteSessionServiceProxy.etablissementList,
                                                niveaux       : profilScolariteService.findNiveauxForPersonne(proprietaire)])
    }

    /**
     *
     * Action "edite"
     */
    def edite() {
        breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "sujet.edite.titre"))
        Personne personne = authenticatedPersonne
        Sujet sujet = Sujet.get(params.id)
        [liens             : breadcrumpsServiceProxy.liens,
         titreSujet        : sujet.titre,
         sujet             : sujet,
         sujetEnEdition    : true,
         peutSupprimerSujet: artefactAutorisationService.utilisateurPeutSupprimerArtefact(personne, sujet),
         peutPartagerSujet : artefactAutorisationService.utilisateurPeutPartageArtefact(personne, sujet),
         artefactHelper    : artefactAutorisationService,
         utilisateur       : personne]
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
        render(view: "editeProprietes", model: [liens     : breadcrumpsServiceProxy.liens,
                                                sujet     : sujet,
                                                typesSujet: sujetService.getAllSujetTypes(),
                                                etablissements: securiteSessionServiceProxy.etablissementList,
                                                artefactHelper: artefactAutorisationService,
                                                niveaux       : profilScolariteService.findNiveauxForPersonne(proprietaire)])
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
        redirect(action: "mesSujets",
                params: [bcInit: true])

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

        render(view: '/sujet/teste', model: [liens            : breadcrumpsServiceProxy.liens,
                                             copie            : copie,
                                             afficheCorrection: true,
                                             sujet            : copie.sujet,
                                             artefactHelper   : artefactAutorisationService,
                                             utilisateur      : eleve])
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
        Personne proprietaire = authenticatedPersonne
        Sujet sujet = sujetService.supprimeQuestionFromSujet(sujetQuestion, proprietaire)
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
        Personne proprietaire = authenticatedPersonne
        Sujet sujet = sujetService.inverseQuestionAvecLaPrecedente(sujetQuestion, proprietaire)
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
        Personne proprietaire = authenticatedPersonne
        Sujet sujet = sujetService.inverseQuestionAvecLaSuivante(sujetQuestion, proprietaire)
        render(view: '/sujet/edite', model: [sujet         : sujet,
                                             titreSujet    : sujet.titre,
                                             sujetEnEdition: true,
                                             liens         : breadcrumpsServiceProxy.liens,
                                             artefactHelper: artefactAutorisationService,
                                             utilisateur   : proprietaire])
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
        Sujet sujet = Sujet.get(params.id)

        [sujet                             : sujet,
         liens                             : breadcrumpsServiceProxy.liens,
         typesQuestionSupportes            : questionService.typesQuestionsInteractionSupportes,
         typesQuestionSupportesPourCreation: questionService.typesQuestionsInteractionSupportesPourCreation]
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
        def modaliteActivite = new ModaliteActivite(
                enseignant: personne,
                sujet: sujet
        )
        def etablissements = securiteSessionServiceProxy.etablissementList
        def structureEnseignementList =
                profilScolariteService.findProprietesScolariteWithStructureForPersonne(
                        personne,
                        etablissements
                )*.structureEnseignement

        List<Fonction> fonctionList =
                preferenceEtablissementService.getFonctionListForRoleApprenant(
                        personne,
                        securiteSessionServiceProxy.currentEtablissement
                )

        render(
                view: '/seance/edite',
                model: [
                        liens                      : breadcrumpsServiceProxy.liens,
                        currentEtablissement       : securiteSessionServiceProxy.currentEtablissement,
                        etablissements             : etablissements,
                        fonctionList               : fonctionList,
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

        if (!sujet) {
            throw new IllegalStateException(
                    "Il n'existe pas de sujet d'id '${params.id}'"
            )
        }

        switch (format) {
            case Format.NATIF_JSON.name():
                JSON json = getSujetAsJson(sujet)
                response.setHeader("Content-disposition", "attachment; filename=${ExportHelper.getFileName(sujet, Format.NATIF_JSON)}")

                response.setCharacterEncoding('UTF-8')
                response.contentType = 'application/tdbase'
                GZIPOutputStream zipOutputStream = new GZIPOutputStream(response.outputStream)
                json.render(new OutputStreamWriter(zipOutputStream, 'UTF-8'))
                break

            case Format.MOODLE_XML.name():
                def xml = moodleQuizExporterService.toMoodleQuiz(sujet)
                response.setHeader("Content-disposition", "attachment; filename=export.xml")
                render(text: xml, contentType: "text/xml", encoding: "UTF-8")
                break

            default:
                throw new IllegalArgumentException(
                        "Le format '$format' est inconnu."
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
                matieres      : profilScolariteService.findMatieresForPersonne(proprietaire),
                etablissements: securiteSessionServiceProxy.etablissementList,
                niveaux       : profilScolariteService.findNiveauxForPersonne(proprietaire),
                fichierMaxSize: grailsApplication.config.eliot.fichiers.importexport.maxsize.mega ?:
                        grailsApplication.config.eliot.fichiers.maxsize.mega ?: 10
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
                                matiere: matiere,
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
                matieres      : profilScolariteService.findMatieresForPersonne(proprietaire),
                etablissements: securiteSessionServiceProxy.etablissementList,
                niveaux       : profilScolariteService.findNiveauxForPersonne(proprietaire),
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
                                matiere: Matiere.load(importCommand.matiereId),
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
                etablissements     : securiteSessionServiceProxy.etablissementList,
                niveaux       : profilScolariteService.findNiveauxForPersonne(proprietaire),
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
        [patternTitre       : patternTitre,
         patternAuteur      : patternAuteur,
         patternPresentation: patternPresentation,
         matiereId          : matiereId,
         typeId             : typeId,
         niveauId           : niveauId]
    }

}