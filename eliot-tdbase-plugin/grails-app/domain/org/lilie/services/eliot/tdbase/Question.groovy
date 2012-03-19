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

import org.lilie.services.eliot.tice.Attachement
import org.lilie.services.eliot.tice.CopyrightsType
import org.lilie.services.eliot.tice.Publication
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau
import org.springframework.web.multipart.MultipartFile

/**
 * Classe représentant une question
 * @author franck Silvestre
 */
class Question implements Artefact {

  QuestionService questionService

  String titre
  String titreNormalise

  Date dateCreated
  Date lastUpdated

  int versionQuestion
  String specification
  String specificationNormalise
  Boolean estAutonome = true
  Boolean publie

  String paternite

  Personne proprietaire
  QuestionType type
  Sujet exercice

  Etablissement etablissement
  Matiere matiere
  Niveau niveau
  CopyrightsType copyrightsType
  Publication publication
  SortedSet<QuestionAttachement> questionAttachements




  private def specificationObject

  static hasMany = [
          questionAttachements: QuestionAttachement
  ]


  static constraints = {
    specificationNormalise(nullable: true)
    etablissement(nullable: true)
    matiere(nullable: true)
    niveau(nullable: true)
    publication(nullable: true)
    paternite(nullable: true)
    exercice(nullable: true)
    specification(validator: { val, obj, errors ->
      def objSpec = obj.getSpecificationObjectForJson(val)
      if (!objSpec.validate()) {
        objSpec.errors.allErrors.each {
          errors.reject(it.code, it.arguments, it.defaultMessage)
        }
      }
    })
  }

  static mapping = {
    table('td.question')
    version(false)
    id(column: 'id', generator: 'sequence', params: [sequence: 'td.question_id_seq'])
    cache(true)
    questionAttachements(lazy: 'false', sort: 'rang', order: 'asc')
  }

  static transients = [
          'questionService',
          'specificationObject',
          'estEnNotationManuelle',
          'estInvariant',
          'attachement',
          'attachementId',
          'attachementFichier',
          'doitSupprimerAttachement'
  ]

  // transients
  Long attachementId
  MultipartFile attachementFichier
  Boolean doitSupprimerAttachement = false

  /**
   * Modifie la variable d'nstance doitSupprimerAttachement
   * @param newValeur la nouvelle valeur
   */
  void setDoitSupprimerAttachement(Boolean newValeur) {
    doitSupprimerAttachement = newValeur
    attachementId = null
    attachementFichier = null
  }

  /**
   *
   * @return true si la question induit une  notation  manuelle
   */
  boolean estEnNotationManuelle() {
    return type.code == QuestionTypeEnum.Open.name() ||
           type.code == QuestionTypeEnum.FileUpload.name()
  }

  boolean estComposite() {
    return type.code == QuestionTypeEnum.Composite.name()
  }

  /**
   *
   * @return la liste des attachements de la question courante
   */
  List<Attachement> attachements() {
    return questionAttachements*.attachement
  }

  /**
   * Retourne le premier attachement de la question si il existe
   * @return le premier attachement de la question si il existe
   */
  Attachement getAttachement() {
    if (questionAttachements?.size() > 0) {
      return questionAttachements.first().attachement
    }
    return null
  }

  /**
   *
   * @return l'objet encapsulant la spécification
   */
  def QuestionSpecification getSpecificationObject() {
    return getSpecificationObjectForJson(specification)
  }

  /**
   *
   * @return l'objet encapsulant la spécification pour un Json donné
   */
  def getSpecificationObjectForJson(String jsonSpec) {
    def specService = questionService.questionSpecificationServiceForQuestionType(type)
    specService.getObjectFromSpecification(jsonSpec)
  }

  /**
   * @return true si la question est distribuée
   * @see Artefact
   */
  boolean estDistribue() {
    // verifie en premier si des copies sont attachées à la question
    def critCopie = Copie.createCriteria()
    def nbCopies = critCopie.count {
      eq 'estJetable', false
      sujet {
        questionsSequences {
          eq 'question', this
        }
      }
    }
    if (nbCopies > 0) {
      return true
    }
    // sinon verifie qu'une séance ouverte n'est pas attaché à la question
    def now = new Date()
    def crit = ModaliteActivite.createCriteria()
    def nbSeances = crit.count {
      le 'dateDebut', now
      ge 'dateFin', now
      sujet {
        questionsSequences {
          eq 'question', this
        }
      }
    }
    return nbSeances > 0
  }

  /**
   *
   * @return true si la question est partagée
   * @see Artefact
   */
  boolean estPartage() {
    return publication != null
  }

  /**
   *
   * @return true si la question est invariante
   * @see Artefact
   */
  boolean estInvariant() {
    return estComposite()
  }

  @Override
  boolean estPresentableEnMoodleXML() {
    ["MultipleChoice",
            "Open",
            "Decimal",
            "Integer",
            "BooleanMatch",
            "ExclusiveChoice",
            "Associate",
            "Statement",
            "Composite"
    ].contains(type.code)
  }

}

