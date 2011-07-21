package org.lilie.services.eliot.tdbase

import grails.plugins.springsecurity.SpringSecurityService
import org.lilie.services.eliot.tice.annuaire.Personne

class SujetController {

  static defaultAction = "recherche"

  SujetService sujetService
  SpringSecurityService springSecurityService

  /**
   *
   * Action "recherche"
   */
  def recherche() {
    [
      titrePage:message(code: "sujet.recherche.titre"),
      afficheFormulaire:true
    ]
  }

  /**
   *
   * Action "mesSujets"
   */
  def mesSujets() {
    def model = [
      titrePage:message(code: "sujet.messujets.titre"),
      afficheFormulaire:false
    ]
    render(view:"recherche", model: model)
  }

  /**
   *
   * Action "nouveau"
   */
  def nouveau() {
    render(view:"edite", model: [
           titrePage:message(code:"sujet.nouveau.titre"),
           titreSujet:message(code:"sujet.nouveau.titre")
           ])
  }

  /**
   *
   * Action "editeProprietes"
   */
  def editeProprietes() {
    render(view:"edite-proprietes")
  }

  /**
   *
   * Action "enregistrer"
   */
  def enregistre() {
    String titre = params.sujetTitre
    def id = params.sujetId
    Sujet sujet
    String titrePage
    if (id) {
       sujet = Sujet.get(id)
    } else {
      Personne personne = Personne.get(springSecurityService.currentUser.personneId)
      sujet = sujetService.createSujet(personne,titre)
      titrePage = message(code:"sujet.nouveau.titre")
    }
    if (!sujet.hasErrors()) {
      flash.message = "sujet.enregistre.succes"
    }
    render(view:"edite",  model: [
           titrePage:titrePage,
           titreSujet:message(code:sujet.titre),
           sujet: sujet
           ])
  }
}
