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

import org.lilie.services.eliot.tdbase.QuestionSpecification
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import static java.util.Collections.shuffle
import grails.validation.Validateable

/**
 * Service des specifications de questions de type texte à trou.
 * @author Bert Poller
 */
class QuestionFillGapSpecificationService extends QuestionSpecificationService<FillGapSpecification> {

  @Override
  def createSpecification(map) {
    new FillGapSpecification(map)
  }
}

/**
 * Specification de question de type texte à trou
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
   * Structure de donnée qui contient le texte à trous.
   */
  List<TextATrouElement> texteATrousStructure = []

  /**
   * Liste des elements decrivant les reponses possibles pour un trou.
   */
  List<TrouElement> trouElements = []

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
   * @return String du texte à trou.
   */
  def String getTexteATrous() {
    def texte = ""
    texteATrousStructure.each { texte += it.valeurAsText()}
    texte
  }
  /**
   * Implementation du setter pour l'attribut virtuel 'texteATrous'. Parse le paramètre 'texteATrous' et l'organise
   * dans les attributs texteATrousStructure et trouElements.
   * @param texteATrous le String qui est parsé.
   */
  void setTexteATrous(String texteATrous) {
    def texte = texteATrous ?: ""
    def index = 0
    while (!texte.isEmpty()) {

      if (!extractText(texte).isEmpty()) {
        texteATrousStructure << new TextElement([index: index, valeur: extractText(texte)])
        texte = eatText(texte)
      } else {
        def trou = new TrouElement([index: index, valeur: extractGap(texte)])
        texteATrousStructure << trou
        trouElements << trou
        texte = eatGap(texte)
      }
      index++
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
   * Enlèvement d'un token de type "texte" du debut du texte à trou.
   * @param texte le texte à trou
   * @return le texte moins le token de type "texte" au debut. Si aucun token de type "trou" existe, une chaine vide
   * est retournée.
   */
  private String eatText(String texte) {
    if (texte.indexOf("#{") > -1) {
      texte.substring(texte.indexOf("#{"), texte.length())
    } else ""
  }

  /**
   * Extraction d'un token de type "texte" du debut du texte à trou jusqu'à la première occurrence d'un token de
   * type "trou".
   * @param texte le texte à trou
   * @return l'extrait du token ou la chaine entière, si aucun token de type "trou" existe.
   */
  private String extractText(String texte) {
    if (texte.indexOf("#{") > -1) {
      texte.substring(0, texte.indexOf("#{"))
    } else texte
  }

  /**
   * Enlèvement d'un token de type "trou" du debut du texte à trou.
   * @param texte le texte à trou.
   * @return le texte moins le token de type "trou" au debut.
   */
  private String eatGap(String texte) {
    texte.substring(texte.indexOf("}") + 1, texte.length())
  }

  /**
   * Extraction d'un token de type "trou" du debut du texte à trou jusqu'à la première occurrence d'un token de
   * type "texte".
   * @param texte le texte à trou.
   * @return Liste des reponses valides pour le trou.
   */
  private List<String> extractGap(String texte) {

    def List<String> reponseList = []

    if (texte.indexOf("#{") > -1) {
      def gapText = texte.substring(0, texte.indexOf("}") + 1)
      gapText = (gapText =~ /#/).replaceAll("")
      gapText = (gapText =~ /\{/).replaceAll("")
      gapText = (gapText =~ /\}/).replaceAll("")

      reponseList = gapText.split(",")
      reponseList = reponseList.collect {it.trim()}
    }

    reponseList
  }
}
/**
 * Classe abstraite d'un constituant d'un texte à trou.
 * @param < V >       le type de la valeur du constituant.
 */
abstract class TextATrouElement<V> {
  int index
  V valeur

  /**
   * Retourne le presentation textuelle de la valeur du constituant de texte à trou.
   * @return la valeur sous forme de texte.
   */
  abstract String valeurAsText()

  /**
   * Indique si le constituant du texte à trou est de type "Texte".
   * @return boolen
   */
  abstract boolean isTexte()
}

/**
 * Constituant d'un texte à trous de type "Texte".
 */
class TextElement extends TextATrouElement<String> {

  @Override
  String valeurAsText() {
    valeur
  }

  @Override
  boolean isTexte() {
    true
  }
}

/**
 * Constituant d'un texte à trous de type "Trou".
 */
class TrouElement extends TextATrouElement<List<String>> {

  @Override
  String valeurAsText() {

    def texte = ""

    if (valeur.size() > 0) {
      texte += "#{" + valeur[0]
    }

    if (valeur.size() > 1) {
      for (def i in 1..valeur.size() - 1) {
        texte += ", ${valeur[i]}"
      }
    }

    texte += "}"
    texte
  }

  @Override
  boolean isTexte() {
    false
  }
}