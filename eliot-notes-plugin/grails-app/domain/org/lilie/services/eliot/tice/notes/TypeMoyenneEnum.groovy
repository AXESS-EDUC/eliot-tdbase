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

package org.lilie.services.eliot.tice.notes

/**
 * Types des moyennes
 * @author msan
 */
public enum TypeMoyenneEnum {
  
  ELEVE_ENSEIGNEMENT_PERIODE, // moyenne d'un élève pour une période et un enseignement
  ELEVE_SERVICE_PERIODE,      // moyenne d'un élève pour une période et un service
  ELEVE_SOUS_SERVICE_PERIODE, // moyenne d'un élève pour une période et un sous-service
  ELEVE_PERIODE,              // moyenne d'un elève pour une période sur tous les services
  CLASSE_ENSEIGNEMENT_PERIODE,// moyenne d'une classe pour uen période et un enseignement
  CLASSE_SERVICE_PERIODE,     // moyenne d'une classe pour une période et un service
  CLASSE_SOUS_SERVICE_PERIODE,// moyenne d'une classe pour une période et un sous-servuce
  CLASSE_PERIODE              // moyenne d'une classe pour une période sur tous les services

  String getId() {
    return this
  }
}