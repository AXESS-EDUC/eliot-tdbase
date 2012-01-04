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

class ResultatsController {

  static defaultAction = "listeEleves"

  BreadcrumpsService breadcrumpsService
  ModaliteActiviteService modaliteActiviteService
  ProfilScolariteService profilScolariteService
  CopieService copieService
  ReponseService reponseService

  /**
   * Action liste résulats
   *
   */
  def liste() {
    params.max = Math.min(params.max ? params.int('max') : 10, 100)
    breadcrumpsService.manageBreadcrumps(params, message(code: "resultats.titre"))
    Personne parent = authenticatedPersonne
    List<Personne> eleves = profilScolariteService.findElevesForResponsable(parent)
    Personne eleveSelectionne = Personne.get(params.eleveId as Long)
    if (!eleveSelectionne) {
      eleveSelectionne = eleves[0]
    }
    def copies = copieService.findCopiesEnVisualisationForResponsableAndApprenant(
            parent,
            eleveSelectionne,
            params
    )
    [
            liens: breadcrumpsService.liens,
            copies: copies,
            eleves: eleves,
            eleveSelectionne: eleveSelectionne
    ]
  }

  /**
   *
   * Action visualise copie
   */
  def visualiseCopie() {
    breadcrumpsService.manageBreadcrumps(params, message(code: "copie.visualisation.titre"))
    Copie copie = Copie.get(params.id)
    render(view: '/resultats/copie/visualise', model: [
            liens: breadcrumpsService.liens,
            copie: copie
    ])
  }


}






