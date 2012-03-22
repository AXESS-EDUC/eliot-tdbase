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

/**
 * Classe représentant la composition d'un sujet
 * @author franck Silvestre
 */
class SujetSequenceQuestions implements Comparable {

  Integer rang
  Float noteSeuilPoursuite
  Float points = 1

  Question question
  Sujet sujet


  static constraints = {
    noteSeuilPoursuite(nullable: true)
    question(validator: {val, obj ->
      if (val.type.interaction) {
        def nb = SujetSequenceQuestions.countBySujetAndQuestion(obj.sujet, val)
        if (nb > 1) {
          return ['invalid.doublonsquestioninteraction']
        } else if (nb == 1) {
          def sujQu = SujetSequenceQuestions.findBySujetAndQuestion(obj.sujet, val)
          if (obj != sujQu) {
            return ['invalid.doublonsquestioninteraction']
          }
        }
      }
    })
  }

  /**
   * Permet l'ordonnancement des questions par le rang de la
   * question dans le sujet
   * @param obj l'objet de comparaison
   * @return
   */
  int compareTo(obj) {
    rang.compareTo(obj.rang)
  }

  static mapping = {
    table('td.sujet_sequence_questions')
    version(false)
    id(column: 'id', generator: 'sequence', params: [sequence: 'td.sujet_sequence_questions_id_seq'])
    cache(true)
    question(fetch: 'join')
    rang(column: 'questions_sequences_idx', insertable: false, updateable: false)
  }


}
