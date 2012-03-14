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

import org.lilie.services.eliot.tice.scolarite.Periode
import org.lilie.services.eliot.tice.securite.DomainAutorite
import org.lilie.services.eliot.tice.scolarite.Enseignement

/**
 * Représente les résultats d'un élève pour un Enseignement et une Période
 *
 * Résultat est supprimé en cascade quand la période proprietaire est supprimé.
 *
 * @author msan
 */
class ResultatEleveEnseignementPeriode {

  Long id
  Enseignement enseignement
  Periode periode // Résultat est supprimé en cascade quand la période proprietaire est supprimé.
  DomainAutorite eleve
  BigDecimal moyenne

  static constraints = {
    enseignement(nullable: false)
    periode(nullable: false)
    eleve(nullable: false)
    moyenne(nullable: true)
  }

  static belongsTo = [
          enseignement: Enseignement,
          periode: Periode,
          eleve: DomainAutorite
  ]

  static mapping = {
    table('entnotes.resultat_eleve_enseignement_periode')
    id column: 'id',
       generator: 'sequence',
       params: [sequence: 'entnotes.resultat_eleve_enseignement_periode_id_seq']
    periode column: 'periode_id'
    eleve column: 'eleve_id'
    moyenne column: 'moyenne'
    version true
  }

  boolean equals(Object o) {
    if (o instanceof ResultatEleveEnseignementPeriode) {
      ResultatEleveEnseignementPeriode res = (ResultatEleveEnseignementPeriode) o
      return (this.eleve.id == res.eleve.id &&
              this.periode.id == res.periode.id &&
              this.enseignement.service.id == res.enseignement.service.id &&
              this.enseignement.enseignant.id == res.enseignement.enseignant.id
      )
    } else {
      return false
    }
  }

  String toString() {
    return "$id ${eleve?.id} $enseignement $periode $moyenne"
  }

}
