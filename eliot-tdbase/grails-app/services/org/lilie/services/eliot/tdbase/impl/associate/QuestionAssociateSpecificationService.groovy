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

package org.lilie.services.eliot.tdbase.impl.associate

import grails.validation.Validateable
import org.lilie.services.eliot.tdbase.QuestionSpecification
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tice.utils.StringUtils

/**
 * Service des specifications de questios de type associate.
 */
class QuestionAssociateSpecificationService extends QuestionSpecificationService<AssociateSpecification> {

  @Override
  AssociateSpecification createSpecification(Map map) {
    new AssociateSpecification(map)
  }

}

/**
 * Specification de question de type associate
 */
@Validateable
class AssociateSpecification implements QuestionSpecification {

  String questionTypeCode = QuestionTypeEnum.Associate.name()

  /**
   * Le libellé.
   */
  String libelle

  /**
   * La correction.
   */
  String correction

  /**
   * Montrer la colonne à gauche.
   */
  boolean montrerColonneAGauche = false

  /**
   * La liste d'associations.
   */
  List<Association> associations = []

  /**
   * La liste de tous les participants de toutes les associations.
   */
  List<String> participants = []

  /**
   * Constructeur par défaut.
   */
  AssociateSpecification() {
    super()
  }

  /**
   * Constructeur.
   * @param params map de paramètres sous format de chaine de charactères.
   */
  AssociateSpecification(Map params) {
    libelle = params.libelle
    correction = params.correction
    associations = params.associations.collect {new Association(it)}
    montrerColonneAGauche = params.montrerColonneAGauche
    sauverParticipants(associations)
  }

  @Override
  Map toMap() {
    [
            questionTypeCode: questionTypeCode,
            libelle: libelle,
            correction: correction,
            associations: associations.collect {it.toMap()},
            montrerColonneAGauche: montrerColonneAGauche
    ]
  }

  /**
   * Setter polymorphique pour la liste des Participants à partir d'une liste d'associations.
   * @param associactionList
   */
  void sauverParticipants(List<Association> associactionList) {
    participants = []
    associactionList.each {participants << it.participant1; participants << it.participant2}
    Collections.shuffle(participants)
  }

  static constraints = {
    libelle blank: false
    associations minSize: 2
  }
}

/**
 * Classe qui represente une associate. Une associate lie deux participants.
 */
class Association {

  /**
   * Le premier participant.
   */
  String participant1
  /**
   * Le deuxieme participant.
   */
  String participant2

  /**
   * Marshalling des membres de la classe dans une map.
   * @return map des valeurs des membres de la classe.
   */
  Map toMap() {
    return [participant1: participant1,
            participant2: participant2]
  }

  /**
   * Evalue l'égalité de deux associations.
   * @param object l'associate à comparer.
   * @return vrai si l'intersection des ensembles de participants des deux associations est vide.
   */
  @Override
  boolean equals(Object object) {
    if (object == null || !(object instanceof Association)) {
      return false
    }

    def meParticipants = [StringUtils.normalise(participant1), StringUtils.normalise(participant2)]
    def lesAutresParticipants = [StringUtils.normalise(object.participant1), StringUtils.normalise(object.participant2)]


    (meParticipants - lesAutresParticipants).isEmpty()
  }


}