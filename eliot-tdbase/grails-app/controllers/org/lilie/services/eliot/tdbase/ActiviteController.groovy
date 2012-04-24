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
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService
import org.lilie.services.eliot.tice.utils.BreadcrumpsService

class ActiviteController {

  static defaultAction = "listeSeances"

  BreadcrumpsService breadcrumpsService
  ModaliteActiviteService modaliteActiviteService
  ProfilScolariteService profilScolariteService
  CopieService copieService
  ReponseService reponseService

  /**
   *
   * Action correspondant à la page d'accueil
   */
  def index() {
    params.max = Math.min(params.max ? params.int('max') : 5, 100)
    breadcrumpsService.manageBreadcrumps(params, message(code: "accueil.titre"))
    Personne personne = authenticatedPersonne
    def modalitesActivites = modaliteActiviteService.findModalitesActivitesForApprenant(personne,
                                                                                        params)
    def copies = copieService.findCopiesEnVisualisationForApprenant(personne,
                                                                    params)
    [liens: breadcrumpsService.liens,
            seances: modalitesActivites,
            copies: copies]
  }

  /**
   *
   * Action "liste des séances"
   */
  def listeSeances() {
    def maxItems = grailsApplication.config.eliot.listes.max
    params.max = Math.min(params.max ? params.int('max') : maxItems, 100)
    breadcrumpsService.manageBreadcrumps(params, message(code: "seance.liste.titre"))
    Personne personne = authenticatedPersonne
    def modalitesActivites = modaliteActiviteService.findModalitesActivitesForApprenant(personne,
                                                                                        params)
    boolean affichePager = false
    if (modalitesActivites.totalCount > maxItems) {
      affichePager = true
    }
    render(view: '/activite/seance/liste', model: [liens: breadcrumpsService.liens,
            seances: modalitesActivites,
            affichePager: affichePager])
  }

  /**
   *
   * Action "Faire sujet"
   */
  def travailleCopie() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "copie.edition.titre"))
    Personne eleve = authenticatedPersonne
    ModaliteActivite seance = ModaliteActivite.get(params.id)
    Copie copie = copieService.getCopieForModaliteActiviteAndEleve(seance, eleve)
    render(view: '/activite/copie/edite', model: [liens: breadcrumpsService.liens,
            copie: copie])
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
    request.messageCode = "copie.enregistre.succes"

    render(view: '/activite/copie/edite', model: [liens: breadcrumpsService.liens,
            copie: copie])
  }

  /**
   *
   * Action enregistre  la copie
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

      render(view: '/activite/copie/edite', model: [liens: breadcrumpsService.liens,
              copie: copie])
    }
  }

  /**
   * Action liste résulats
   *
   */
  def listeResultats() {
    params.max = Math.min(params.max ? params.int('max') : 10, 100)
    breadcrumpsService.manageBreadcrumps(params, message(code: "seance.resultats.titre"))
    Personne personne = authenticatedPersonne
    def copies = copieService.findCopiesEnVisualisationForApprenant(personne,
                                                                    params)
    render(view: '/activite/seance/resultats', model: [liens: breadcrumpsService.liens,
            copies: copies])
  }

  /**
   *
   * Action visualise copie
   */
  def visualiseCopie() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "copie.visualisation.titre"))
    Copie copie = Copie.get(params.id)
    render(view: '/activite/copie/visualise', model: [liens: breadcrumpsService.liens,
            copie: copie])
  }


}

class ListeReponsesCopie {
  List<ReponseCopie> listeReponses = []
}





