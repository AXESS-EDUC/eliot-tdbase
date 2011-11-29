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

import org.lilie.services.eliot.tdbase.QuestionSpecification
import org.lilie.services.eliot.tdbase.QuestionSpecificationService

/**
 * Service des specifications de questios de type associate.
 */
class QuestionAssociateSpecificationService extends QuestionSpecificationService<AssociateSpecification> {

    @Override
    def createSpecification(Object map) {
        new AssociateSpecification(map)
    }

}

/**
 * Specification de question de type associate
 */
class AssociateSpecification implements QuestionSpecification {

    /**
     * Le libellé.
     */
    String libelle
    /**
     * La correction.
     */
    String correction

    /**
     * La liste d'associations.
     */
    List<Associaction> associactions

    /**
     * La liste de tous les participants de toutes les associations.
     */
    List<String> participants

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
        associactions = params.associactions.collect {new Associaction(it)}
        setParticipants(associactions)
    }

    @Override
    Map toMap() {
        return [libelle: libelle,
                correction: correction,
                assocations: associactions.collect {it.toMap()}]
    }

    /**
     * Setter polymorphique pour la liste des Participants à partir d'une liste d'associations.
     * @param associactionList
     */
    void setParticipants(List<Associaction> associactionList) {
        participants = []
        associactionList.each {participants << it.participant1; participants << it.participant2}
        Collections.shuffle(participants)
    }
}

/**
 * Classe qui represente une associate. Une associate lie deux participants.
 */
class Associaction {

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
        if (object == null || !(object instanceof Associaction)) {
            return false
        }

        def meParticipants = [participant1, participant2]
        def lesAutresParticipants = [object.participant1, object.participant2]


        (meParticipants - lesAutresParticipants).isEmpty()
    }


}