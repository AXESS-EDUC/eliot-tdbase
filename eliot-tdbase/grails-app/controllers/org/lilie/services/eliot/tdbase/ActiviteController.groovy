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
import org.lilie.services.eliot.tice.scolarite.ProprietesScolarite
import org.lilie.services.eliot.tice.utils.BreadcrumpsService

class ActiviteController {

  static defaultAction = "listeSeances"

  BreadcrumpsService breadcrumpsService
  ModaliteActiviteService modaliteActiviteService
  ProfilScolariteService profilScolariteService



  /**
   *
   * Action "liste des séances"
   */
  def listeSeances() {
    params.max = Math.min(params.max ? params.int('max') : 10, 100)
    breadcrumpsService.manageBreadcrumps(params, message(code: "seance.liste.titre"))
    Personne personne = authenticatedPersonne
    def modalitesActivites = modaliteActiviteService.findModalitesActivitesForApprenant(
            personne,
            params
    )
    render(view: '/activite/seance/liste', model: [
           liens: breadcrumpsService.liens,
           seances: modalitesActivites
           ])
  }

  /**
   *
   * Action "Faire sujet"
   */
  def faireSujet() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "copie.edition.titre"))
    ModaliteActivite seance = ModaliteActivite.get(params.id)
    Sujet sujet = seance.sujet
    render(view: '/activite/copie/edite', model: [
           liens: breadcrumpsService.liens,
           sujet: sujet
           ])
  }

  /**
   *
   * Action enregistre réponse
   */
  def enregistreReponse() {
    render("Non implémenté")
  }

}


