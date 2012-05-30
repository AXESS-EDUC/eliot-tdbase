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

package org.lilie.services.eliot.tice.webservices.rest.client

import groovyx.net.http.AuthConfig
import groovyx.net.http.ContentType
import groovyx.net.http.Method
import groovy.util.logging.Log

/**
 * Implementation d'une RestOperation générique avec propriétés
 * @author franck Silvestre
 */
@Log
class GenericRestOperation implements RestOperation {

  Long invocationCount = 0
  Long successCount = 0
  Long failureCount = 0

  String operationName
  String description
  String urlServer
  String uriTemplate
  String requestBodyTemplate
  Method method

  ContentType contentType
  String responseContentStructure

  def onSucess(def response,def bodyContent) {
    invocationCount++
    successCount++
    log.info(bodyContent.toString())
  }

  def onError(Object error) {
    invocationCount++
    failureCount++
    log.severe(error.toString())
  }
}
