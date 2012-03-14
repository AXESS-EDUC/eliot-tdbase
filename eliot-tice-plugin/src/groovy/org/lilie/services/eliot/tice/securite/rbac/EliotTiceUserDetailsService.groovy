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

package org.lilie.services.eliot.tice.securite.rbac

import org.codehaus.groovy.grails.plugins.springsecurity.GrailsUserDetailsService
import org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils
import org.springframework.security.core.authority.GrantedAuthorityImpl
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.lilie.services.eliot.tice.annuaire.UtilisateurService
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.annuaire.RoleUtilisateurService

/**
 *
 * @author franck Silvestre
 */
class EliotTiceUserDetailsService implements GrailsUserDetailsService {

  UtilisateurService utilisateurService
  RoleUtilisateurService roleUtilisateurService

/**
 * Some Spring Security classes (e.g. RoleHierarchyVoter) expect at least one role, so
 * we give a user with no granted roles this one which gets past that restriction but
 * doesn't grant anything.
 */
  static final List NO_ROLES = [new GrantedAuthorityImpl(SpringSecurityUtils.NO_ROLE)]

  UserDetails loadUserByUsername(String username, boolean loadRoles)
  throws UsernameNotFoundException {
    return loadUserByUsername(username)
  }

  UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
    Utilisateur utilisateur = utilisateurService.findUtilisateur(username)
    if (utilisateur) {
      def roles = roleUtilisateurService.findRolesForUtilisateur(utilisateur) ?: NO_ROLES
      return new EliotTiceUser(utilisateur, roles)
    }
    return null
  }

}
