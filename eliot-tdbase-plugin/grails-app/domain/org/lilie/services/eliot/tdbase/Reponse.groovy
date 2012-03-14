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
 * Classe représentant une réponse à une question
 * @author franck Silvestre
 */
class Reponse implements Comparable {

  ReponseService reponseService

  String specification

  String correctionAnnotation
  Date correctionDate
  Float correctionNoteAutomatique
  Float correctionNoteFinale
  Float correctionNoteCorrecteur
  String correctionNoteNonNumerique

  Copie copie
  // necessaire pour recuperer le bareme, le seuil de passage à
  // la question suivante et l'ordre dans le cas d'un ordre impose
  // par le sujet
  SujetSequenceQuestions sujetQuestion
  // le rang est null si l'ordre des questions dans la copie est imposée dans
  // le sujet
  Integer rang

  /**
   *
   * @return le rang de la réponse i.e. le rang de la question dans la copie
   */
  Integer getRang() {
    if (rang == null) {
      return sujetQuestion.rang
    } else {
      return rang
    }
  }

  Personne correcteur
  Personne eleve    // utile uniquement pour stats et securite
  SortedSet<ReponseAttachement> reponseAttachements

  static hasMany = [
          reponseAttachements: ReponseAttachement
  ]

  static constraints = {
    specification(nullable: true)
    correctionAnnotation(nullable: true)
    correctionDate(nullable: true)
    correctionNoteAutomatique(nullable: true)
    correctionNoteFinale(nullable: true)
    correctionNoteCorrecteur(nullable: true)
    correctionNoteNonNumerique(nullable: true)
    correcteur(nullable: true)
    eleve(nullable: true)
    rang(nullable: true)
  }

  static mapping = {
    table('td.reponse')
    version(false)
    id(column: 'id', generator: 'sequence', params: [sequence: 'td.reponse_id_seq'])
    cache(true)
    sujetQuestion(fetch: 'join')
  }

  static transients = ['reponseService', 'estEnNotationManuelle', 'question', 'questionType']

  /**
   * Permet l'ordonnancement des réponse par le rang de la
   * réponse dans la copie
   * @param obj l'objet de comparaison
   * @return
   */
  int compareTo(obj) {
    getRang().compareTo(obj.rang)
  }

  /**
   *
   * @return la question associée à la réponse
   */
  Question getQuestion() {
    return sujetQuestion.question
  }

  /**
   *
   * @return le type de question associé à la réponse
   */
  QuestionType getQuestionType() {
    return sujetQuestion.question.type
  }

  /**
   *
   * @return true si la question induit une  notation  manuelle
   */
  boolean estEnNotationManuelle() {
    return sujetQuestion.question.estEnNotationManuelle()
  }

  /**
   *
   * @return l'objet encapsulant la spécification
   */
  def getSpecificationObject() {
    def qtype = sujetQuestion.question.type
    def specService = reponseService.reponseSpecificationServiceForQuestionType(qtype)
    specService.getObjectFromSpecification(specification)
  }


}
