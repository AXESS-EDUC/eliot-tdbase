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

import groovy.json.JsonSlurper
import groovy.text.SimpleTemplateEngine
import groovy.util.logging.Log4j
import groovyx.net.http.ContentType
import groovyx.net.http.HTTPBuilder

/**
 * Classe représentant un client de webservices Rest pour une opération
 * disponible dans l'annuaire des opérations
 * @author franck Silvestre
 */
@Log4j
class RestClient {

  String authBasicUser
  String authBasicPassword
  String urlServer
  String uriPrefix
  RestOperationDirectory restOperationDirectory
  Integer connexionTimeout = 15000 // ms

  /**
   * Invoque une opération identifiée par son nom.
   * L'invocation prend en compte l'authentification basique si elle a été
   * configurée, le timeout de connexion et la gestion d'erreur
   * @param operationName le nom de l'opération à déclencher
   * @param parameters les paramètres encodées dans l'URL
   * @param httpParameters les paramètres http
   * @param requestContentParameters les paramètres encodés dans le corps de la
   * requête
   * @return le résultat de l'opération
   */
  def invokeOperation(String operationName,
                      Map parameters,
                      Map httpParameters,
                      Map requestContentParameters = null)
  throws RestOperationDoesNotExistsInDirectoryException {

    def operation = restOperationDirectory.getOperationByName(operationName)
    if (!operation) {
      throw new RestOperationDoesNotExistsInDirectoryException()
    }
    def bodyContent = null
    def result = null
    def url = operation.urlServer ?: urlServer
    def http = new HTTPBuilder(url)
    if (authBasicUser && authBasicPassword) {
      //http.auth.basic authBasicUser, authBasicPassword
      http.headers['Authorization'] =
        "$authBasicUser:$authBasicPassword".getBytes().encodeBase64()
    }

    try {
      http.request(operation.method, operation.contentType) {  req ->
        // Timeout de  connexion
        req.getParams().setParameter("http.connection.timeout", connexionTimeout);
        req.getParams().setParameter("http.socket.timeout", connexionTimeout);
        log.debug("Connexion timeout : ${connexionTimeout} ms")
        def uriPref = uriPrefix ?: ""
        uri = url + uriPref + getUrlPath(operation.uriTemplate, parameters, httpParameters)
        log.debug("uri : ${uri}")
        if (operation.requestBodyTemplate) {
          bodyContent = getBody(operation.requestBodyTemplate, requestContentParameters)
          body = bodyContent
          log.debug(("body : ${bodyContent}"))
        }
        response.success = { resp, contentResp ->
          operation.onSucess(resp, contentResp)
          if (operation.contentType == ContentType.JSON) {
            def slurper = new JsonSlurper()
            result = slurper.parseText(contentResp.toString())
          } else {
            result = contentResp
          }
        }
        response.failure = { resp ->
          log.error("Unexpected error: ${resp.statusLine.statusCode} : ${resp.statusLine.reasonPhrase} : ${uri}")
          log.error("Body : \n ${bodyContent}")
        }
      }
    } catch (Exception e) {
      log.error(e.message, e)
    }
    result
  }

  private String getUrlPath(String uriTemplate, Map parameters, Map httpParameters) {
    // resoud le template
    def engine = new SimpleTemplateEngine()
    def template = engine.createTemplate(uriTemplate)
    def urlPath = template.make(parameters).toString()
    // resoud les parametres http
    if (httpParameters) {
      def strB = new StringBuilder()
      strB << '?'
      httpParameters.each { key, val ->
        strB << key << '=' << val.encodeAsURL() << '&'
      }
      strB.deleteCharAt(strB.length() - 1)
      urlPath += strB.toString()
    }
    urlPath
  }


  private String getBody(String bodyTemplate, Map parameters) {
    // resoud le template
    def engine = new SimpleTemplateEngine()
    def template = engine.createTemplate(bodyTemplate)
    template.make(parameters).toString()
  }

}