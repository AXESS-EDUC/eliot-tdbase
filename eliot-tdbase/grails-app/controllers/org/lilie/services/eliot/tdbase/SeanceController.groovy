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

import groovy.json.JsonBuilder
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService
import org.lilie.services.eliot.tice.scolarite.ProprietesScolarite
import org.lilie.services.eliot.tice.utils.BreadcrumpsService
import org.lilie.services.eliot.tice.utils.NumberUtils

class SeanceController {

  static defaultAction = "liste"

  BreadcrumpsService breadcrumpsService
  ModaliteActiviteService modaliteActiviteService
  CopieService copieService
  ProfilScolariteService profilScolariteService
  CahierTextesService cahierTextesService
  NotesService notesService

/**
 *
 * Action "edite"
 */
  def edite() {
    ModaliteActivite modaliteActivite
    Personne personne = authenticatedPersonne
    def afficheLienCreationDevoir = false
    def afficheLienCreationActivite = false
    def afficheActiviteCreee = false
    def afficheDevoirCree = false
    def lienBookmarkable = null
    List<ServiceInfo> services = []
    List<CahierTextesInfo> cahiers = []
    List<ChapitreInfo> chapitres = []
    if (params.creation) {
      modaliteActivite = new ModaliteActivite(enseignant: personne)
      params.bcInit = true
    } else {
      modaliteActivite = ModaliteActivite.get(params.id)
      lienBookmarkable = createLink(controller: "accueil", action: "activite",
                                    id: modaliteActivite.id,
                                    absolute: true,
                                    params: [sujetId: modaliteActivite.sujetId])
      def strongCheck = grailsApplication.config.eliot.interfacage.strongCheck as Boolean
      afficheLienCreationDevoir = modaliteActiviteService.canCreateNotesDevoirForModaliteActivite(modaliteActivite,
                                                                                                  personne,
                                                                                                  strongCheck)
      afficheLienCreationActivite = modaliteActiviteService.canCreateTextesActiviteForModaliteActivite(modaliteActivite,
                                                                                                       personne,
                                                                                                       strongCheck)
      if (!afficheLienCreationDevoir) {
        afficheDevoirCree = modaliteActiviteService.modaliteActiviteHasNotesDevoir(modaliteActivite,
                                                                                   personne,
                                                                                   strongCheck)
      } else {
        services = notesService.findServicesEvaluablesByModaliteActivite(modaliteActivite,
                                                                         personne,
                                                                         codePorteur)
      }
      if (!afficheLienCreationActivite) {
        afficheActiviteCreee = modaliteActiviteService.modaliteActiviteHasTextesActivite(modaliteActivite,
                                                                                         personne,
                                                                                         strongCheck)
      } else {
        cahiers = cahierTextesService.findCahiersTextesInfoByModaliteActivite(modaliteActivite,
                                                                              personne,
                                                                              codePorteur)
      }
    }
    breadcrumpsService.manageBreadcrumps(params, message(code: "seance.edite.titre"), [services: services])
    def proprietesScolarite = profilScolariteService.findProprietesScolariteWithStructureForPersonne(personne)
    render(view: '/seance/edite', model: [liens: breadcrumpsService.liens,
            lienBookmarkable: lienBookmarkable,
            afficheLienCreationDevoir: afficheLienCreationDevoir,
            afficheLienCreationActivite: afficheLienCreationActivite,
            afficheActiviteCreee: afficheActiviteCreee,
            afficheDevoirCree: afficheDevoirCree,
            modaliteActivite: modaliteActivite,
            proprietesScolarite: proprietesScolarite,
            cahiers: cahiers,
            chapitres: chapitres,
            services: services])
  }

  /**
   * Action updateChapitres
   */
  def updateChapitres() {
    Personne personne = authenticatedPersonne
    List<ChapitreInfo> chapitres = []
    if (params.cahierId != 'null') {
      def cahierId = params.cahierId as Long
      chapitres = cahierTextesService.getChapitreInfosForCahierId(cahierId,
                                                                  personne,
                                                                  codePorteur)
    }
    render(view: "/seance/_selectChapitres", model: [chapitres: chapitres])
  }

  /**
   *
   * Action "enregistre"
   */
  def enregistre() {
    ModaliteActivite modaliteActivite
    Personne personne = authenticatedPersonne
    def propsId = params.proprietesScolariteSelectionId
    if (propsId && propsId != 'null') {
      ProprietesScolarite props = ProprietesScolarite.get(params.proprietesScolariteSelectionId)
      params.'structureEnseignement.id' = props.structureEnseignement.id
      if (props.matiere) {
        params.'matiere.id' = props.matiere.id
      }
    }
    if (params.id) {
      modaliteActivite = ModaliteActivite.get(params.id)
      modaliteActiviteService.updateProprietes(modaliteActivite, params, personne)
    } else {
      modaliteActivite = modaliteActiviteService.createModaliteActivite(params, personne)
    }

    if (!modaliteActivite.hasErrors()) {
      flash.messageCode = "seance.enregistre.succes"
      tryInsertActiviteForModaliteActivite(modaliteActivite, params, personne)
      tryInsertDevoirForModaliteActivite(modaliteActivite, params, personne)
      redirect(action: "edite", id: modaliteActivite.id, params: [bcInit: true])
    } else {
      def proprietesScolarite = profilScolariteService.findProprietesScolariteWithStructureForPersonne(personne)
      render(view: '/seance/edite', model: [liens: breadcrumpsService.liens,
              modaliteActivite: modaliteActivite,
              proprietesScolarite: proprietesScolarite])
    }
  }

  /**
   *
   * Action "recherche"
   */
  def liste() {
    def maxItems = grailsApplication.config.eliot.listes.max
    params.max = Math.min(params.max ? params.int('max') : maxItems, 100)
    breadcrumpsService.manageBreadcrumps(params, message(code: "seance.liste.titre"))
    Personne personne = authenticatedPersonne
    def modalitesActivites = modaliteActiviteService.findModalitesActivitesForEnseignant(personne,
                                                                                         params)
    boolean affichePager = false
    if (modalitesActivites.totalCount > maxItems) {
      affichePager = true
    }
    render(view: '/seance/liste', model: [liens: breadcrumpsService.liens,
            seances: modalitesActivites,
            affichePager: affichePager])
  }

  /**
   *
   * Action supprime une séance
   */
  def supprime() {
    ModaliteActivite seance = ModaliteActivite.get(params.id)
    Personne personne = authenticatedPersonne
    if (seance.activiteId) {
      flash.messageSuppressionTextesCode = "seance.suppression.activitenonsupprimee"
    }
    if (seance.evaluationId) {
      flash.messageSuppressionNotesCode = "seance.suppression.devoirnonsupprime"
    }
    modaliteActiviteService.supprimeModaliteActivite(seance,
                                                     personne)
    flash.messageSuppressionCode = "seance.suppression.succes"
    redirect(action: "liste", params: [bcInit: true])
  }

  /**
   *
   * Action liste résultats
   */
  def listeResultats() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "seance.resultats.titre"))

    ModaliteActivite seance = ModaliteActivite.get(params.id)
    Personne personne = authenticatedPersonne
    def strongCheck = grailsApplication.config.eliot.interfacage.strongCheck as Boolean
    def afficheLienMiseAjourNote = modaliteActiviteService.modaliteActiviteHasNotesDevoir(seance,
                                                                                          personne,
                                                                                          strongCheck)
    def copies = copieService.findCopiesRemisesForModaliteActivite(seance,
                                                            personne)
    def elevesSansCopies = copieService.findElevesSansCopieForModaliteActivite(seance,
                                                                               copies,
                                                                               personne)
    render(view: '/seance/listeResultats', model: [liens: breadcrumpsService.liens,
            seance: seance,
            afficheLienMiseAjourNote: afficheLienMiseAjourNote,
            copies: copies,
            elevesSansCopies: elevesSansCopies])
  }

  /**
   * Action de mise à jour des notes
   */
  def updateNotesDevoir() {
    ModaliteActivite seance = ModaliteActivite.get(params.id)
    Personne personne = authenticatedPersonne
    def copies = copieService.findCopiesRemisesForModaliteActivite(seance,
                                                            personne)
    def notes = [:]
    copies.each { Copie copie ->
        notes.put(copie.eleveId, copie.correctionNoteFinale)
    }
    Long res =  notesService.updateNotes(seance,personne,codePorteur)
    if (res == null ) {
      flash.messageErreurNotesCode = "seance.updatenotes.echec"
    } else {
      flash.messageCode = "seance.updatenotes.succes"
      flash.messageArgs = [res]
    }
    redirect(action: 'listeResultats',id: seance.id,controller: 'seance')
  }

  /**
   *
   * Action visualise copie
   */
  def visualiseCopie() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "copie.visualisation.titre"))
    ModaliteActivite seance = ModaliteActivite.get(params.id)
    Personne personne = authenticatedPersonne
    List<Copie> copies = copieService.findCopiesRemisesForModaliteActivite(seance,
                                                                    personne,
                                                                    params)
    render(view: '/seance/copie/corrige', model: [liens: breadcrumpsService.liens,
            copies: copies,
            seance: seance])
  }

  /**
   *
   * Action visualise copie
   */
  def enregistreCopie(CopieNotationCommand copieNotation) {
    Personne personne = authenticatedPersonne
    ModaliteActivite seance = ModaliteActivite.get(params.id)
    def allErrors = null
    if (!copieNotation.hasErrors()) {
      Copie copie = Copie.get(copieNotation.copieId)
      copieService.updateAnnotationAndModulationForCopie(copieNotation.copieAnnotation,
                                                         copieNotation.copiePointsModulation,
                                                         copie,
                                                         personne)
      if (!copie.hasErrors()) {
        request.messageCode = "copie.correction.succes"
      } else {
        copie.errors.allErrors.each {
          copieNotation.errors.reject("copie.${it.code}")
        }
      }
    }
    List<Copie> copies = copieService.findCopiesRemisesForModaliteActivite(seance,
                                                                    personne,
                                                                    params)
    render(view: '/seance/copie/corrige', model: [liens: breadcrumpsService.liens,
            copies: copies,
            seance: seance,
            copieNotation: copieNotation

    ])
  }

  /**
   *
   * Action pour mettre à jour la note d'une réponse
   */
  def updateReponseNote(UpdateReponseNoteCommand nvelleNote) {
    Personne enseignant = authenticatedPersonne
    try {
      // deduit l'id de l'objet réponse à modifier
      def reponse = Reponse.get(nvelleNote.element_id)
      // récupère la nouvelle valeur
      def points = nvelleNote.update_value
      // met à jour
      def copie = copieService.updateNoteForReponse(points, reponse, enseignant)
      if (copie.hasErrors()) {
        render new JsonBuilder([nvelleNote.element_id.toString(), params.original_html]).toString()
      } else {
        def noteRep = NumberUtils.formatFloat(points)
        def noteFinale = NumberUtils.formatFloat(copie.correctionNoteFinale)
        render new JsonBuilder([nvelleNote.element_id.toString(), noteRep, noteFinale]).toString()
      }
    } catch (Exception e) {
      log.info(e.message)
      render new JsonBuilder([nvelleNote.element_id.toString(), params.original_html]).toString()
    }
  }

  /**
   * Essayer de creer l'activité dans le cahier de textes
   * @param modaliteActivite la séance
   * @param params les params de la requête
   * @param personne la personne déclenchant l'opération
   */
  private tryInsertActiviteForModaliteActivite(ModaliteActivite modaliteActivite, def params, Personne personne) {
    // lien vers cahier de textes
    Long cahierId = null
    Long chapitreId = null
    ContexteActivite activiteContext = ContexteActivite.CLA
    if (params.cahierId && params.cahierId != 'null') {
      cahierId = params.cahierId as Long
      if (params.chapitreId && params.chapitreId != 'null') {
        chapitreId = params.chapitreId as Long
      }
      if (params.activiteContexteId) {
        activiteContext = ContexteActivite.valueOf(ContexteActivite.class,
                                                  params.activiteContexteId)
      }
      String urlSeance = createLink(controller: "accueil", action: "activite",
                                    id: modaliteActivite.id, absolute: true,
                                    params: [sujetId: modaliteActivite.sujetId])
      // hack pour que l'url soit valide dans tous les cas
      urlSeance = urlSeance.replaceFirst("localhost","127.0.0.1")

      def description = ""
      Long actId = cahierTextesService.createTextesActivite(cahierId,
                                                            chapitreId,
                                                            activiteContext,
                                                            modaliteActivite,
                                                            description,
                                                            urlSeance,
                                                            personne,
                                                            codePorteur)
      if (!actId) {
        flash.messageTextesCode = "seance.enregistre.liencahiertextes.erreur"
      }
    }
  }

  /**
   * Essayer de creer le devoir dans le module notes
   * @param modaliteActivite la séance
   * @param params les params de la requête
   * @param personne la personne déclenchant l'opération
   */
  private tryInsertDevoirForModaliteActivite(ModaliteActivite modaliteActivite, def params, Personne personne) {
    // lien vers notes
    String serviceId = null
    if (params.serviceId && params.serviceId != 'null') {
      serviceId = params.serviceId
      List<ServiceInfo> services = breadcrumpsService.getValeurPropriete('services')
      ServiceInfo service = services.find {it.id == serviceId}
      Long evalId = null
      if (service) {
        evalId = notesService.createDevoir(service, modaliteActivite,
                                           personne, codePorteur)
      }
      if (!evalId) {
        flash.messageNotesCode = "seance.enregistre.liennotes.erreur"
      }
    }
  }
}


class CopieNotationCommand {
  Long copieId
  String copieAnnotation
  Float copiePointsModulation

}

class UpdateReponseNoteCommand {
  Long element_id
  Float update_value
}

