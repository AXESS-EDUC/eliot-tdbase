package org.lilie.services.eliot.tdbase

import grails.plugins.springsecurity.SpringSecurityService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService
import org.lilie.services.eliot.tice.utils.BreadcrumpsService

class SujetController {

  static defaultAction = "mesSujets"

  SujetService sujetService
  SpringSecurityService springSecurityService
  ProfilScolariteService profilScolariteService
  BreadcrumpsService breadcrumpsService

  /**
   *
   * Action "recherche"
   */
  def recherche(RechercheSujetCommand rechCmd) {
    params.max = Math.min(params.max ? params.int('max') : 10, 100)
    breadcrumpsService.manageBreadcrumps(params, message(code: "sujet.recherche.titre"))
    Personne personne = authenticatedPersonne
    def sujets = sujetService.findSujets(
            personne,
            rechCmd.patternTitre,
            rechCmd.patternAuteur,
            rechCmd.patternPresentation,
            Matiere.get(rechCmd.matiereId),
            Niveau.get(rechCmd.niveauId),
            SujetType.get(rechCmd.typeId),
            params
    )
    [
            liens: breadcrumpsService.liens,
            afficheFormulaire: true,
            typesSujet: sujetService.getAllSujetTypes(),
            matieres: profilScolariteService.findMatieresForPersonne(personne),
            niveaux: profilScolariteService.findNiveauxForPersonne(personne),
            sujets: sujets,
            rechercheCommand: rechCmd
    ]
  }

  /**
   *
   * Action "mesSujets"
   */
  def mesSujets() {
    params.max = Math.min(params.max ? params.int('max') : 10, 100)
    breadcrumpsService.manageBreadcrumps(params, message(code: "sujet.messujets.titre"))
    Personne personne = authenticatedPersonne
    def model = [
            liens: breadcrumpsService.liens,
            afficheFormulaire: false,
            sujets: sujetService.findSujetsForProprietaire(
                    personne,
                    params)
    ]
    render(view: "recherche", model: model)
  }

  /**
   *
   * Action "nouveau"
   */
  def nouveau() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "sujet.nouveau.titre"))
    render(view: "edite", model: [
           liens: breadcrumpsService.liens,
           titreSujet: message(code: "sujet.nouveau.titre")
           ])
  }

  /**
   *
   * Action "edite"
   */
  def edite() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "sujet.edite.titre"))
    Sujet sujet = Sujet.get(params.id)
    [
            liens: breadcrumpsService.liens,
            titreSujet: sujet.titre,
            sujet: sujet,
            sujetEnEdition: true
    ]
  }

  /**
   *
   * Action "editeProprietes"
   */
  def editeProprietes() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "sujet.editeproprietes.titre"))
    Sujet sujet = Sujet.get(params.id)
    Personne proprietaire = authenticatedPersonne
    render(view: "editeProprietes", model: [
           liens: breadcrumpsService.liens,
           lienRetour: breadcrumpsService.lienRetour(),
           sujet: sujet,
           typesSujet: sujetService.getAllSujetTypes(),
           matieres: profilScolariteService.findMatieresForPersonne(proprietaire),
           niveaux: profilScolariteService.findNiveauxForPersonne(proprietaire)
           ])
  }

  /**
   *
   * Action supprime element
   */
  def supprimeFromSujet() {
    SujetSequenceQuestions sujetQuestion = SujetSequenceQuestions.get(params.id)
    Personne proprietaire = authenticatedPersonne
    Sujet sujet = sujetService.supprimeQuestionFromSujet(sujetQuestion,proprietaire)
    render(view: '/sujet/edite', model:[
            sujet: sujet,
            titreSujet: sujet.titre,
            sujetEnEdition: true,
            liens: breadcrumpsService.liens
    ])
  }

/**
   *
   * Action remonte element
   */
  def remonteElement() {
    SujetSequenceQuestions sujetQuestion = SujetSequenceQuestions.get(params.id)
    Personne proprietaire = authenticatedPersonne
    Sujet sujet = sujetService.inverseQuestionAvecLaPrecedente(sujetQuestion,proprietaire)
    render(view: '/sujet/edite', model:[
            sujet: sujet,
            titreSujet: sujet.titre,
            sujetEnEdition: true,
            liens: breadcrumpsService.liens
    ])
  }

  /**
   *
   * Action remonte element
   */
  def descendElement() {
    SujetSequenceQuestions sujetQuestion = SujetSequenceQuestions.get(params.id)
    Personne proprietaire = authenticatedPersonne
    Sujet sujet = sujetService.inverseQuestionAvecLaSuivante(sujetQuestion,proprietaire)
    render(view: '/sujet/edite', model:[
            sujet: sujet,
            titreSujet: sujet.titre,
            sujetEnEdition: true,
            liens: breadcrumpsService.liens
    ])
  }


  /**
   *
   * Action "enregistrer"
   */
  def enregistre(NouveauSujetCommand sujetCmd) {
    Sujet sujet
    boolean sujetEnEdition = false
    Personne personne = authenticatedPersonne
    if (sujetCmd.sujetId) {
      sujet = Sujet.get(sujetCmd.sujetId)
      sujetEnEdition = true
      sujetService.updateTitreSujet(sujet, sujetCmd.sujetTitre, personne)
    } else {
      sujet = sujetService.createSujet(personne, sujetCmd.sujetTitre)
    }
    if (!sujet.hasErrors()) {
      request.messageCode = "sujet.enregistre.succes"
      if (!sujetEnEdition) {
        def params = [:]
        params."${BreadcrumpsService.PARAM_BREADCRUMPS_INIT}" = true
        params.id = sujet.id
        params.action = "edite"
        params.controller = "sujet"
        breadcrumpsService.manageBreadcrumps(params,
              message(code: "sujet.edite.titre"))
        sujetEnEdition = true
      }
    }
    render(view: "edite", model: [
           liens: breadcrumpsService.liens,
           titreSujet: sujet.titre,
           sujet: sujet,
           sujetEnEdition: sujetEnEdition
           ])
  }


  /**
   *
   * Action "enregistrerPropriete
   */
  def enregistrePropriete() {
    Sujet sujet = Sujet.get(params.id)
    Personne proprietaire = authenticatedPersonne
    Sujet sujetModifie = sujetService.updateProprietes(sujet, params, proprietaire)
    if (!sujet.hasErrors()) {
      request.messageCode = "sujet.enregistre.succes"
    }
    render(view: "editeProprietes", model: [
           liens: breadcrumpsService.liens,
           lienRetour: breadcrumpsService.lienRetour(),
           sujet: sujetModifie,
           typesSujet: sujetService.getAllSujetTypes(),
           matieres: profilScolariteService.findMatieresForPersonne(proprietaire),
           niveaux: profilScolariteService.findNiveauxForPersonne(proprietaire)
           ])
  }

  /**
   *
   * Action ajoute element
   */
  def ajouteElement() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "sujet.ajouteelement.titre"))
    Sujet sujet = Sujet.get(params.id)
    [
            sujet: sujet,
            liens: breadcrumpsService.liens
    ]
  }


}

class NouveauSujetCommand {
  String sujetTitre
  Long sujetId
}

class RechercheSujetCommand {
  String patternTitre
  String patternAuteur
  String patternPresentation

  Long matiereId
  Long typeId
  Long niveauId

  Map toParams() {
    [
            patternTitre: patternTitre,
            patternAuteur: patternAuteur,
            patternPresentation: patternPresentation,
            matiereId: matiereId,
            typeId: typeId,
            niveauId: niveauId
    ]
  }

}