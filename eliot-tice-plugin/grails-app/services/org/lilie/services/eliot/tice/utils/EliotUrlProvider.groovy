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

import org.apache.commons.validator.UrlValidator
import org.codehaus.groovy.grails.commons.ConfigurationHolder
import org.lilie.services.eliot.tice.annuaire.PorteurEnt

/**
 * Service de récupération des urls entre applications, prenant en compte
 * les urls de portail (par porteur)
 * @author jtra
 * @author franck silvestre
 */
class EliotUrlProvider {

  static transactional = false

  String requestHeaderPorteur
  String nomApplication
  UrlServeurResolutionEnum urlServeurResolutionEnum
  String urlServeurFromConfiguration



  /**
   * Retourne l'url serveur d'une application
   * @param porteurEnt le porteur ENT
   * @param application
   * @return
   */
  String getUrlServeur(PorteurEnt porteurEnt) {

    String url

    switch (urlServeurResolutionEnum) {
      case UrlServeurResolutionEnum.CONFIGURATION:
        url = urlServeurFromConfiguration
        break;
      case UrlServeurResolutionEnum.ANNUAIRE_PORTEUR:
        url = porteurEnt?.urlAccesEnt ?: ""
        break;
      default: throw new IllegalStateException("$urlServeurResolutionEnum n'est pas un mode géré")
    }

    // Suppression du dernier / s'il existe
    if (url.endsWith('/')) {
      return url[0..(url.size() - 2)]
    }

    return url
  }

}


