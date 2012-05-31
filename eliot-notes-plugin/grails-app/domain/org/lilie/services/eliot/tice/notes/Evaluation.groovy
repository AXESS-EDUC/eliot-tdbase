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

import org.lilie.services.eliot.tice.scolarite.Enseignement
import org.lilie.services.eliot.tice.scolarite.ModaliteMatiere
import org.lilie.services.eliot.tice.scolarite.Periode

/**
 * Evaluation est un exercice noté ( devoir, interrogation, etc.. )
 * piloté par un enseignant et debouchant sur un evaluation des eleves de
 * l'enseignement
 *
 * @author bcro
 * @author msan
 */

class Evaluation {

  Long id
  // le couple service-enseignant
  Enseignement enseignement
  // @TODO referencer Activite quand migrée sur le plugin
  //Activite activite
  String titre
  Date dateEvaluation
  String description
  BigDecimal coefficient
  BigDecimal noteMaxPossible
  Boolean publiable
  Date dateCreation = new Date()
  Integer ordre = 0 // l'ordre d'evaluation pour la periode et l'enseignement donnée
  BigDecimal moyenne // moyenne d'évaluation pour tous les élèves évalués par cet évaluation
  Set<Periode> periodes
  Set<Note> notes
  ModaliteMatiere modaliteMatiere

  static transients = ['verrouille', 'noteMaxSaisie']

  static constraints = {
    description(nullable: true)
    dateCreation(nullable: false)
    ordre(nullable: false)
    moyenne(nullable: true)
    periodes nullable: false, validator: {val, obj -> val.size() > 0}
    modaliteMatiere(nullable: true)
  }

  static hasMany = [notes: Note, periodes: Periode]

  static mapping = {
    table('entnotes.evaluation')
    id column: 'id',
       generator: 'sequence',
       params: [sequence: 'entnotes.evaluation_id_seq']

    // l'enregistrement dans le tableau de jointure est enlevé par
    // cascade quand l'évaluation est supprimée
    periodes joinTable: [
            name: 'entnotes.rel_evaluation_periode',
            key: 'evaluation_id',
            column: 'periode_id'
    ]
    publiable column: 'est_publiable'

  }

  /**
   * Retourne true si au moins une période de cette évaluation est verrouillée
   * @return Boolean
   * @author bper
   */
  Boolean getVerrouille() {
    return this.periodes.any {Periode periode -> periode.verrouille}
  }

  /**
   * Retourne la valeur numérique maximale des notes saisiees pour cette évaluation
   * @return note max
   * @author bper
   */
  BigDecimal getNoteMaxSaisie() {
    return this.notes*.valeurNumerique?.max()
  }
}
