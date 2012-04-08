/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *  
 *  Lilie is free software. You can redistribute it and/or modify since
 *  you respect the terms of either (at least one of the both license) :
 *  - under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *  - the CeCILL-C as published by CeCILL-C; either version 1 of the
 *  License, or any later version
 *  
 *  There are special exceptions to the terms and conditions of the
 *  licenses as they are applied to this software. View the full text of
 *  the exception in file LICENSE.txt in the directory of this software
 *  distribution.
 *  
 *  Lilie is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  Licenses for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  and the CeCILL-C along with Lilie. If not, see :
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */

package org.lilie.services.eliot.tice

import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.lilie.services.eliot.tice.utils.PortailTagLibService

import org.lilie.services.eliot.tice.utils.EliotUrlProvider
import org.lilie.services.eliot.tice.annuaire.PorteurEnt

class PortailTagLib {

  static namespace = "et"
  PortailTagLibService portailTagLibService
  EliotUrlProvider eliotUrlProvider

  /**
   * Affiche le lien vers le manuel.
   *
   * @attr fonctionEnum REQUIRED la fonction pour laquelle on souhaite le manuel
   * @attr libelleLien le libelle à afficher
   * @attr noManuelFonction la fonction javascript à appeler si pas de manuel
   * @attr noManuelAlert le contenu de l'alerte si pas de manuel
   */
  def manuelLink = { attrs, body ->
    def lnkUrl = "#"
    def noManuelFonction = attrs.noManuelFonction
    def noManuelAlert = attrs.noManuelAlert ?: g.message(code: "manuels.introuvable")
    def attrClass = attrs.class
    if (attrs.fonctionEnum) {
      FonctionEnum fonctionEnum = attrs.fonctionEnum
      def url = portailTagLibService.findManuelDocumentUrlForFonction(fonctionEnum)
      if (url?.startsWith("http://")) {
        lnkUrl =  url
      } else if (url) {
        def code = request.getHeader("${eliotUrlProvider.requestHeaderPorteur}")
        def porteurEnt = PorteurEnt.findByCode(code, [cached: true])
        lnkUrl = eliotUrlProvider.getUrlServeur(porteurEnt)+ url
      }
    }
    if (lnkUrl == "#") {
      def functJS
      if (noManuelFonction) {
        functJS = noManuelFonction
      } else {
        functJS = "alert('${noManuelAlert}')"
      }
      out << '<a href="#" onclick="' << functJS << '"'
      if (attrClass) {
        out << ' class="' << attrClass << '"'
      }
      out << '>' << body() << '</a>'
    } else {
      out << '<a href="' << lnkUrl << '" target="_blank"'
      if (attrClass) {
        out << ' class="' << attrClass << '"'
      }
      out << '>' << body() << '</a>'
    }
  }

/**
 * Div container de toutes les pages de l'application.
 * Si les pages de de l'application sont encapsulées dans un iframe
 * permet de spécifier la taille du div
 *
 */
  def container = { attrs, body ->
    def inFrame = portailTagLibService.applicationInFrame
    out << "<div"
    def attrClass = attrs.class
    if (attrClass) {
      out << ' class="' << attrClass << '"'
    }
    if (inFrame) {
      def h = portailTagLibService.divHeight
      def w = portailTagLibService.divWidth
      out << ' style="height: ' << h << 'px; width: ' << w << 'px;overflow: auto;"'
    }
    out << '>' << body() << '</div>'
  }


}
