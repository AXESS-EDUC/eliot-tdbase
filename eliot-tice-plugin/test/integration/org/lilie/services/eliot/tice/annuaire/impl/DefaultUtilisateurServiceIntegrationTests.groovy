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

import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.annuaire.UtilisateurService
import org.lilie.services.eliot.tice.securite.DomainAutorite
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.securite.CompteUtilisateur

/**
 *  Test la classe DefaultUtilisateurService
 * @author franck silvestre
 */
class DefaultUtilisateurServiceIntegrationTests extends GroovyTestCase  {

  private static final String UTILISATEUR_1_LOGIN = "mary.dupond"
  private static final String UTILISATEUR_1_PASSWORD = "password"
  private static final String UTILISATEUR_1_NOM = "dupond"
  private static final String UTILISATEUR_1_PRENOM = "mary"
  private static final String NO_USER_LOGIN = "NO_USER_LOGIN"
  private static final String UTILISATEUR_1_LOGIN_ALIAS = "mary.d"


  UtilisateurService defaultUtilisateurService

  void testCreateUtilisateur() {

    Utilisateur utilisateur1 = defaultUtilisateurService.createUtilisateur(
           UTILISATEUR_1_LOGIN,
           UTILISATEUR_1_PASSWORD,
           UTILISATEUR_1_NOM,
           UTILISATEUR_1_PRENOM,
            null,
            new Date().parse("d/M/yyyy","21/3/1972")
    )

    assertNotNull("Création de l'utilisateur a échouée",utilisateur1)
    DomainAutorite domainAutorite = DomainAutorite.get(utilisateur1.autoriteId)
    assertNotNull("La création de l'autorité a échouée",domainAutorite)
    assertEquals("Le nom de l'entité n'est pas bon", "ent.personne", domainAutorite.nomEntiteCible)

    Personne personne = Personne.get(utilisateur1.personneId)
    assertNotNull("Personne non créée",personne)
    assertEquals("nom incorrect","dupond", personne.nom)

    CompteUtilisateur compteUtilisateur = CompteUtilisateur.get(utilisateur1.compteUtilisateurId)
    assertEquals("login incorrect", "mary.dupond",compteUtilisateur.login)
    assertTrue("compte non active",compteUtilisateur.compteActive)
    assertFalse("compte expire", compteUtilisateur.compteExpire)
    assertFalse("compte verrouille", compteUtilisateur.compteVerrouille)
    assertFalse("password expire",compteUtilisateur.passwordExpire)

  }


  void testFindUtilisateur() {
    Utilisateur utilisateur1 = defaultUtilisateurService.createUtilisateur(
            UTILISATEUR_1_LOGIN,
            UTILISATEUR_1_PASSWORD,
            UTILISATEUR_1_NOM,
            UTILISATEUR_1_PRENOM
    )

    def utilisateurNotFind = defaultUtilisateurService.findUtilisateur(NO_USER_LOGIN)
    assertNull(utilisateurNotFind)

    def utilisateur1Copie = defaultUtilisateurService.findUtilisateur(UTILISATEUR_1_LOGIN)
    assertNotNull(utilisateur1Copie)

    assertEquals(UTILISATEUR_1_NOM, utilisateur1Copie.nom)
    assertNotNull(utilisateur1Copie.autoriteId)
    assertEquals(UTILISATEUR_1_LOGIN, utilisateur1Copie.login)
    assertNull(utilisateur1Copie.loginAlias)

    defaultUtilisateurService.setAliasLogin(UTILISATEUR_1_LOGIN, UTILISATEUR_1_LOGIN_ALIAS)

    def utilisateur1Copie2 = defaultUtilisateurService.findUtilisateur(UTILISATEUR_1_LOGIN_ALIAS)
    assertNotNull(utilisateur1Copie2)

    assertEquals(UTILISATEUR_1_NOM, utilisateur1Copie2.nom)
    assertNotNull(utilisateur1Copie2.autoriteId)
    assertEquals(UTILISATEUR_1_LOGIN, utilisateur1Copie2.login)
    assertEquals(UTILISATEUR_1_LOGIN_ALIAS,utilisateur1Copie2.loginAlias)

  }

}
