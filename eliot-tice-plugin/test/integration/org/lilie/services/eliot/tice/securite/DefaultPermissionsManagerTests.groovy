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

import org.lilie.services.eliot.tice.securite.acl.Permission
import org.lilie.services.eliot.tice.securite.acl.TypeAutorite
import org.lilie.services.eliot.tice.securite.acl.AutorisationException
import org.lilie.services.eliot.tice.securite.acl.DefaultAclSecuritySession
import org.lilie.services.eliot.tice.securite.acl.DefaultPermissionsManager
import org.lilie.services.eliot.tice.securite.acl.AclSecuritySession


class DefaultPermissionsManagerTests extends GroovyTestCase {

  AclSecuritySession session
  DomainAutorite tousLesProfs
  DomainAutorite autorite1
  DomainItem projetB2I
  DomainAutorisation autOnProjetB2IForTousLesProfs
  DomainAutorisation autOnProjetB2IForActeur1

  DefaultPermissionsManager permissionsManager

  protected void setUp() {
    super.setUp()
    // initialise la session

    autorite1 = new DomainAutorite(identifiant: "TEST_prof1", type: TypeAutorite.GROUPE_PERSONNE.libelle).save()
    session = new DefaultAclSecuritySession(defaultAutorite: autorite1, autorites: [autorite1, tousLesProfs])
    // intialise l'autorite
    tousLesProfs = new DomainAutorite(identifiant: "TEST_tousLesProfs", type: TypeAutorite.GROUPE_PERSONNE.libelle).save()

    // initialise l'item
    projetB2I = new DomainItem(type: "PROJET")
    projetB2I.save()
    if (projetB2I.hasErrors()) println projetB2I.errors.toString()


  }

  protected void tearDown() {
    super.tearDown()
  }

  void testCreateDefaultPermissionsManager() {
    try {
      permissionsManager = new DefaultPermissionsManager(
              projetB2I, tousLesProfs, session
      )
    } catch (AutorisationException e) {
      println e.toString()
    }
    // la creation doit echouer faute d'autorisation de acteur 1
    assertNull permissionsManager

    // on créé l'autorisation pour acteur 1
    int val = Permission.PEUT_CONSULTER_PERMISSIONS | Permission.PEUT_MODIFIER_PERMISSIONS
    autOnProjetB2IForActeur1 = new DomainAutorisation(
            autorite: session.getDefaultAutorite(),
            item: projetB2I,
            valeurPermissionsExplicite: val
    )
    autOnProjetB2IForActeur1.save()
    if (autOnProjetB2IForActeur1.hasErrors()) println autOnProjetB2IForActeur1.errors.toString()


    println "liste des autorisations (type ${session.findAutorisationsOnItem(projetB2I).getClass()} : ${session.findAutorisationsOnItem(projetB2I)}"

    try {
      permissionsManager = new DefaultPermissionsManager(
              projetB2I, tousLesProfs, session
      )
    } catch (AutorisationException e) {
      println e.toString()
    }

    // la création doit à présent réussir
    assertNotNull permissionsManager
  }

  void testAddPermissionModificationSansPermInitiales() {
    // preparation du permission manager
    int val = Permission.PEUT_CONSULTER_PERMISSIONS | Permission.PEUT_MODIFIER_PERMISSIONS
    autOnProjetB2IForActeur1 = new DomainAutorisation(
            autorite: session.getDefaultAutorite(),
            item: projetB2I,
            valeurPermissionsExplicite: val
    )
    autOnProjetB2IForActeur1.save()
    if (autOnProjetB2IForActeur1.hasErrors()) println autOnProjetB2IForActeur1.errors.toString()


    println "liste des autorisations : ${session.findAutorisationsOnItem(projetB2I)}"

    try {
      permissionsManager = new DefaultPermissionsManager(
              projetB2I, tousLesProfs, session
      )
    } catch (AutorisationException e) {
      println e.toString()
    }

    // test
    permissionsManager.addPermissionModification()

    DomainAutorisation autB2IProfsRecherchee = DomainAutorisation.findByItemAndAutorite(projetB2I, tousLesProfs)

    assertTrue autB2IProfsRecherchee.autoriseModifierLeContenu()

  }

  void testAddPermissionModificationAvecPermInitiales() {
    // initilialise autoritsation sur tous les profs
    int val = Permission.PEUT_CONSULTER_CONTENU
    autOnProjetB2IForTousLesProfs = new DomainAutorisation(autorite: tousLesProfs, item: projetB2I, valeurPermissionsExplicite: val)
    autOnProjetB2IForTousLesProfs.save()
    if (autOnProjetB2IForTousLesProfs.hasErrors()) println(autOnProjetB2IForTousLesProfs.errors.toString())
    // preparation du permission manager
    val = Permission.PEUT_CONSULTER_PERMISSIONS | Permission.PEUT_MODIFIER_PERMISSIONS
    autOnProjetB2IForActeur1 = new DomainAutorisation(
            autorite: session.getDefaultAutorite(),
            item: projetB2I,
            valeurPermissionsExplicite: val
    )
    autOnProjetB2IForActeur1.save()
    if (autOnProjetB2IForActeur1.hasErrors()) println autOnProjetB2IForActeur1.errors.toString()


    println "liste des autorisations : ${session.findAutorisationsOnItem(projetB2I)}"

    try {
      permissionsManager = new DefaultPermissionsManager(
              projetB2I, tousLesProfs, session
      )
    } catch (AutorisationException e) {
      println e.toString()
    }

    // test
    permissionsManager.addPermissionModification()
    permissionsManager.addPermissionConsultationPermissions()

    DomainAutorisation autB2IProfsRecherchee = DomainAutorisation.findByItemAndAutorite(projetB2I, tousLesProfs)

    assertTrue autB2IProfsRecherchee.autoriseModifierLeContenu()
    assertTrue autB2IProfsRecherchee.autoriseConsulterLesPermissions()

  }


  void testDeletePermissionConsultation() {
    // initilialise autoritsation sur tous les profs
    int val = Permission.PEUT_CONSULTER_CONTENU | Permission.PEUT_MODIFIER_CONTENU
    autOnProjetB2IForTousLesProfs = new DomainAutorisation(autorite: tousLesProfs, item: projetB2I, valeurPermissionsExplicite: val)
    autOnProjetB2IForTousLesProfs.save()
    if (autOnProjetB2IForTousLesProfs.hasErrors()) println(autOnProjetB2IForTousLesProfs.errors.toString())
    // preparation du permission manager
    val = Permission.PEUT_CONSULTER_PERMISSIONS | Permission.PEUT_MODIFIER_PERMISSIONS
    autOnProjetB2IForActeur1 = new DomainAutorisation(
            autorite: session.getDefaultAutorite(),
            item: projetB2I,
            valeurPermissionsExplicite: val
    )
    autOnProjetB2IForActeur1.save()
    if (autOnProjetB2IForActeur1.hasErrors()) println autOnProjetB2IForActeur1.errors.toString()


    println "liste des autorisations : ${session.findAutorisationsOnItem(projetB2I)}"

    try {
      permissionsManager = new DefaultPermissionsManager(
              projetB2I, tousLesProfs, session
      )
    } catch (AutorisationException e) {
      println e.toString()
    }

    // test
    permissionsManager.deletePermissionConsultation()

    DomainAutorisation autB2IProfsRecherchee = DomainAutorisation.findByItemAndAutorite(projetB2I, tousLesProfs)

    assertNull autB2IProfsRecherchee

  }


}
