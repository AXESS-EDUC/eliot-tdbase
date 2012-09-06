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




package org.lilie.services.eliot.tdbase.impl.slider

import grails.validation.Validateable
import org.lilie.services.eliot.tdbase.QuestionSpecification
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tice.utils.NumberUtils
import org.lilie.services.eliot.tdbase.QuestionTypeEnum

/**
 *
 * @author franck Silvestre
 */
class QuestionSliderSpecificationService extends QuestionSpecificationService<SliderSpecification> {

  @Override
  SliderSpecification createSpecification(Map map) {
    new SliderSpecification(map)
  }

}

/**
 * Représente un objet spécification pour une question de type Decimal
 */
@Validateable
class SliderSpecification implements QuestionSpecification {
  String questionTypeCode = QuestionTypeEnum.Slider.name()
  String libelle
  Float valeur
  Float precision = 0
  Float valeurMin = 0
  Float valeurMax = 0
  Float pas = 0
  String correction


  SliderSpecification() {
    super()
  }

  /**
   * Créer et initialise un nouvel objet de type MultipleChoiceSpecification
   * @param map la map permettant d'initialiser l'objet en cours
   * de création
   */
  SliderSpecification(Map map) {
    libelle = map.libelle
    valeur = map.valeur
    valeurMin = map.valeurMin
    valeurMax = map.valeurMax
    precision = map.precision
    pas = map.pas
    correction = map.correction
  }

  Map toMap() {
    [
            questionTypeCode: questionTypeCode,
            libelle: libelle,
            valeur: valeur,
            valeurMin: valeurMin,
            valeurMax: valeurMax,
            pas: pas,
            precision: precision,
            correction: correction
    ]
  }

  String getValeurAffichage() {
    if (valeur != null) {
      return NumberUtils.formatFloat(valeur)
    }
    return null
  }

  String getPrecisionAffichage() {
    if (precision != null) {
      return NumberUtils.formatFloat(precision)
    }
    return null
  }

  String getValeurMinAffichage() {
    valeurMin != null ? NumberUtils.formatFloat(valeurMin) : null
  }

  String getValeurMaxAffichage() {
    valeurMax != null ? NumberUtils.formatFloat(valeurMax) : null
  }

  String getPasAffichage() {
    pas != null ? NumberUtils.formatFloat(pas) : null
  }

  static constraints = {
    libelle blank: false
    valeur nullable: false, validator: {  val, obj ->
        return val <= obj.valeurMax && val >= obj.valeurMin
    }
    valeurMin(nullable: false)
    valeurMax(nullable: false)
    precision(nullable: false)
    pas(nullable: false)
  }

}