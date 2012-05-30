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
import groovyx.net.http.AuthConfig

/**
 * Interface représentant une opération REST
 * @author franck Silvestre
 */
public interface RestOperation {

  /**
   * @return le nom de l'opération
   */
  String getOperationName()

  /**
   * @return la description de l'opération
   */
  String getDescription()

  /**
   * @return l'Url du serveur fournissant le service
   */
  String getUrlServer()


  /**
   * Fournit le format de l'Uri de la ressource sous la forme d'un template
   * Groovy
   * Exemple : /eliot-textes/api-rest/v2/cahiers/$cahierId/chapitres
   * Les éléments préfixés par '$' repésentent des paramètres encodés dans l'Uri
   * @return le format de l'Uri de la ressource demandée
   */
  String getUriTemplate()

  /**
   * Fournit le format du corps de la requête sous la forme d'un template Groovy
   * @return  le format du corps de la requête
   */
  String getRequestBodyTemplate()

  /**
   * @return la méthode Http utilisée par l'opération
   */
  Method getMethod()

  /**
   * @return le contenType utilisé par l'opération pour ses échanges
   */
  ContentType getContentType()

  /**
   * Fournit l'identifiant du format utilisé pour structurer le contenu de la
   * réponse.<br/>
   * Exemple : eliot-textes#chapitres#structure-chapitres
   * @return l'identifiant du format
   */
  String getResponseContentStructure()

  /**
   * Traitement à réaliser en cas d'obtention d'une réponse
   * @param response la réponse complète
   * @param bodyContent le contenu de la réponse
   */
  def onSucess(def response, def bodyContent)

  /**
   * Traitement à réaliser en cas d'obtention d'une erreur
   * @param error l'erreur obtenue
   */
  def onError(def error)

}