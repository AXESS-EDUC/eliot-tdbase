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

/**
 * Relation service - modalité matière (sous-matière) - type période
 * @author msan
 */
class SousService {

  Long id
  BigDecimal coeff
  ModaliteMatiere modaliteMatiere
  Service service


  Integer ordre
  Boolean evaluable = Boolean.FALSE

  static belongsTo = [
          service: Service,
          modaliteMatiere: ModaliteMatiere
  ]

  static constraints = {
    coeff(nullable: false)
    modaliteMatiere(nullable: false)
    service(nullable: false)
    ordre(nullable: true)
    evaluable(nullable: false)
  }

  static mapping = {
    table('ent.sous_service')
    id column: 'id',
       generator: 'sequence',
       params: [sequence: 'ent.sous_service_id_seq']

    coeff column: 'coeff'
    modaliteMatiere column: 'modalite_matiere_id'
    service column: 'service_id'
    ordre column: 'ordre'
    evaluable column: 'evaluable'
  }

  public String toString() {
    return "id: $id Service: $service  ModaliteMatiere: $modaliteMatiere"
  }
}
