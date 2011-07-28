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
    breadcrumpsService.manageBreadcrumps(params,message(code: "sujet.recherche.titre"))
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
    breadcrumpsService.manageBreadcrumps(params,message(code: "sujet.messujets.titre"))
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
    breadcrumpsService.manageBreadcrumps(params,message(code: "sujet.nouveau.titre"))
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
    breadcrumpsService.manageBreadcrumps(params,message(code: "sujet.edite.titre"))
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
    breadcrumpsService.manageBreadcrumps(params,message(code: "sujet.editeproprietes.titre"))
    Sujet sujet = Sujet.get(params.id)
    Personne proprietaire = authenticatedPersonne
    render(view: "edite-proprietes", model: [
           liens: breadcrumpsService.liens,
           lienRetour:breadcrumpsService.lienRetour(),
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
    Sujet sujetModifie = sujetService.setProprietes(sujet, params, proprietaire)
    if (!sujet.hasErrors()) {
      request.messageCode = "sujet.enregistre.succes"
    }
    render(view: "edite-proprietes", model: [
           liens: breadcrumpsService.liens,
           lienRetour: breadcrumpsService.lienRetour(),
           sujet: sujetModifie,
           typesSujet: sujetService.getAllSujetTypes(),
           matieres: profilScolariteService.findMatieresForPersonne(proprietaire),
           niveaux: profilScolariteService.findNiveauxForPersonne(proprietaire)
           ])
  }



}

class NouveauSujetCommand {
  String sujetTitre
  Long sujetId
}