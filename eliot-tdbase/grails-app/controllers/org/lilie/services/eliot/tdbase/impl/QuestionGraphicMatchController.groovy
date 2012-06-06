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
import org.lilie.services.eliot.tdbase.impl.graphicmatch.GraphicMatchSpecification
import org.lilie.services.eliot.tdbase.impl.graphicmatch.Hotspot
import org.lilie.services.eliot.tdbase.impl.graphicmatch.MatchIcon

/**
 * Controlleur pour la saisie des questions de type graphique à compléter
 */
class QuestionGraphicMatchController extends QuestionController {

  @Override
  protected def getSpecificationObjectFromParams(Map params) {

    def specifobject = new GraphicMatchSpecification()
    def size = params.specifobject.hotspots?.size
    if (size) {
      size = size as Integer
      size.times {
        specifobject.hotspots << new Hotspot()
      }
    }

    size = params.specifobject.icons?.size
    if (size) {
      size = size as Integer
      size.times {
        specifobject.icons << new MatchIcon()
      }
    }

    bindData(specifobject, params, "specifobject")
  }

  /**
   *
   * Action "ajouteHotspot"
   */
  def ajouteHotspot() {
    GraphicMatchSpecification specifobject = getSpecificationObjectFromParams(params) ?: new GraphicMatchSpecification()

    def hotspotId = createId(specifobject.hotspots)
    def iconId = createId(specifobject.icons)

    specifobject.hotspots << new Hotspot([id: hotspotId])
    specifobject.icons << new MatchIcon([id: iconId])
    specifobject.graphicMatches[iconId] = hotspotId

    render(
            template: "/question/GraphicMatch/GraphicMatchEditionHotSpots",
            model: [specifobject: specifobject]
    )
  }

  /**
   *
   * Action "supprimerHotSpot"
   */
  def supprimeHotspot() {
    GraphicMatchSpecification specifobject = getSpecificationObjectFromParams(params)
    def hotspotId = specifobject.hotspots[params.id.toInteger()].id

    Long matchingIconId = lookupIconId(specifobject.graphicMatches, hotspotId)

    specifobject.hotspots.remove(params.id as Integer)
    specifobject.graphicMatches.remove(matchingIconId)
    specifobject.icons.remove(specifobject.icons.find {
      icon -> icon.id == matchingIconId
    })

    render(
            template: "/question/GraphicMatch/GraphicMatchEditionHotSpots",
            model: [specifobject: specifobject]
    )
  }

  private Long lookupIconId(Map<Long, String> graphicMatches, String hotspotId) {

    Long matchingIconId

    graphicMatches.each {entry ->
      if (entry.value == hotspotId) {matchingIconId = entry.key}
    }

    matchingIconId
  }

  private createId(List items) {
    def idList = items*.id.collect {it.toInteger()}
    if (idList && !idList.isEmpty()) {
      return (idList.max() + 1).toString()
    }
    "1"
  }
}