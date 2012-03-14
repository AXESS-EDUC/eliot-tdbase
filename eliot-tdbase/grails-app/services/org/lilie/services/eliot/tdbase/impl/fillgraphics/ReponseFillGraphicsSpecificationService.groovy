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

package org.lilie.services.eliot.tdbase.impl.fillgraphics

import grails.validation.Validateable
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.ReponseSpecification
import org.lilie.services.eliot.tdbase.ReponseSpecificationService
import org.lilie.services.eliot.tice.utils.StringUtils
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.QuestionSpecification

/**
 *   Service pour les specifications de reponses de type 'graphique à compléter'.
 */
class ReponseFillGraphicsSpecificationService extends
        ReponseSpecificationService<ReponseFillGraphicsSpecification> {

  @Override
  ReponseFillGraphicsSpecification createSpecification(Map map) {
    new ReponseFillGraphicsSpecification(map)
  }

  @Override
  ReponseFillGraphicsSpecification getObjectInitialiseFromSpecification(QuestionSpecification questionSpecification) {
    List<TextZoneContenu> reponsesPossibles = []
    List<TextZoneContenu> valeursDeReponse = []
    questionSpecification.textZones.each {
      reponsesPossibles << new TextZoneContenu(id: it.id, text: it.text)
      valeursDeReponse << new TextZoneContenu()
    }
    createSpecification(reponsesPossibles: reponsesPossibles, valeursDeReponse: valeursDeReponse)
  }
}

/**
 * Specifications de reponses de type 'graphique à compléter'.
 */
class ReponseFillGraphicsSpecification implements ReponseSpecification {
  String questionTypeCode = QuestionTypeEnum.FillGraphics.name()
  /**
   * Liste d'elements fournis comme reponse à la question.
   */
  List<TextZoneContenu> valeursDeReponse = []

  /**
   * Liste d'elements qui forment une reponse correcte.
   */
  List<TextZoneContenu> reponsesPossibles = []

  /**
   * Calcule la TextZoneContenus differents entre reponses possibles et
   * valeurs de reponse. Le nombre des differences est ensuite deduit au
   * pro-rata des points maximales atteignables.
   *
   * @param maximumPoints
   * @return
   */
  float evaluate(float maximumPoints) {
    def nombreReponses = reponsesPossibles.size()
    def nombreDifferences = (reponsesPossibles - valeursDeReponse).size()
    def reponsesCorrects = nombreReponses - nombreDifferences
    reponsesCorrects / nombreReponses * maximumPoints
  }

  ReponseFillGraphicsSpecification(Map params) {
    valeursDeReponse = params.valeursDeReponse
    reponsesPossibles = params.reponsesPossibles
  }

  @Override
  Map toMap() {
    [
            questionTypeCode: questionTypeCode,
            valeursDeReponse: valeursDeReponse,
            reponsesPossibles: reponsesPossibles
    ]
  }
}

/**
 * Un Text element qui sert à comparer le contenu des text zones
 */

class TextZoneContenu {

/**
 * L'identifiant. 
 */
  String id = ""

  /**
   * Le texte que cette zone doit afficher.
   */
  String text = ""

  /**
   * Conversion de l'objet en map.
   * @return une map des attributs de l'objet.
   */
  Map toMap() {[id: id, text: text]}

  @Override
  boolean equals(other) {
    if (this.is(other)) return true
    if (!(other instanceof TextZoneContenu)) return false

    TextZoneContenu that = (TextZoneContenu) other

    if (id != that.id) return false
    if (StringUtils.normalise(text) != StringUtils.normalise(that.text)) return false

    println "Text:" + StringUtils.normalise(text)
    println "Other:" + StringUtils.normalise(that.text)
    true
  }

  @Override
  int hashCode() {
    int result
    result = (id != null ? id.hashCode() : 0)
    31 * result + (text != null ? StringUtils.normalise(text).hashCode() : 0)
  }
}
