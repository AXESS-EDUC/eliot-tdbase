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

package org.lilie.services.eliot.tdbase

import org.lilie.services.eliot.tice.annuaire.Personne

/**
 * Classe représentant la copie d'un élève
 * @author franck Silvestre
 */
class Copie {

  Date dateEnregistrement
  Date dateRemise
  String correctionAnnotation
  Date correctionDate
  Float correctionNoteAutomatique
  Float correctionNoteFinale
  Float correctionNoteCorrecteur
  Float maxPoints
  Float maxPointsAutomatique
  Float maxPointsCorrecteur
  Float pointsModulation = 0
  String correctionNoteNonNumerique
  Boolean estJetable = false

  Sujet sujet
  Personne eleve

  Personne correcteur
  ModaliteActivite modaliteActivite

  SortedSet<Reponse> reponses
  static hasMany = [reponses: Reponse]

  static constraints = {
    dateEnregistrement(nullable: true)
    dateRemise(nullable: true)
    correctionAnnotation(nullable: true)
    correctionDate(nullable: true)
    correctionNoteAutomatique(nullable: true)
    correctionNoteFinale(nullable: true, validator: { val, obj ->
      if (val && val > obj.maxPoints) {
        return ['notetropgrande']
      }
    })
    correctionNoteCorrecteur(nullable: true)
    correctionNoteNonNumerique(nullable: true)
    maxPoints(nullable: true)
    maxPointsAutomatique(nullable: true)
    maxPointsCorrecteur(nullable: true)
    eleve(nullable: true)
    correcteur(nullable: true)
    modaliteActivite(nullable: true)
  }

  static mapping = {
    table('td.copie')
    version(false)
    id(column: 'id', generator: 'sequence', params: [sequence: 'td.copie_id_seq'])
    cache(true)
    reponses(lazy: false)
    sujet(fetch: 'join')
  }

  static transients = ['estModifiable', 'recalculeNoteFinale']

  /**
   *  Retourne la réponse correspondant à la question donnée
   * @param sujetQuestion la question (objet type SujetSequenceQuestions)
   * @return la réponse
   */
  Reponse getReponseForSujetQuestion(SujetSequenceQuestions sujetQuestion) {
    Reponse.findByCopieAndSujetQuestion(this, sujetQuestion)
  }

  /**
   *
   * @return true si la copie est modifiable, false, sinon
   */
  boolean estModifiable() {
    if (!modaliteActivite) {
      return true
    }
    def now = new Date()
    if (now.after(modaliteActivite.dateFin) || now.before(modaliteActivite.dateDebut)) {
      return false
    }
    def copieAmeliorable = modaliteActivite.copieAmeliorable
    if (dateRemise && !copieAmeliorable) {
      return false
    }
    return true
  }

  /**
   *
   * @return true si la copie peut-être rendu, false, sinon
   */
  boolean estRemisable() {
    if (!modaliteActivite) {
      return true
    }
    def now = new Date()
    if (now.after(modaliteActivite.dateFin) || now.before(modaliteActivite.dateDebut)) {
      if (dateRemise) {
          return false
      }
    }

    def copieAmeliorable = modaliteActivite.copieAmeliorable
    if (dateRemise && !copieAmeliorable) {
      return false
    }
    return true
  }

  /**
   *
   * @return la nouvelle valeur de la note finale
   */
  Float recalculeNoteFinale() {
    def note = 0
    if (correctionNoteAutomatique != null) {
      note += correctionNoteAutomatique
    }
    if (correctionNoteCorrecteur != null) {
      note += correctionNoteCorrecteur
    }
    note + pointsModulation
  }


}
