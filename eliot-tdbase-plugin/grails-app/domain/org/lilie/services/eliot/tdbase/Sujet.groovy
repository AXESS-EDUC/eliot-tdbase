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

import org.lilie.services.eliot.tice.CopyrightsType
import org.lilie.services.eliot.tice.Publication
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau

/**
 * Classe représentant un sujet
 * @author franck Silvestre
 */
class Sujet implements Artefact {

  String titre
  String titreNormalise
  int versionSujet = 1

  Date dateCreated
  Date lastUpdated

  String presentation
  String presentationNormalise

  String annotationPrivee
  Integer nbQuestions
  Integer dureeMinutes
  Float noteMax
  Float noteAutoMax
  Float noteEnseignantMax
  Boolean publie = false
  Boolean accesPublic = false
  Boolean accesSequentiel = false
  Boolean ordreQuestionsAleatoire = false

  String paternite


  Personne proprietaire

  SujetType sujetType
  Etablissement etablissement
  Matiere matiere
  Niveau niveau
  Publication publication
  CopyrightsType copyrightsType

  List<SujetSequenceQuestions> questionsSequences
  static hasMany = [questionsSequences: SujetSequenceQuestions]

  Integer rangInsertion

  static transients = ['rangInsertion',
          'estUnExercice',
          'questionComposite',
          'estInvariant']

  static constraints = {
    titre(blank: false, nullable: false)
    sujetType(nullable: true, validator: { val, obj ->
      if (val == SujetTypeEnum.Exercice.sujetType && obj.possedeUneQuestionComposite()) {
        return ['invalid.exerciceavecquestioncomposite']
      }
    })
    etablissement(nullable: true)
    matiere(nullable: true)
    niveau(nullable: true)
    publication(nullable: true)
    presentation(nullable: true)
    presentationNormalise(nullable: true)
    titreNormalise(nullable: true)
    annotationPrivee(nullable: true)
    nbQuestions(nullable: true)
    dureeMinutes(nullable: true)
    noteMax(nullable: true)
    noteAutoMax(nullable: true)
    noteEnseignantMax(nullable: true)
    paternite(nullable: true)
  }

  static mapping = {
    table('td.sujet')
    version(false)
    id(column: 'id', generator: 'sequence', params: [sequence: 'td.sujet_id_seq'])
    questionsSequences(cascade: 'refresh')
    sujetType(fetch: 'join')
    cache(true)
  }

  /**
   *
   * @return true si le sujet est un exercice
   */
  boolean estUnExercice() {
    sujetTypeId == SujetTypeEnum.Exercice.id
  }

  /**
   * Retourne la question composite associée au sujet
   * @return la question composite
   */
  Question getQuestionComposite() {
    Question.findByExercice(this)
  }

  /**
   *
   * @return la liste des questions du sujet
   */
  List<Question> getQuestions() {
    questionsSequences*.question
  }

  /**
   *
   * @return true si le sujet possede une question composite
   */
  boolean possedeUneQuestionComposite() {
    return questions?.count { it.estComposite() } > 0
  }

  /**
   *
   * @return la note maximale calculée
   */
  Float calculNoteMax() {
    def res = 0
    questionsSequences.each {SujetSequenceQuestions sujetQuest ->
      if (sujetQuest.question.estComposite()) {
        res += sujetQuest.question.exercice.calculNoteMax()
      } else {
        if (sujetQuest.points) {
          res += sujetQuest.points
        }
      }

    }
    res
  }

  @Override
  boolean estDistribue() {
    if (estUnExercice()) {
      return questionComposite.estDistribue()
    }
    // verifie en premier si des copies sont attachées
    def critCopie = Copie.createCriteria()
    def nbCopies = critCopie.count {
      eq 'estJetable', false
      eq 'sujet', this
    }
    if (nbCopies > 0) {
      return true
    }
    // sinon verifie qu'une séance ouverte n'est pas attaché
    def crit = ModaliteActivite.createCriteria()
    def now = new Date()
    def nbSeances = crit.count {
      le 'dateDebut', now
      ge 'dateFin', now
      eq 'sujet', this
    }
    return nbSeances > 0
  }

  @Override
  boolean estPartage() {
    publicationId != null
  }

  @Override
  boolean estInvariant() {
    false
  }

  @Override
  boolean estPresentableEnMoodleXML() {
    true
  }

  /**
   * Vrai si l'artefact peut-être supprimeé l'artefact.
   * Cette méthode est appeler après avoir vérifier que l'artefact est modifiable
   * @return true si artefact  peut être supprimé
   */
  boolean estSupprimableQuandArtefactEstModifiable() {
    def crit = ModaliteActivite.createCriteria()
    def nbSeances = crit.count {
      eq 'sujet', this
    }
    return nbSeances == 0
  }


}
