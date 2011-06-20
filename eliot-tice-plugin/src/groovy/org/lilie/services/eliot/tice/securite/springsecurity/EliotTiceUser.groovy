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

package org.lilie.services.eliot.tice.securite.springsecurity

import org.codehaus.groovy.grails.plugins.springsecurity.GrailsUser
import org.springframework.security.core.GrantedAuthority

/**
 * Classe représentant l'objet de type UserDetail nécessaire à SpringSecurity
 * pour créer un Security Context
 * @author franck Silvestre
 */
class EliotTiceUser extends GrailsUser {

  /**
   *
   * @param username l'identifiant unique (chaine de caractère)
   * @param password le mot de passe
   * @param enabled flag indiquant si l'utilisateur est activé
   * @param accountNonExpired  flag indiquant si
   * @param credentialsNonExpired  flag indiquant si
   * @param accountNonLocked  flag indiquant si
   * @param authorities liste des objets de type GrantedAuthorities correspondant
   *        aux fonctions de l'utilisateur connecté
   * @param id l'id de l'utilisateur
   */
  EliotTiceUser(
          String username,
          String password,
          boolean enabled,
          boolean accountNonExpired,
          boolean credentialsNonExpired,
          boolean accountNonLocked,
          Collection<GrantedAuthority> authorities,
          Object id
  ) {
    super(
            username,
            password,
            enabled,
            accountNonExpired,
            credentialsNonExpired,
            accountNonLocked,
            authorities,
            id)
  }
}
