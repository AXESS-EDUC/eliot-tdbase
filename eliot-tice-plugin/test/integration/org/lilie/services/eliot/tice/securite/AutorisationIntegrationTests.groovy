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

import org.lilie.services.eliot.tice.securite.acl.DefaultPermissionsManager
import org.lilie.services.eliot.tice.securite.acl.DefaultAclSecuritySession
import org.lilie.services.eliot.tice.securite.acl.Autorisation
import org.lilie.services.eliot.tice.securite.acl.AclSecuritySession
import org.lilie.services.eliot.tice.securite.acl.TypeAutorite

/**
 *  Test la classe Item
 * @author franck silvestre
 */
class AutorisationIntegrationTests extends GroovyTestCase {


  AclSecuritySession session
  DomainItem projetB2I
  DomainAutorite autProp
  DomainAutorite aut

  DomainAutorisation autOnProjetB2I1
  DomainAutorisation autOnProjetB2I2


  protected void setUp() {
    super.setUp()

    session = new DefaultAclSecuritySession()

    autProp = new DomainAutorite(identifiant: "autProp", type: TypeAutorite.PERSONNE.libelle).save()
    aut = new DomainAutorite(identifiant: "aut", type: TypeAutorite.PERSONNE.libelle).save()

    session = new DefaultAclSecuritySession(defaultAutorite: autProp, autorites: [autProp])

    // initialise l'item
    projetB2I = new DomainItem(type: "PROJET")
    projetB2I.save()
    if (projetB2I.hasErrors()) log.error projetB2I.errors
  }

  protected void tearDown() {
    super.tearDown()
  }

  void testFindAllPersonneProprietaireAutorisations() {
    // on créé l'autorisation pour autoritePers1 1 , en le mettant proprietaire
    DomainAutorisation autorisationDefault = new DomainAutorisation(
            autorite: autProp,
            item: projetB2I,
            proprietaire: true
    )
    autorisationDefault.save()

    DefaultPermissionsManager permManager2 = new DefaultPermissionsManager(
            projetB2I, aut, session
    )
    permManager2.addPermissionConsultation()

    DomainItem item = DomainItem.get(projetB2I.id)
    List<Autorisation> autsProps = item.findAllPersonneProprietaireAutorisations()
    assertEquals autsProps.size(), 1
    Autorisation autPropFetched = autsProps.last()
    assertTrue autPropFetched.autoriteEstProprietaire()
  }


}
