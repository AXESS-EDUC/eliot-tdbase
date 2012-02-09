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

import grails.validation.Validateable
import org.lilie.services.eliot.tdbase.QuestionSpecification
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import static java.util.Collections.shuffle

/**
 * Service des specifications de questions de type text à trou.
 * @author Bert Poller
 */
class QuestionFillGapSpecificationService extends QuestionSpecificationService<FillGapSpecification> {

    @Override
    def createSpecification(map) {
        new FillGapSpecification(map)
    }
}

/**
 * Specification de question de type text à trou
 */
@Validateable
class FillGapSpecification implements QuestionSpecification {

    /**
     * Le libellé.
     */
    String libelle

    /**
     * Indique si la suggestion des reponses doit être activée.
     */
    boolean montrerLesMots

    /**
     * La correction de la question.
     */
    String correction

    /**
     * Structure de donnée qui contient le text à trous.
     */
    List<TextATrouElement> texteATrousStructure = []


    @Override
    Map toMap() {
        [
                libelle: libelle,
                montrerLesMots: montrerLesMots,
                texteATrous: texteATrous,
                correction: correction,
        ]
    }

    static constraints = {
        libelle blank: false
        texteATrousStructure minSize: 2
    }

    /**
     * Implementation du getter pour l'attribut virtuel 'texteATrous'. Se repose sur la structure de données
     * texteATrousStructure pour sa génération.
     * @return String du text à trou.
     */
    def String getTexteATrous() {
        def texte = ""
        texteATrousStructure.each { texte += it.valeurAsText()}
        texte
    }
    /**
     *
     * On imagine le text à trou comme un stack qui est une mélange des TextElements et TrouElements.
     * Cette méthode prends élément par element et les range dans une liste.
     *
     * @param texteATrous le String qui est parsé.
     */
    void setTexteATrous(String texteATrous) {
        def text = texteATrous ?: ""
        while (!text.isEmpty()) {
            if (peekedElementIsText(text)) {
                texteATrousStructure << extractTextElement(text)
                text = eatText(text)
            } else {
                texteATrousStructure << extractGap(text)
                text = eatGap(text)
            }
        }
    }

    protected boolean peekedElementIsText(String text) {
        text.indexOf("{") != 0
    }

    /**
     * Extraction d'un token de type "text" du debut du text à trou jusqu'à la première occurrence d'un token de
     * type "trou".
     * @param text le text à trou
     * @return l'extrait du token ou la chaine entière, si aucun token de type "trou" existe.
     */
    protected TextElement extractTextElement(String text) {
        assert (peekedElementIsText(text))
        def index = getIndexOfGapToken(text)

        // s'il y a un token alors ...
        if (index) {
            //...retourne un TextElement du texte avant le token.
            return new TextElement(valeur: text.substring(0, index).replaceAll("\\\\\\{", "{"))
        }

        else {
            //sinon ...on retourne tous le texte.
            return new TextElement(valeur: text.replaceAll("\\\\\\{", "{"))
        }
    }

/**
 * Genère une liste des mots suggerés comme reponses. Utilise l'attribut trouElements. Parmi les possibilité de
 * reponse pour un trouElement, le premier est choisi pour la suggestion de reponse. Les suggestions de reponse sont
 * melangés pour que le candidat qui passe le teste ne trouve pas de correlation entre les trous à remplir et le
 * reponses suggerés.
 * @return une liste des reponses suggerés.
 */
    def List getMotsSugeres() {
        def mots = []
        trouElements.each {
            if (it.valeur.size() > 0) { mots << it.valeur[0]}
        }
        shuffle(mots, new Random())
        mots
    }

/**
 * Enlèvement d'un token de type "text" du debut du text à trou.
 * @param texte le text à trou
 * @return le text moins le token de type "text" au debut. Si aucun token de type "trou" existe, une chaine vide
 * est retournée.
 */
    protected String eatText(String text) {
        assert (peekedElementIsText(text))
        def index = getIndexOfGapToken(text)
        index ? text.substring(index, text.length()) : text
    }

    /**
     * Trouve la première occurrence d'un token. Tollerant aux charactères d'escape.
     * @param token
     * @param text
     * @return
     */
    private Integer getIndexOfToken(String token, String text) {
        Integer index

        //
        for (i in 0..text.length() - 1) {
            if (text[i].equals(token) && !text[i - 1].equals('\\')) {
                index = i
                break
            }
        }
        index
    }

/**
 * Enlèvement d'un token de type "trou" du debut du text à trou.
 * @param texte le text à trou.
 * @return le text moins le token de type "trou" au debut.
 */
    private String eatGap(String texte) {
        texte.substring(texte.indexOf("}") + 1, texte.length())
    }

/**
 * Extraction d'un token de type "trou" du debut du text à trou jusqu'à la première occurrence d'un token de
 * type "text".
 * @param texte le text à trou.
 * @return Liste des reponses valides pour le trou.
 */
    protected TrouElement extractGap(String texte) {
        def List<TrouText> reponseList = []
        def endTokenIndex = getIndexOfToken('}', texte)
        assert texte.indexOf("{") == 0 && endTokenIndex

        def gapText = texte.substring(1, endTokenIndex)

        while (!gapText.isEmpty()) {
            if (gapText[0] == '=') {

//>>>>>>>>>>Continue here

                reponseList << new TrouText(correct: true, text: 'toto')

            }
            else {
                reponseList << new TrouText(correct: false, text: 'toto')
            }
        }

        new TrouElement(valeur: reponseList)
    }

}
/**
 * Interface d'un constituant d'un text à trou.
 */
interface TextATrouElement {

    /**
     * Retourne le presentation textuelle de la valeur du constituant de text à trou.
     * @return la valeur sous forme de text.
     */
    String valeurAsText()

    /**
     * Indique si le constituant du text à trou est de type "Texte".
     * @return boolen
     */
    boolean isTextElement()
}

/**
 * Constituant d'un text à trous de type "Texte".
 */
class TextElement implements TextATrouElement {

    String valeur


    String valeurAsText() {
        valeur
    }


    boolean isTextElement() {
        true
    }
}

/**
 * Constituant d'un text à trous de type "Trou".
 */
class TrouElement implements TextATrouElement {

    List<TrouText> valeur = []

    @Override
    String valeurAsText() {

        def texte = ""

        if (valeur.size() > 0) {
            texte += "{" + valeur[0].toString()
        }

        if (valeur.size() > 1) {
            for (def i in 1..valeur.size() - 1) {
                texte += valeur[i].toString()
            }
        }
        texte + "}"
    }

    boolean isTextElement() {
        false
    }

}

class TrouText {
    String text
    boolean correct

    public String toString() {
        (correct ? "=" : "~") + text
    }
}