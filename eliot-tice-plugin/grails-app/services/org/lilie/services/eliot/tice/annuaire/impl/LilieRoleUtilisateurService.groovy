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



package org.lilie.services.eliot.tice.annuaire.impl

import org.lilie.services.eliot.tice.annuaire.RoleUtilisateurService
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.springframework.security.core.GrantedAuthority
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService
import org.springframework.security.core.authority.GrantedAuthorityImpl

/**
 *
 * @author franck Silvestre
 */
class LilieRoleUtilisateurService implements RoleUtilisateurService {

  public static final String ROLE_EN_ACTIVITE = "ROLE_EN_ACTIVITE"
  ProfilScolariteService profilScolariteService

  /**
   *
   * @see org.lilie.services.eliot.tice.annuaire.RoleUtilisateurService
   */
  List<GrantedAuthority> findRolesForUtilisateur(Utilisateur utilisateur) {
    String login = utilisateur.login
    def roles = []
    def iterator = RoleFromLoginPrefix.values().iterator()
    while (iterator.hasNext()) {
      RoleFromLoginPrefix roleFromLoginPrefix = iterator.next()
      if (login.startsWith(roleFromLoginPrefix.prefix)) {
        roles << roleFromLoginPrefix
        break
      }
    }
    roles += profilScolariteService.findFonctionsForPersonne(utilisateur.personne)
    if (utilisateur.autorite.estActive) {
      roles += new GrantedAuthorityImpl(ROLE_EN_ACTIVITE)
    }
    return roles
  }

}

/**
 * Représente un rôle déduit du préfixe du login renvoyé par CAS
 */
enum RoleFromLoginPrefix implements GrantedAuthority {
  // le CAS retourne UTnnnnnnn ALnnnnnnnn ...
  // Extrait code CAS de Lilie
  //  public static final String TYPE_UTILISATEUR_NORMAL = "UT";
  //      /** Type de l'utilisateur connecté : administrateur local */
  //      public static final String TYPE_UTILISATEUR_ADMIN_LOCAL = "AL";
  //      /** Type de l'utilisateur connecté : administrateur de la console d'admin */
  //      public static final String TYPE_UTILISATEUR_ADMIN_CONSOLE_ADMIN = "SA";
  //      /** Type de l'utilisateur connecté : administrateur de la console d'admin */
  //      public static final String TYPE_UTILISATEUR_CORRESPONDANT = "CD";


  ADMIN_LOCAL("AL"),
  CORRESPONDANT_DEPLOIEMENT("CD")

  private String prefix

  private RoleFromLoginPrefix(String prefix) {
    this.prefix = prefix
  }

  String getAuthority() {
    return this.name()
  }

  String getPrefix() {
    return prefix
  }
}