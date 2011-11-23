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







package org.lilie.services.eliot.tdbase.impl.exclusivechoice

import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.Reponse
import org.lilie.services.eliot.tdbase.ReponseSpecification
import org.lilie.services.eliot.tdbase.ReponseSpecificationService
import org.springframework.transaction.annotation.Transactional

/**
 *
 * @author franck Silvestre
 */
class ReponseExclusiveChoiceSpecificationService extends ReponseSpecificationService<ReponseExclusiveChoiceSpecification> {

    @Override
    ReponseExclusiveChoiceSpecification createSpecification(Map map) {
        new ReponseExclusiveChoiceSpecification(map)
    }

    /**
     * Si il n'y a aucune réponse explicite (pas de bouton coché), la notes est 0.
     * Si il y a au moins une réponse explicite (un bouton cochée), alors :
     * - si réponse juste on ajoute un point
     * - si réponse fausse on retranche un point
     * On effectue une règle de trois pour ramener la note correspondant au barême
     *
     * @see ReponseSpecificationService
     */
    @Transactional
    Float evalueReponse(Reponse reponse) {
        def res = 0
        ReponseExclusiveChoiceSpecification repSpecObj = reponse.specificationObject
        ExclusiveChoiceSpecification questSpecObj = reponse.sujetQuestion.question.specificationObject
        if (repSpecObj.indexReponse == questSpecObj.indexBonneReponse) {
            res = reponse.sujetQuestion.points
        } else if (repSpecObj.indexReponse != null) {
            def nbRepPos = questSpecObj.reponses.size()
            // on décompte avec points positifs et/ou négatifs
            res = (-1 / nbRepPos) * reponse.sujetQuestion.points
        }
        reponse.correctionNoteAutomatique = res
        reponse.save()
        return res
    }


}

/**
 * Représente un objet spécification pour une question de type MultipleChoice
 */
class ReponseExclusiveChoiceSpecification implements ReponseSpecification {

    Integer indexReponse

    ReponseExclusiveChoiceSpecification() {
        super()
    }

    /**
     * Créer et initialise un nouvel objet de type RepoonseMultipleChoiceSpecification
     * @param map la map permettant d'initialiser l'objet en cours
     * de création
     */
    ReponseExclusiveChoiceSpecification(Map map) {
        indexReponse = map.indexReponse
    }



    Map toMap() {
        [
                indexReponse: indexReponse
        ]
    }

}