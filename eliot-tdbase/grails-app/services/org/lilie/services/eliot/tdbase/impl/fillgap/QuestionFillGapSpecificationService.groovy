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
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import static java.util.Collections.shuffle

/**
 * Service des specifications de questions de type text à trou.
 * @author Bert Poller
 */
class QuestionFillGapSpecificationService extends QuestionSpecificationService<FillGapSpecification> {

  @Override
  FillGapSpecification createSpecification(Map params) {
    new FillGapSpecification(params)
  }
}

/**
 * Specification de question de type text à trou
 */
  @Validateable
  class FillGapSpecification implements QuestionSpecification {
    String questionTypeCode = QuestionTypeEnum.FillGap.name()
    /**
     * Le libellé.
     */
    String libelle

    /**
     * Indique le mode de saisie.
     */
    String modeDeSaisie = 'SL'

    final static String SAISIE_LIBRE = 'SL'
    final static String SAISIE_MONTRER_LES_MOTS = 'MLM'
    final static String SAISIE_MENU_DEROULANT = 'MDR'

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
              questionTypeCode: questionTypeCode,
              libelle: libelle,
              modeDeSaisie: modeDeSaisie,
              texteATrous: texteATrous,
              correction: correction
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
    def setTexteATrous(String texteATrous) {
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

    /**
     * Genère une liste des mots suggerés comme reponses.
     * @return une liste des reponses suggerés.
     */
    def List getMotsSugeres() {
      def mots = []
      texteATrousStructure.each {
        if (!it.isTextElement()) {
          TrouElement trouElement = (TrouElement) it
          trouElement.valeur.each {
            mots << it.text
          }
        }
      }
      shuffle(mots, new Random())
      mots
    }

    private boolean peekedElementIsText(String text) {
      text.indexOf("{") != 0
    }

    /**
     * Extraction d'un token de type "text" du debut du text à trou jusqu'à la première occurrence d'un token de
     * type "trou".
     * @param text le text à trou
     * @return l'extrait du token ou la chaine entière, si aucun token de type "trou" existe.
     */
    private TextElement extractTextElement(String text) {
      assert (peekedElementIsText(text))
      def index = getIndexOfToken('{', text)

      // s'il y a un token alors ...
      if (index) {
        //...retourne un TextElement du text avant le token.
        return new TextElement(valeur: text.substring(0, index).replaceAll("\\\\\\{", "{"))
      }

      else {
        //sinon ...on retourne tous le text.
        return new TextElement(valeur: text.replaceAll("\\\\\\{", "{"))
      }
    }

    /**
     * Enlèvement d'un token de type "text" du debut du text à trou.
     * @param texte le text à trou
     * @return le text moins le token de type "text" au debut. Si aucun token de type "trou" existe, une chaine vide
     * est retournée.
     */
    private String eatText(String text) {
      assert (peekedElementIsText(text))
      def index = getIndexOfToken('{', text)
      index ? text.substring(index, text.length()) : ""
    }

    /**
     * Trouve la première occurrence d'un token. Tollerant aux charactères d'escape.
     * @param token
     * @param text
     * @return
     */
    private Integer getIndexOfToken(String token, String text) {
      Integer index = null
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
     * @param text le text à trou.
     * @return le text moins le token de type "trou" au debut.
     */
    private String eatGap(String text) {
      assert (!peekedElementIsText(text))
      text.substring(getIndexOfToken('}', text) + 1, text.length())
    }

    /**
     * Extraction d'un token de type "trou" du debut du text à trou jusqu'à la première occurrence d'un token de
     * type "text".
     * @param texte le text à trou.
     * @return Liste des reponses valides pour le trou.
     */
    private TrouElement extractGap(String texte) {
      def List<TrouText> reponseList = []
      def endTokenIndex = getIndexOfToken('}', texte)
      assert texte.indexOf("{") == 0 && endTokenIndex

      def gapText = texte.substring(1, endTokenIndex).trim()

      while (!gapText.isEmpty()) {

        assert (gapText[0] == '=' || gapText[0] == '~')

        def isCorrect = gapText[0] == '='

        gapText = gapText.substring(1)
        Integer indexOfNextToken = getNextTrouTextBeginningToken(gapText)
        def trouText = indexOfNextToken ? gapText.substring(0, indexOfNextToken) : gapText

        reponseList << new TrouText(correct: isCorrect, text: trouText)

        gapText = indexOfNextToken ? gapText.substring(indexOfNextToken, gapText.length()) : ""
      }

      new TrouElement(valeur: reponseList)
    }

    /**
     * Trouve l'index du prochain token qui indique le debut d'une variante de reponse pour un trou.
     *
     * Pour un texte de 'titi=toto~tata' la reponse est 4.
     *
     * @param text MQ
     * @return
     */
    private Integer getNextTrouTextBeginningToken(String text) {
      Integer correctTokenIndex = getIndexOfToken('=', text)
      Integer inCorrectTokenIndex = getIndexOfToken('~', text)

      if (correctTokenIndex && inCorrectTokenIndex) {
        Math.min(correctTokenIndex, inCorrectTokenIndex)
      } else if (correctTokenIndex) {
        correctTokenIndex
      } else if (inCorrectTokenIndex) {
        inCorrectTokenIndex
      } else {
        null
      }
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