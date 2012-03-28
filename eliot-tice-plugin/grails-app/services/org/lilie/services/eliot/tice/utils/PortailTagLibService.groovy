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

package org.lilie.services.eliot.tice.utils

import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.codenarc.rule.basic.IntegerGetIntegerAstVisitor

class PortailTagLibService {

  private manuelDocumentsUrl = [:]

  Boolean applicationInFrame
  Integer divHeight
  Integer divWidth

  static transactional = false

  /**
   * Ajoute une URL de manuel pour une fonction utilisateur donné
   * @param url l'url du document
   * @param fonctionEnum la fonction de l'utilisateur
   */
  def addManuelDocumentUrlForFonction(String url, FonctionEnum fonctionEnum) {
    manuelDocumentsUrl.put(fonctionEnum,url)
  }

  /**
   * Récupère, si il existe, le manuel correspondant à une fonction utilisateur
   * @param fonctionEnum la fonction utilisateur
   * @return l'Url du manuel correspondant ou null
   */
  String findManuelDocumentUrlForFonction(FonctionEnum fonctionEnum) {
    return manuelDocumentsUrl[fonctionEnum]
  }

  /**
   * Ajoute un lots d'urls de  manuels
   * @param urlMap la map d'Url où les clés sont les noms de fonctions et les
   * valeurs les urls des manuels correspondant
   */
  def addManuelDocumentUrls(Map urlMap) {
    urlMap.keySet().each {
      def fonctionEnum = FonctionEnum.valueOf(it)
      addManuelDocumentUrlForFonction(urlMap.get(it), fonctionEnum)
    }
  }
  

}
