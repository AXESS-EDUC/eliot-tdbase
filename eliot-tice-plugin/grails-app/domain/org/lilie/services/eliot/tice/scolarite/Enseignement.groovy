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

import org.lilie.services.eliot.tice.securite.DomainAutorite
import groovy.transform.EqualsAndHashCode


@EqualsAndHashCode
class Enseignement implements Serializable {

  DomainAutorite enseignant
  Service service
  Double nbHeures
  String origine = "AUTO"

  /**
   * Numéro de version de l'import STS qui a engendré la création ou la
   * modification de cet enseignement
   * -1 si cet enseignement n'a pas été créée durant un import STS
   */
  int versionImportSts = -1

  /**
   * Indique si cet enseignement existe dans les données du
   * dernier import STS
   * Lorsqu'un enseignement existe en base, mais pas dans les données
   * d'un import STS, la propriété actif passe à false
   */
  boolean actif = true

  static belongsTo = [enseignant: DomainAutorite, service: Service]

  static constraints = {
    nbHeures(nullable: true)
    enseignant(nullable: false)
    service(nullable: false)
  }
//  static hasMany = [
//          evenements: Evenement
//  ]

  static mapping = {
    table 'ent.enseignement'
    enseignant fetch: 'join'
    service  fetch: 'join'
    id column: 'id',
           generator: 'sequence',
           params: [sequence: 'ent.enseignement_id_seq']
  }

  def String toString() {
    return "Enseignant : ${enseignant?.id}, Service : ${service?.id}";
  }


}
