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
import org.lilie.services.eliot.tice.securite.DomainAutorite
import org.lilie.services.eliot.tice.scolarite.Periode
import org.lilie.services.eliot.tice.scolarite.Service

/**
 * Représente les résultats d'une classe pour un Service et une Période
 *
 * Résultat est supprimé en cascade quand la période proprietaire est supprimé.
 *
 * @author bper
 */
class ResultatClasseServicePeriode implements Serializable {

  Long id
  StructureEnseignement classe
  Service service
  Periode periode // Résultat est supprimé en cascade quand la période proprietaire est supprimé.

  DomainAutorite enseignant // enseignant qui a donné l'appreciation
  BigDecimal moyenne  // moyenne des moyennes des élèves de la classe
  BigDecimal moyenneMax  // meilleure moyenne de la classe pour ce service
  BigDecimal moyenneMin  // pire moyenne de la classe pour ce service 

  Set<ResultatClasseSousServicePeriode> resultatsClasseSousServicePeriode

  static hasMany = [
          resultatsClasseSousServicePeriode: ResultatClasseSousServicePeriode
  ]

  static belongsTo = [
          classe: StructureEnseignement,
          service: Service,
          periode: Periode
  ]

  static constraints = {
    classe nullable: false, validator: {val, obj -> val.isClasse()}
    service nullable: false
    periode nullable: false
    enseignant nullable: true
    moyenne nullable: true
    moyenneMax nullable: true
    moyenneMin nullable: true
  }

  static mapping = {
    table('entnotes.resultat_classe_service_periode')
    id column: 'id',
       generator: 'sequence',
       params: [sequence: 'entnotes.resultat_classe_service_periode_id_seq']
    version true
    classe column: 'id_structure_enseignement'
    service column: 'id_service'
    periode column: 'id_periode'
    enseignant column: 'id_autorite_enseignant'
    moyenne: 'moyenne'
    moyenneMax: 'moyenne_max'
    moyenneMin: 'moyenne_min'
  }

  boolean equals(Object o) {
    if (o instanceof ResultatClasseServicePeriode) {
      ResultatClasseServicePeriode res = (ResultatClasseServicePeriode) o
      return (this.classe.id == res.classe.id &&
              this.periode.id == res.periode.id &&
              this.service.id == res.service.id)
    } else {
      return false
    }
  }

  String toString() {
    return "$id ${classe} $service $periode $moyenne"
  }

}
