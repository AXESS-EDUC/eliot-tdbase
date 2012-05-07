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

import grails.validation.Validateable
import org.lilie.services.eliot.tdbase.QuestionSpecification
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tdbase.QuestionTypeEnum

/**
 * Service des specifications de questios de type 'ordre à retablir'.
 */
class QuestionOrderSpecificationService extends QuestionSpecificationService<OrderSpecification> {


  @Override
  OrderSpecification createSpecification(Map map) {
    new OrderSpecification(map)

  }
}

/**
 * Specification d'une question de type 'ordre à retablir'.
 */
@Validateable
class OrderSpecification implements QuestionSpecification {
  String questionTypeCode = QuestionTypeEnum.Order.name()
  /**
   * Le libellé.
   */
  String libelle

  /**
   * La correction.
   */
  String correction

  /**
   * Les elements dans leur ordre.
   */
  List<Item> orderedItems = []

  /**
   * Constructeur par defaut.
   */
  OrderSpecification() {
    super()
  }

  /**
   * Constructeur
   * @param params map des paramètres pour l'initialisation de l'objet
   */
  OrderSpecification(Map params) {
    libelle = params.libelle
    correction = params.correction
    orderedItems = params.orderedItems.collect {new Item(it)}
  }

  @Override
  Map toMap() {
    [
            questionTypeCode: questionTypeCode,
            libelle: libelle,
            correction: correction,
            orderedItems: orderedItems.collect {it.toMap()}
    ]
  }

  /**
   * Genère une liste des ordinals que l'on peut selectionner lors de l'edition d'une question de type
   * ordre à retablir.
   * @return
   */
  def getSelectableOrdinalList() {
    def ordinal = 1
    def selectableOrdinalList = []
    orderedItems.size().times {selectableOrdinalList << ordinal++}
    selectableOrdinalList
  }

  def getShuffledItems() {
    def shuffledItems = []
    orderedItems.each {shuffledItems << it}

    Collections.shuffle(shuffledItems)
    while (ordinalsAreSame(shuffledItems, orderedItems)) {
      Collections.shuffle(shuffledItems)
    }
    shuffledItems
  }

  private boolean ordinalsAreSame(List<Item> left, List<Item> right) {
    for (i in 0..left.size()) {
      if (!left[i]?.ordinal.equals(right[i]?.ordinal)) {
        return false
      }
    }
    true
  }

  static constraints = {
    libelle blank: false
    orderedItems minSize: 2
  }
}

/**
 * Un element de la liste des elements à remettre en ordre.
 */
class Item {
  /**
   * Le texte.
   */
  String text
  /**
   * La position dans la liste.
   */
  String ordinal

  /**
   * Marshalling sous forme d'une map.
   * @return la presentation map de l'Item.
   */
  Map toMap() {
    [text: text, ordinal: ordinal]
  }

  @Override
  boolean equals(Object object) {
    if (object != null && object instanceof Item) {
      Item theOther = object
      return text == theOther.text && ordinal == theOther.ordinal
    }
    false
  }

  @Override
  int hashCode() {
    int hash = 1
    hash = hash * 31 + (text == null ? 0 : text.hashCode())
    hash = hash * 31 + (ordinal == null ? 0 : ordinal.hashCode())
    hash
  }
}