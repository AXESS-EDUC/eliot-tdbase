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

package org.lilie.services.eliot.tice.annuaire.data

import groovy.transform.ToString
import groovy.transform.EqualsAndHashCode
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.securite.CompteUtilisateur
import org.lilie.services.eliot.tice.securite.DomainAutorite

/**
 * Classe représentant un utilisateur
 * @author franck Silvestre
 */
@ToString(includeNames = true, includeFields = true)
@EqualsAndHashCode(excludes = 'compteUtilisateurId dateDerniereConnexion compteActive compteExpire compteVerrouille passwordExpire')
class Utilisateur {

  // information compte utilisateur

  String login
  String loginAlias
  String password
  Date dateDerniereConnexion
  boolean compteActive
  boolean compteExpire
  boolean compteVerrouille
  boolean passwordExpire

  Long compteUtilisateurId

  // information personne

  String nom
  String prenom
  Date dateNaissance
  String email
  String sexe

  Long personneId

  // information autorite
  Long autoriteId

  /**
   *
   * @return la personne correspondante à l'utilisateur
   */
  Personne getPersonne() {
    return Personne.get(personneId)
  }

  /**
   *
   * @return le compte utilisateur correspondant à l'utilisateur
   */
  CompteUtilisateur getCompteUtilisateur() {
    return CompteUtilisateur.get(compteUtilisateurId)
  }

  /**
   *
   * @return l'autorité correspondant à l'utilisateur
   */
  DomainAutorite getAutorite() {
    return DomainAutorite.get(autoriteId)
  }

}
