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

package org.lilie.services.eliot.tice.notes

import org.lilie.services.eliot.tice.scolarite.SousService

/**
 * Représente les résultats d'un élève pour un SousService et une Période
 *
 * Résultat est supprimé en cascade quand le Résultat parent est supprimé
 *
 * @author msan
 */
class ResultatEleveSousServicePeriode implements Serializable {

  Long id

  ResultatEleveServicePeriode resultatEleveServicePeriode // résultat parent
  SousService sousService

  BigDecimal moyenne

  static belongsTo = [
          resultatEleveServicePeriode: ResultatEleveServicePeriode,
          sousService: SousService
  ]

  static constraints = {
    resultatEleveServicePeriode nullable:false
    sousService nullable:false
    moyenne nullable: true
  }

  static mapping = {
    table('entnotes.resultat_eleve_sous_service_periode')
    id column: 'id',
            generator: 'sequence',
            params: [sequence: 'entnotes.resultat_eleve_sous_service_periode_id_seq']
    version true
    sousService column:'sous_service_id'
    resultatEleveServicePeriode column:'resultat_eleve_service_periode_id'
    moyenne column: 'moyenne'
  }

  String toString() {
    return "$id $resultatEleveServicePeriode $sousService $moyenne"
  }
}