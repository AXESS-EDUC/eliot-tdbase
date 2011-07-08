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

import org.lilie.services.eliot.tice.securite.DomainAutorite
import org.lilie.services.eliot.tice.scolarite.Periode

/**
 * Appreciations d'un élève pour une période.
 * Saisies dans les Synthèses / Conseil de classe
 *
 * @author msan
 */
class AppreciationElevePeriode {

  Long id
  DomainAutorite eleve
  Periode periode

  AvisConseilDeClasse avisConseilDeClasse
  AvisOrientation avisOrientation

  String appreciation // appreciation donnée lors de conseil de classe

  static belongsTo = [
      eleve: DomainAutorite,
      periode: Periode
  ]

  static constraints = {
    eleve nullable:false
    periode nullable: false
    appreciation(nullable:true, maxSize: 1024)
    avisConseilDeClasse nullable: true
    avisOrientation nullable: true
  }

  static mapping = {
    table('entnotes.appreciation_eleve_periode')
    id column: 'id',
            generator: 'sequence',
            params: [sequence: 'entnotes.appreciation_eleve_periode_id_seq']
    version true
    eleve column: 'eleve_id'
    periode column: 'periode_id'
    appreciation column: 'appreciation'
    avisConseilDeClasse column: 'avis_conseil_de_classe_id'
    avisOrientation column: 'avis_orientation_id'
  }

  String toString() {
    return "$id ${eleve?.id} $periode $appreciation $avisConseilDeClasse $avisOrientation"
  }
}
