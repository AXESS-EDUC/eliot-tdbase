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

/**
 * Classe représentant un type de question
 * @author franck Silvestre
 */
class QuestionType {

  String nom
  String nomAnglais
  String code
  Boolean interaction

  static constraints = {
    nomAnglais(nullable: true)
  }

  static mapping = {
    table('td.question_type')
    version(false)
    id(column: 'id', generator: 'sequence', params: [sequence: 'td.question_type_id_seq'])
    cache('read-only')
  }
}

/**
 * Enumération des types de question
 * <ul>
 *  <li>MultipleChoice - question à choix multiple</li>
 *  <li>Open - question ouverte</li>
 *  <li>Decimal - question à réponse nombre décimal</li>
 *  <li>Integer - question à réponse nombre entièr</li>
 *  <li>Composite - question composée </li>
 *  <li>FillGap - texte à trous</li>
 *  <li>BooleanMatch - évaluation booléeene</li>
 *  <li>ExclusiveChoice - question à choix exclusif</li>
 *  <li>FillGraphics - graphique à compléter</li>
 *  <li>FileUpload - fichier à télécharger</li>
 *  <li>Order - ordre à rétablir</li>
 *  <li>Associate - associate</li>
 *  <li>Slider - curseur à déplacer</li>
 *  <li>GraphicMatch - association graphique</li>
 *  <li>Document - présentation d'un document (pas d'interaction) </li>
 *  <li>Statement - élément d'énoncé (pas d'interaction)</li>
 *
 * </ul>
 */
enum QuestionTypeEnum {

  MultipleChoice(1),
  Open(2),
  Decimal(3),
  Integer(4),
  Composite(5),
  FillGap(6),
  BooleanMatch(7),
  ExclusiveChoice(8),
  FillGraphics(9),
  FileUpload(10),
  Order(11),
  Associate(12),
  Slider(13),
  GraphicMatch(14),
  Document(51),
  Statement(52)


  private Long id

  private QuestionTypeEnum(Long id) {
    this.id = id
  }

  Long getId() {
    return id
  }

  QuestionType getQuestionType() {
    QuestionType.get(id)
  }

}