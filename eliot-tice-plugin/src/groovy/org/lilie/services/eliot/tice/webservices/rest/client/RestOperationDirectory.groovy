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

import groovy.util.logging.Log4j

/**
 * Classe représentant un annuaire d'opérations
 * @author franck Silvestre
 */
@Log4j
class RestOperationDirectory {

  private Map operations = [:]

  /**
   * Ajoute une opération à l'annuaire
   * @param operation l'opération à ajouter à l'annuaire
   * @return
   */
  def addOperation(RestOperation operation) {
    if (operation) {
      operations.put(operation.getOperationName(), operation)
    }
  }

  /**
   * Récupère une opération par son nom
   * @param operationName le nom de l'opération recherchée
   * @return l'opération recherchée ou null si elle n'existe pas
   */
  RestOperation getOperationByName(String operationName) {
    return operations.get(operationName)
  }

  /**
   * Supprime une opération de l'annuaire
   * @param operationName le nom de l'opération
   */
  def removeOperation(String operationName) {
    def operation = getOperationByName(operationName)
    if (operation) {
      operations.remove(operation)
    }
  }

  /**
   * @return le nombre d'opérations enregistrées
   */
  def operationCount() {
    return operations.size()
  }

  /**
   * @return la listes des noms d'opération enregistrées
   */
  Set<String> getOperationNames() {
    return operations.keySet()
  }

  /**
   * Enregistre les opérations de webservices rest
   * @param operations la liste des opérations sous forme de map
   */
  def registerOperationsFromMaps(List<Map> operations) {
    log.info("REST enregistrement de ${operations.size()} operations...")
    operations.each { Map operationMap ->
      RestOperation operation = new GenericRestOperation(operationMap)
      addOperation(operation)
      log.info("Enregistrement operation : ${operation.operationName}")
    }
    log.info("REST Operations enregistrees: ${operationCount()}")
  }
}
