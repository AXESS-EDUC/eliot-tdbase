package org.lilie.services.eliot.tdbase

import grails.plugins.springsecurity.SpringSecurityService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService

class SujetController {

  static defaultAction = "recherche"

  SujetService sujetService
  SpringSecurityService springSecurityService
  ProfilScolariteService profilScolariteService

  /**
   *
   * Action "recherche"
   */
  def recherche() {
    [
            titrePage: message(code: "sujet.recherche.titre"),
            afficheFormulaire: true
    ]
  }

  /**
   *
   * Action "mesSujets"
   */
  def mesSujets() {
    params.max = Math.min(params.max ? params.int('max') : 10, 100)
    Personne personne = authenticatedPersonne
    def model = [
            titrePage: message(code: "sujet.messujets.titre"),
            afficheFormulaire: false,
            sujets: sujetService.findSujetsForProprietaire(
                    personne,
                    params
            ),
            sujetsCount: sujetService.nombreSujetsForProprietaire(personne)
    ]
    render(view: "recherche", model: model)
  }

  /**
   *
   * Action "nouveau"
   */
  def nouveau() {
    render(view: "edite", model: [
           titrePage: message(code: "sujet.nouveau.titre"),
           titreSujet: message(code: "sujet.nouveau.titre")
           ])
  }

  /**
   *
   * Action "edite"
   */
  def edite() {
    Sujet sujet = Sujet.get(params.id)
    String titrePage = message(code: "sujet.edite.titre")
    [
            titrePage: titrePage,
            titreSujet: message(code: sujet.titre),
            sujet: sujet,
            sujetEnEdition: true
    ]
  }

  /**
   *
   * Action "editeProprietes"
   */
  def editeProprietes() {
    Sujet sujet = Sujet.get(params.id)
    Personne proprietaire = authenticatedPersonne
    render(view: "edite-proprietes", model: [
           sujet: sujet,
           typesSujet : sujetService.getAllSujetTypes(),
           matieres: profilScolariteService.findMatieresForPersonne(proprietaire),
           niveaux: profilScolariteService.findNiveauxForPersonne(proprietaire)
           ])
  }

  /**
   *
   * Action "enregistrer"
   */
  def enregistre(NouveauSujetCommand sujetCmd) {
    Sujet sujet
    String titrePage = message(code: "sujet.edite.titre")
    boolean sujetEnEdition = false
    Personne personne = authenticatedPersonne
    if (sujetCmd.sujetId) {
      sujet = Sujet.get(sujetCmd.sujetId)
      sujetEnEdition = true
      sujetService.setTitreSujet(sujet,sujetCmd.sujetTitre,personne)
    } else {
      sujet = sujetService.createSujet(personne, sujetCmd.sujetTitre)
    }
    if (!sujet.hasErrors()) {
      request.messageCode = "sujet.enregistre.succes"
      sujetEnEdition = true
    } else if (!sujetEnEdition) {
      titrePage = message(code: "sujet.nouveau.titre")
    }
    render(view: "edite", model: [
           titrePage: titrePage,
           titreSujet: sujet.titre,
           sujet: sujet,
           sujetEnEdition: sujetEnEdition
           ])
  }

  def enregistrePropriete() {
    Sujet sujet = Sujet.get(params.id)
    Personne proprietaire = authenticatedPersonne
    Sujet sujetModifie = sujetService.setProprietes(sujet,params, proprietaire)
    if (!sujet.hasErrors()) {
      request.messageCode = "sujet.enregistre.succes"
    }
    render(view: "edite-proprietes", model: [
           sujet: sujetModifie,
           typesSujet : sujetService.getAllSujetTypes(),
           matieres: profilScolariteService.findMatieresForPersonne(proprietaire),
           niveaux: profilScolariteService.findNiveauxForPersonne(proprietaire)
           ])
  }
}

class NouveauSujetCommand {
  String sujetTitre
  Long sujetId
}