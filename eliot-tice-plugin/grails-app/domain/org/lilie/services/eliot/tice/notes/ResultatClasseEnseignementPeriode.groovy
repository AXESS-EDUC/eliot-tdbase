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

import org.lilie.services.eliot.tice.scolarite.StructureEnseignement
import org.lilie.services.eliot.tice.scolarite.Enseignement
import org.lilie.services.eliot.tice.scolarite.Periode

/**
 * Représente les résultats d'une classe pour un Enseignement et une Période
 *
 * Résultat est supprimé en cascade quand la période proprietaire est supprimé.
 *
 * @author bper
 */
class ResultatClasseEnseignementPeriode {

  Long id
  StructureEnseignement classe
  Enseignement enseignement
  Periode periode //Résultat est supprimé en cascade quand la période proprietaire est supprimé.

  BigDecimal moyenne  // moyenne des moyennes générales des élèves de la classe
  BigDecimal moyenneMax  // meilleure moyenne générale de la classe
  BigDecimal moyenneMin  // pire moyenne générale de la classe

  static constraints = {
    classe nullable: false, validator: {val,obj -> val.isClasse()}
    enseignement nullable: false
    periode nullable: false
    moyenne nullable: true
    moyenneMax nullable: true
    moyenneMin nullable: true
  }

  static belongsTo = [
          classe: StructureEnseignement,
          enseignement: Enseignement,
          periode: Periode
  ]

  static mapping = {
    table('entnotes.resultat_classe_enseignement_periode')
    id column: 'id',
            generator: 'sequence',
            params: [sequence: 'entnotes.resultat_classe_enseignement_periode_id_seq']
    classe column: 'structure_enseignement_id'
    periode column: 'periode_id'
    moyenne column: 'moyenne'
    moyenneMax column: 'moyenne_max'
    moyenneMin column: 'moyenne_min'
    version true
  }

  boolean equals(Object o) {
    if (o instanceof ResultatClasseEnseignementPeriode) {
      ResultatClasseEnseignementPeriode res = (ResultatClasseEnseignementPeriode) o
      return (this.classe.id == res.classe.id &&
              this.periode.id == res.periode.id &&
              this.enseignement.service.id == res.enseignement.service.id &&
              this.enseignement.enseignant.id == res.enseignement.enseignant.id
      )
    } else {
      return false
    }
  }

}
