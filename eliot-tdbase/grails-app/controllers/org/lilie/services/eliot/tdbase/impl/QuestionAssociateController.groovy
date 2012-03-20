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

package org.lilie.services.eliot.tdbase.impl

import org.lilie.services.eliot.tdbase.QuestionController
import org.lilie.services.eliot.tdbase.impl.associate.AssociateSpecification
import org.lilie.services.eliot.tdbase.impl.associate.Association

/**
 * Controlleur pour la saisie des questions de type association
 */
class QuestionAssociateController extends QuestionController {

  @Override
  protected def getSpecificationObjectFromParams(Map params) {

    def specifobject = new AssociateSpecification()
    def size = params.specifobject.associations.size as Integer
    if (size) {
      size.times {
        specifobject.associations << new Association()
      }
    }
    bindData(specifobject, params, "specifobject")
  }

  /**
   *
   * Action "ajouteAssociation"
   */
  def ajouteAssociation() {
    AssociateSpecification specifobject = getSpecificationObjectFromParams(params) ?: new AssociateSpecification()
    specifobject.associations << new Association()
    render(
            template: "/question/Associate/AssociateEditionReponses",
            model: [specifobject: specifobject]
    )
  }

  /**
   *
   * Action "supprimeAssociation"
   */
  def supprimeAssociation() {
    AssociateSpecification specifobject = getSpecificationObjectFromParams(params)
    specifobject.associations.remove(params.id as Integer)
    render(
            template: "/question/Associate/AssociateEditionReponses",
            model: [specifobject: specifobject]
    )
  }

}
