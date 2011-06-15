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

package org.lilie.services.eliot.tice.scolarite

import org.lilie.services.eliot.tice.securite.Perimetre
import org.lilie.services.eliot.tice.annuaire.PorteurEnt

/**
 * Représente un établissement
 * @author msan
 * @author jtra
 */
class Etablissement {

  Long id
  String nomAffichage
  String idExterne
  String uai
  String codePorteurENT

  Perimetre perimetre
  PorteurEnt porteurEnt

  /**
   * Numéro de version du dernier import STS pour cet établissement
   * 0 lorsqu'aucun import n'a été effectué pour cet établissement
   */
  int versionImportSts = 0

  /**
   * Date du dernier import Sts effectué pour cet établissement
   */
  Date dateImportSts = null

  static mapping = {
    table 'ent.etablissement'
    id column: 'id', generator: 'sequence', params: [sequence: 'ent.etablissement_id_seq']
    codePorteurENT column: 'code_porteur_ent'
    cache usage: 'read-write'
  }

  static constraints = {
    idExterne(nullable: false, maxSize: 128, unique: true)
    uai(nullable: true)
    nomAffichage(maxSize: 1024)
    dateImportSts(nullable: true)

    perimetre(nullable: true)
    porteurEnt(nullable: true)

  }

}
