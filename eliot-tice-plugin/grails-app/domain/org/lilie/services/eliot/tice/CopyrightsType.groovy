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

package org.lilie.services.eliot.tice

/**
 * Classe représentant un type de copyright
 * @author franck Silvestre
 */
class CopyrightsType {

  private static DEFAULT_COPYRIGHTS_TYPE_ID = 1

  String code
  String presentation
  String lien
  String logo
  Boolean optionCcPaternite
  Boolean optionCcPasUtilisationCommerciale
  Boolean optionCcPasModification
  Boolean optionCcPartageViral
  Boolean optionTousDroitsReserves

  static constraints = {
    presentation(nullable: true)
    lien(nullable: true)
    logo(nullable: true)
    optionCcPaternite(nullable: true)
    optionCcPasUtilisationCommerciale(nullable: true)
    optionCcPasModification(nullable: true)
    optionCcPartageViral(nullable: true)
    optionTousDroitsReserves(nullable: true)
  }

  static mapping = {
    table('tice.copyrights_type')
    version(false)
    id(column: 'id', generator: 'sequence', params: [sequence: 'tice.copyrights_type_id_seq'])
    cache('read-only')
  }

  /**
   * Retourne le type de copyright par défaut : "tous droits réservés"
   * @return le type de copyright par défaut
   */
  static CopyrightsType getDefault() {
    return get(DEFAULT_COPYRIGHTS_TYPE_ID)
  }
}

/**
 * Enumération des types de copyright
 * <ul>
 *  <li>TousDroitsReserves - Tous droits réservés </li>
 *  <li>CC_BY_NC_SA - Creative Commons, partage viral non commercial</li>
 *  <li>CC_BY_NC - Creative Commons, partage non viral non commercial</li>
 * </ul>
 */
enum CopyrightsTypeEnum {
  TousDroitsReserves(1),
  CC_BY_NC_SA(2),
  CC_BY_NC(3)

  private Long id;

  private CopyrightsTypeEnum(Long id) {
    this.id = id
  }

  CopyrightsType getCopyrightsType() {
    CopyrightsType.get(id)
  }

}