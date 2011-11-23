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

package org.lilie.services.eliot.tdbase.impl.fillgap

import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tdbase.Specification
import org.lilie.services.eliot.tice.utils.StringUtils

/**
 * @author Bert Poller
 */
class QuestionFillGapSpecificationService extends QuestionSpecificationService<FillGapSpecification> {

    @Override
    def createSpecification(map) {
        new FillGapSpecification(map);
    }

    @Override
    def updateQuestionSpecificationForObject(Question question, Object object) {
        question.specification = getSpecificationFromObject(object)
        question.specificationNormalise = getSpecificationNormaliseFromObject(object)
        question.save()
    }

    @Override
    def getSpecificationNormaliseFromObject(FillGapSpecification specification) {
        specification?.libelle ? StringUtils.normalise(specification.libelle) : null
    }
}

class FillGapSpecification implements Specification {

    String libelle
    boolean montrerLesMots
    String texteATrous
    String correction

    Map toMap() {
        [
                libelle: libelle,
                montrerLesMots: montrerLesMots,
                texteATrous: texteATrous,
                correction: correction
        ]
    }


    def getMotsSugeres() {

        def mots = []

        reponsesPossibles.each {
            if (it.size() > 0) { mots << it[0]}
        }
        Collections.shuffle(mots, new Random())

        mots
    }

    def getReponsesPossibles() {

        def gaps = []
        def texte = texteATrous

        while (!texte.isEmpty()) {
            texte = eatText(texte)
            extractGap(texte, gaps)
            texte = eatGap(texte)
        }

        gaps.collect {
            String gapSpec = it

            gapSpec = (gapSpec =~ /#/).replaceAll("")
            gapSpec = (gapSpec =~ /\{/).replaceAll("")
            gapSpec = (gapSpec =~ /\}/).replaceAll("")

            def reponseList = gapSpec.split(",")
            reponseList.collect {StringUtils.normalise(it.trim())}
        }
    }

    List<TextElement> getTexteATrousStructure() {

        def List<TextElement> structure = []
        def texte = texteATrous
        def index = 0
        while (!texte.isEmpty()) {

            if (!extractText(texte).isEmpty()) {
                structure << new TextElement([index: index, valeur: extractText(texte), type: "TEXTE"])
                texte = eatText(texte)
            } else {
                structure << new TextElement([index: index, type: "TROU"])
                texte = eatGap(texte)
            }
            index++
        }
        structure
    }

    String eatText(String texte) {
        if (texte.indexOf("#{") > -1) {
            texte.substring(texte.indexOf("#{"), texte.length())
        } else ""
    }

    String extractText(String texte) {
        if (texte.indexOf("#{") > -1) {
            texte.substring(0, texte.indexOf("#{"))
        } else texte
    }

    void extractGap(String texte, List gaps) {
        if (texte.indexOf("#{") > -1) {
            gaps << texte.substring(0, texte.indexOf("}") + 1)
        }
    }

    String eatGap(String texte) {
        texte.substring(texte.indexOf("}") + 1, texte.length())
    }
}

class TextElement {
    int index
    String valeur
    String type

    Map toMap() {
        [
                index: index,
                valeur: valeur,
                type: type
        ]
    }

}