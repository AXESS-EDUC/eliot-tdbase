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

package org.lilie.services.eliot.tdbase.impl.order

import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.ReponseSpecification
import org.lilie.services.eliot.tdbase.ReponseSpecificationService

/**
 * Service pour les specifications de reponses de type 'ordre à retablir'.
 */
class ReponseOrderSpecificationService extends ReponseSpecificationService<ReponseOrderSpecification> {


    @Override
    ReponseOrderSpecification createSpecification(Map map) {
        new ReponseOrderSpecification(map)
    }

    @Override
    ReponseOrderSpecification getObjectInitialiseFromSpecification(Question question) {

        List<Item> valeursReponse = []

        question.specificationObject.orderedItems.each {
            valeursReponse << new Item(text: it.text)
        }

        new ReponseOrderSpecification(valeursDeReponse: valeursReponse,
                reponsesPossibles: question.specificationObject.orderedItems)
    }

    @Override
    Float evalueReponse(org.lilie.services.eliot.tdbase.Reponse reponse) {

        ReponseOrderSpecification repSpecObj = reponse.specificationObject

        float points = repSpecObj.evaluate(reponse.sujetQuestion.points)

        reponse.correctionNoteAutomatique = points
        reponse.save()
        points
    }
}

/**
 * Specifications de reponses de type ordre a retablir.
 */
class ReponseOrderSpecification implements ReponseSpecification {

    /**
     * Liste d'elements fournis comme reponse à la question.
     */
    List<Item> valeursDeReponse = []

    /**
     * Liste d'elements qui forment une reponse correcte.
     */
    List<Item> reponsesPossibles = []

    /**
     * Constructeur par defaut
     */
    ReponseOrderSpecification() {
        super()
    }

    /**
     * Constructeur
     * @param params map des paramètres pour l'initialisation de l'objet
     */
    ReponseOrderSpecification(Map params) {
        valeursDeReponse = params.valeursDeReponse.collect {createItem(it)}
        reponsesPossibles = params.reponsesPossibles.collect {createItem(it)}
    }

    @Override
    Map toMap() {
        [
                valeursDeReponse: valeursDeReponse.collect {it.toMap()},
                reponsesPossibles: reponsesPossibles.collect {it.toMap()}
        ]
    }

    /**
     * Logique d'evaluation.
     * @param maximumPoints les points maximum que l'on peut atteindre si la reponse est bonne.
     * @return les points correspondants à l'evaluation.
     */
    def evaluate(float maximumPoints) {
        float points = maximumPoints
        def difference = valeursDeReponse - reponsesPossibles
        if (!difference.isEmpty()) {
            points = 0.0f
        }
        points
    }

    def createItem(Item item) {
        item
    }

    def createItem(Map params) {
        new Item(params)
    }
}