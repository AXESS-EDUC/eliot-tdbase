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

/**
 * Classe fournissant le service de gestion de breadcrumps
 * @author franck silvestre
 */
class BreadcrumpsService {


  static transactional = false
  static scope = "session"

  Breadcrumps breadcrumps = new Breadcrumps()

  List<BreadcrumpsLien> getLiens() {
    return breadcrumps.liens
  }

  /**
   * Gère le breacrumps à partir du contenu de la requête
   * @param params les parametres de la requête
   * @param libelle le libelle du lien à mettre dans le breadcrump si nécessaire
   */
  def manageBreadcrumps(Map params, String libelle, Map proprietes = null) {
    if (params."${Breadcrumps.PARAM_BREADCRUMPS_INIT}") {
      breadcrumps.initialise()
      params.remove(Breadcrumps.PARAM_BREADCRUMPS_INIT)
    }
    if (params."${Breadcrumps.PARAM_BREADCRUMPS_INDEX}") {
      onClikSurLienBreadcrumps(params."${Breadcrumps.PARAM_BREADCRUMPS_INDEX}" as Integer)
    } else {
      onClickSurNouveauLien(params.action,
                            params.controller,
                            libelle,
                            params,
                            proprietes
      )
    }
  }

  /**
   * Renvoie le lien correspondant à un backtrack applicatif : à utiliser typiquement
   * pour mettre en place un lien annuler
   * @return le lien
   */
  BreadcrumpsLien lienRetour() {
    return breadcrumps.lienRetour()
  }

  /**
   * Retourne la valeur d'une propriete
   * @param nom le nom de la propriete
   * @return la valeur ou null si la propriete n'est pas definie
   */
  def getValeurPropriete(String nom) {
    return breadcrumps.getValeurPropriete(nom)
  }

  /**
   * Modifie la valeur d'une propriete
   * @param nom  le nom de la propriete
   * @param valeur  la valeur de la propriete
   */
  def setValeurPropriete(String nom, def valeur) {
    breadcrumps.setValeurPropriete(nom, valeur)
  }

  /**
   * Met à jour les liens du breadcrumps quand un nouveau lien est cliqué
   * @param action le nom de l'action
   * @param controller le nom du controller
   * @param libelle le libelle
   * @param params les parametres à conserver
   * @return le breadcrumps lien cliqué
   */
  private BreadcrumpsLien onClickSurNouveauLien(String action,
                                                String controller,
                                                String libelle,
                                                Map params,
                                                Map proprietes = null) {

    BreadcrumpsLien lien = new BreadcrumpsLien(action: action,
                                               controller: controller,
                                               libelle: libelle)

    return breadcrumps.addLien(lien, params, proprietes)

  }

  /**
   * Met à jour les liens du breadcrumps en cas de clique sur un des liens
   * du breadcump
   * @param indexLien l'indice du lien cliqué dans le breadcrumps
   */
  private BreadcrumpsLien onClikSurLienBreadcrumps(int indexLien) {
    return breadcrumps.depileLiens(indexLien)
  }

}
