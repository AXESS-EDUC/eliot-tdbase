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

package org.lilie.services.eliot.tice.utils

class BreadcrumpsService {

  static transactional = false
  static scope = "session"

  List<BreadcrumpsLien> liens = []

  /**
   * Met à jour les liens du breadcrumps quand un nouveau lien est cliqué
   * @param action le nom de l'action
   * @param controller le nom du controller
   * @param libelle le libelle
   * @param params les parametres à conserver
   */
  def onClickSurNouveauLien(String action,
                            String controller,
                            String libelle,
                            Map params) {
    BreadcrumpsLien lien = new BreadcrumpsLien(action: action,
                                               controller: controller,
                                               libelle: libelle)
    if (params == null) {
      params = [:]
    }

    synchronized (liens) {
        if (liens && liens.last() == lien) {
          // si on déclenche la même action (pagination) on ne doit pas
          // ajouter de lien, on se contente de conserver la bonne version
          // des parametres
          def dernierLien = liens.last()
          params.breadcrumpsIndex = dernierLien.index
          dernierLien.params = params
      } else {
        liens.add(lien)
        lien.index = liens.size() - 1
        params.breadcrumpsIndex = lien.index
        lien.params = params
      }

    }
  }

  /**
   * Met à jour les liens du breadcrumps en cas de clique sur un des liens
   * du breadcump
   * @param indexLien l'indice du lien cliqué dans le breadcrumps
   */
  def onClikSurLienBreadcrumps(int indexLien) {
    synchronized (liens) {
      int depart = liens.size() - 1
      for (int i = depart; i > indexLien; i--) {
        liens.remove(i)
      }
    }
  }

  /**
   * reinitialise le breadcrumps
   * @return
   */
  def initialiseBreadcrumps() {
    liens = []
  }

}
