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

import groovy.transform.EqualsAndHashCode

/**
 * Classe représentant un lien de breadcrumps
 * @author franck Silvestre
 */
@EqualsAndHashCode(excludes = "params, index, libelle")
class BreadcrumpsLien {
  String action
  String controller
  String libelle
  Map params
  int index
  Map proprietes
  String url = null
}

class Breadcrumps {

  static final String PARAM_BREADCRUMPS_INIT = "bcInit"
  static final String PARAM_BREADCRUMPS_INDEX = "bcIdx"

  List<BreadcrumpsLien> liens = []
  Map proprietes = [:]

  /**
   * Initialise le breadcrump
   */
  synchronized def initialise() {
    liens = []
    proprietes = [:]
  }

  /**
   * Ajoute un lien au breadcrumps
   * @param lien le lien
   * @param params les paramètres de la requête
   * @param proprietes les proprietes à ajouter
   * @return le lien ajouté
   */
  synchronized BreadcrumpsLien addLien(BreadcrumpsLien lien,
                                       Map params,
                                       Map newproprietes = null) {
    if (params == null) {
      params = [:]
    }
    def lienRes
    if (liens && liens.last() == lien) {
      // si on déclenche la même action (pagination) on ne doit pas
      // ajouter de lien, on se contente de conserver la bonne version
      // des parametres
      lienRes = liens.last()
    } else {
      liens.add(lien)
      lien.index = liens.size() - 1
      lienRes = lien
    }
    params."$PARAM_BREADCRUMPS_INDEX" = lienRes.index
    lienRes.params = params
    if (newproprietes) {
      if (lienRes.proprietes == null) {
        lienRes.proprietes = [:]
      }
      lienRes.proprietes << newproprietes
      proprietes << newproprietes
    }
    return lienRes
  }

  /**
   * Renvoie le lien correspondant à un backtrack applicatif : à utiliser typiquement
   * pour mettre en place un lien annuler
   * @return le lien
   */
  synchronized BreadcrumpsLien lienRetour() {
    def lien = null
    if (liens.size() > 1) {
      lien = liens.get(liens.size() - 2)
    } else if (liens.size() > 0) {
      lien = liens.get(liens.size() - 1)
    }
    return lien
  }

  /**
   * Depile le breadcrump jusqu'au lien d'indice passé en paramètre
   * @param indexLien l'indice du lien limite
   * @return le dernier lien du breadcrump après dépilement
   */
  synchronized BreadcrumpsLien depileLiens(int indexLien) {
    int depart = liens.size() - 1
    for (int i = depart; i > indexLien; i--) {
      liens.remove(i)
    }
    // reconstitution des proprietes
    proprietes = [:]
    liens.each {
      if (it.proprietes) {
        proprietes << it.proprietes
      }
    }
    return liens.get(indexLien)
  }

  /**
   * Retourne la valeur d'une propriete
   * @param nom le nom de la propriete
   * @return la valeur ou null si la propriete n'est pas definie
   */
  synchronized def getValeurPropriete(String nom) {
    return proprietes."$nom"
  }

  /**
   * Modifie la valeur d'une propriete
   * @param nom le nom de la propriete
   * @param valeur de la propriete
   */
  synchronized def setValeurPropriete(String nom, def valeur) {
    proprietes."$nom" = valeur
  }

}
