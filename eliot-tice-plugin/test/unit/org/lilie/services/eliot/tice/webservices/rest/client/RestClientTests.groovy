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

import groovyx.net.http.ContentType
import groovyx.net.http.Method
import org.vertx.groovy.core.Vertx



class RestClientTests extends GroovyTestCase {

  RestOperationDirectory restOperationDirectory = new RestOperationDirectory()
  RestClient restClient = new RestClient(restOperationDirectory: restOperationDirectory)
  def httpserver
  def port = 8796

  void setUp() {
    def vertx = Vertx.newVertx()
    httpserver = vertx.createHttpServer()
    httpserver.requestHandler { req ->
      def rep = req.response
      rep.putHeader("Content-Type","application/json").end('{"cahierId":1}')
    }.listen(port)
  }

  void tearDown() {
    httpserver.close()
  }


  void testRestClientInvokeOperation() {
    RestOperation restOperation = new GenericRestOperation(contentType: ContentType.JSON,
                                                           description: "test de http://localhost:8090/eliot-test-webservices/echanges/v2/cahiers/1/chapitres",
                                                           operationName: "op1",
                                                           method: Method.GET,
                                                           requestBodyTemplate: null,
                                                           responseContentStructure: "eliot-textes#chapitres#structure-chapitres",
                                                           urlServer: "http://localhost:$port",
                                                           uriTemplate: '/eliot-test-webservices/echanges/v2/cahiers/$cahierId/chapitres')
    restOperationDirectory.addOperation(restOperation)
    def resp = restClient.invokeOperation("op1",
                                          [cahierId: 1],
                                          null)
    assert restOperation.invocationCount == 1
    assert restOperation.successCount == 1
    assertNotNull(resp)
    println("Reponse : ${resp.toString()}")
  }
}