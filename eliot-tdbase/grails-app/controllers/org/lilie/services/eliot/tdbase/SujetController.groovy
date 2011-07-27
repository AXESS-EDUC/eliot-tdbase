package org.lilie.services.eliot.tdbase

import grails.plugins.springsecurity.SpringSecurityService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService
import org.lilie.services.eliot.tice.utils.BreadcrumpsService

class SujetController {

  static defaultAction = "recherche"

  SujetService sujetService
  SpringSecurityService springSecurityService
  ProfilScolariteService profilScolariteService
  BreadcrumpsService breadcrumpsService

  /**
   *
   * Action "recherche"
   */
  def recherche() {
    manageBreadcrumps(message(code: "sujet.recherche.titre"))
    [
            liens: message(code: "sujet.recherche.titre"),
            afficheFormulaire: true
    ]
  }

  /**
   *
   * Action "mesSujets"
   */
  def mesSujets() {
    manageBreadcrumps(message(code: "sujet.messujets.titre"))
    params.max = Math.min(params.max ? params.int('max') : 10, 100)
    Personne personne = authenticatedPersonne
    def model = [
            liens: breadcrumpsService.liens,
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
    manageBreadcrumps(message(code: "sujet.nouveau.titre"))
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
    manageBreadcrumps(message(code: "sujet.edite.titre"))
    Sujet sujet = Sujet.get(params.id)
    [
            liens: breadcrumpsService.liens,
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
    manageBreadcrumps(message(code: "sujet.editeproprietes.titre"))
    Sujet sujet = Sujet.get(params.id)
    Personne proprietaire = authenticatedPersonne
    render(view: "edite-proprietes", model: [
           liens: breadcrumpsService.liens,
           sujet: sujet,
           typesSujet: sujetService.getAllSujetTypes(),
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
      sujetService.setTitreSujet(sujet, sujetCmd.sujetTitre, personne)
    } else {
      sujet = sujetService.createSujet(personne, sujetCmd.sujetTitre)
    }
    if (!sujet.hasErrors()) {
      request.messageCode = "sujet.enregistre.succes"
      sujetEnEdition = true
    } else if (!sujetEnEdition) {
      titrePage = message(code: "sujet.nouveau.titre")
    }
    manageBreadcrumps(titrePage)
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
    manageBreadcrumps(message(code: "sujet.editeproprietes.titre"))
    Sujet sujet = Sujet.get(params.id)
    Personne proprietaire = authenticatedPersonne
    Sujet sujetModifie = sujetService.setProprietes(sujet, params, proprietaire)
    if (!sujet.hasErrors()) {
      request.messageCode = "sujet.enregistre.succes"
    }
    render(view: "edite-proprietes", model: [
           liens: breadcrumpsService.liens,
           sujet: sujetModifie,
           typesSujet: sujetService.getAllSujetTypes(),
           matieres: profilScolariteService.findMatieresForPersonne(proprietaire),
           niveaux: profilScolariteService.findNiveauxForPersonne(proprietaire)
           ])
  }


  private def manageBreadcrumps(String libelle) {
    if (params.initialiseBreadcrumps) {
      breadcrumpsService.initialiseBreadcrumps()
    }
    if (params.breadcrumpsIndex) {
      breadcrumpsService.onClikSurLienBreadcrumps(params.breadcrumpsIndex as Integer)
    } else {
      breadcrumpsService.onClickSurNouveauLien(params.action,
                                               params.controller,
                                               libelle,
                                               params
      )
    }
  }

}

class NouveauSujetCommand {
  String sujetTitre
  Long sujetId
}