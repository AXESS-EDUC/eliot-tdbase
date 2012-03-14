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

package org.lilie.services.eliot.tice.securite

import org.lilie.services.eliot.tice.securite.acl.AccessManager
import org.lilie.services.eliot.tice.securite.acl.DefaultAclSecuritySession
import org.lilie.services.eliot.tice.securite.acl.AclSecuritySession
import org.lilie.services.eliot.tice.securite.acl.TypeAutorite
import org.lilie.services.eliot.tice.securite.acl.Permission


class AccessManagerTests extends GroovyTestCase {

  AclSecuritySession session
  DomainItem projetB2I
  DomainAutorisation autorisationOnProjetB2I
  DomainAutorite autoritePers1

  protected void setUp() {
    super.setUp()

    autoritePers1 = new DomainAutorite(type: TypeAutorite.PERSONNE.libelle, identifiant: "PERS 1").save()
    session = new DefaultAclSecuritySession(defaultAutorite: autoritePers1, autorites: [autoritePers1])
    // initialise l'item
    projetB2I = new DomainItem(type: "PROJET")
    projetB2I.save()
    if (projetB2I.hasErrors()) log.error projetB2I.errors
  }

  protected void tearDown() {
    super.tearDown()
  }

  void testPeutModifierLeContenu() {
    // on créé l'autorisation pour l'autoritePers1
    int val = Permission.PEUT_CONSULTER_CONTENU | Permission.PEUT_MODIFIER_CONTENU
    autorisationOnProjetB2I = new DomainAutorisation(
            autorite: session.getDefaultAutorite(),
            item: projetB2I,
            valeurPermissionsExplicite: val
    )
    autorisationOnProjetB2I.save()
    if (autorisationOnProjetB2I.hasErrors()) log.error autorisationOnProjetB2I.errors

    // création de l'access manager
    AccessManager accessManager = new AccessManager(projetB2I, session)

    assertTrue accessManager.peutConsulterLeContenu()
    assertTrue accessManager.peutModifierLeContenu()


  }

  void testPeutModifierLesPermissions() {
    // on créé l'autorisation pour l'autorité , en le mettant proprietaire
    autorisationOnProjetB2I = new DomainAutorisation(
            autorite: session.getDefaultAutorite(),
            item: projetB2I,
            proprietaire: true
    )
    autorisationOnProjetB2I.save()
    if (autorisationOnProjetB2I.hasErrors()) log.error autorisationOnProjetB2I.errors

    // création de l'access manager
    AccessManager accessManager = new AccessManager(projetB2I, session)

    assertTrue accessManager.peutConsulterLeContenu()
    assertTrue accessManager.peutModifierLesPermissions()


  }
}
