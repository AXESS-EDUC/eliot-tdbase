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

import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.UtilisateurService
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.securite.CompteUtilisateur
import org.lilie.services.eliot.tice.securite.DomainAutorite
import org.hibernate.SessionFactory
import org.hibernate.stat.Statistics

/**
 *  Test la classe DefaultUtilisateurService
 * @author franck silvestre
 */
class DefaultUtilisateurServiceIntegrationTests extends GroovyTestCase {

  private static final String UTILISATEUR_1_LOGIN = "mary.dupond"
  private static final String UTILISATEUR_1_PASSWORD = "password"
  private static final String UTILISATEUR_1_NOM = "dupond"
  private static final String UTILISATEUR_1_PRENOM = "mary"
  private static final String NO_USER_LOGIN = "NO_USER_LOGIN"
  private static final String UTILISATEUR_1_LOGIN_ALIAS = "mary.d"

  private static final String UTILISATEUR_2_LOGIN = "paul.dupond"
  private static final String UTILISATEUR_2_PASSWORD = "password2"
  private static final String UTILISATEUR_2_NOM = "dupond"
  private static final String UTILISATEUR_2_PRENOM = "paul"



  UtilisateurService defaultUtilisateurService
  SessionFactory sessionFactory
  Statistics statistics


  void testCreateUtilisateur() {

    Utilisateur utilisateur1 = defaultUtilisateurService.createUtilisateur(
            UTILISATEUR_1_LOGIN,
            UTILISATEUR_1_PASSWORD,
            UTILISATEUR_1_NOM,
            UTILISATEUR_1_PRENOM,
            null,
            new Date().parse("d/M/yyyy", "21/3/1972")
    )

    assertNotNull("Création de l'utilisateur a échouée", utilisateur1)
    DomainAutorite domainAutorite = DomainAutorite.get(utilisateur1.autoriteId)
    assertNotNull("La création de l'autorité a échouée", domainAutorite)
    assertEquals("Le nom de l'entité n'est pas bon", "ent.personne", domainAutorite.nomEntiteCible)

    Personne personne = Personne.get(utilisateur1.personneId)
    assertNotNull("Personne non créée", personne)
    assertEquals("nom incorrect", "dupond", personne.nom)

    CompteUtilisateur compteUtilisateur = CompteUtilisateur.get(utilisateur1.compteUtilisateurId)
    assertEquals("login incorrect", "mary.dupond", compteUtilisateur.login)
    assertTrue("compte non active", compteUtilisateur.compteActive)
    assertFalse("compte expire", compteUtilisateur.compteExpire)
    assertFalse("compte verrouille", compteUtilisateur.compteVerrouille)
    assertFalse("password expire", compteUtilisateur.passwordExpire)

  }


  void testFindUtilisateur() {


    assertNull(defaultUtilisateurService.findUtilisateur(""))


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
    assertEquals(UTILISATEUR_1_LOGIN_ALIAS, utilisateur1Copie2.loginAlias)

  }

  void testSetLoginAlias() {
    Utilisateur utilisateur1 = defaultUtilisateurService.createUtilisateur(
            UTILISATEUR_1_LOGIN,
            UTILISATEUR_1_PASSWORD,
            UTILISATEUR_1_NOM,
            UTILISATEUR_1_PRENOM
    )

    Utilisateur utilisateur2 = defaultUtilisateurService.createUtilisateur(
            UTILISATEUR_2_LOGIN,
            UTILISATEUR_2_PASSWORD,
            UTILISATEUR_2_NOM,
            UTILISATEUR_2_PRENOM
    )

    defaultUtilisateurService.setAliasLogin(UTILISATEUR_1_LOGIN, UTILISATEUR_1_LOGIN_ALIAS)
    def utilisateur1Copie = defaultUtilisateurService.findUtilisateur(UTILISATEUR_1_LOGIN)
    assertNotNull(utilisateur1Copie)
    assertEquals(UTILISATEUR_1_LOGIN_ALIAS, utilisateur1Copie.loginAlias)

    shouldFail {
      defaultUtilisateurService.setAliasLogin(UTILISATEUR_2_LOGIN, UTILISATEUR_1_LOGIN_ALIAS)
    }

    shouldFail {
      defaultUtilisateurService.setAliasLogin(UTILISATEUR_2_LOGIN, UTILISATEUR_1_LOGIN)
    }
  }

  void testDesactiveUtilisateur() {
    Utilisateur utilisateur1 = defaultUtilisateurService.createUtilisateur(
            UTILISATEUR_1_LOGIN,
            UTILISATEUR_1_PASSWORD,
            UTILISATEUR_1_NOM,
            UTILISATEUR_1_PRENOM
    )
    assertTrue(utilisateur1.compteActive)

    utilisateur1 = defaultUtilisateurService.desactiveUtilisateur(UTILISATEUR_1_LOGIN)
    assertFalse(utilisateur1.compteActive)

    def copieUtilisateur1 = defaultUtilisateurService.findUtilisateur(UTILISATEUR_1_LOGIN)
    assertFalse(copieUtilisateur1.compteActive)
  }

  void testReactiveUtilisateur() {
    Utilisateur utilisateur1 = defaultUtilisateurService.createUtilisateur(
            UTILISATEUR_1_LOGIN,
            UTILISATEUR_1_PASSWORD,
            UTILISATEUR_1_NOM,
            UTILISATEUR_1_PRENOM
    )
    assertTrue(utilisateur1.compteActive)

    utilisateur1 = defaultUtilisateurService.desactiveUtilisateur(UTILISATEUR_1_LOGIN)
    assertFalse(utilisateur1.compteActive)

    utilisateur1 = defaultUtilisateurService.reactiveUtilisateur(UTILISATEUR_1_LOGIN)
    assertTrue(utilisateur1.compteActive)

    def copieUtilisateur1 = defaultUtilisateurService.findUtilisateur(UTILISATEUR_1_LOGIN)
    assertTrue(copieUtilisateur1.compteActive)
  }

  void testUpdateUtilisateur() {
    Utilisateur utilisateur1 = defaultUtilisateurService.createUtilisateur(
            UTILISATEUR_1_LOGIN,
            UTILISATEUR_1_PASSWORD,
            UTILISATEUR_1_NOM,
            UTILISATEUR_1_PRENOM
    )

    utilisateur1.nom = UTILISATEUR_2_NOM
    utilisateur1.email = "aaa@bbb.com"
    utilisateur1.dateNaissance = new Date().parse("d/M/yyyy", "21/3/1972")

    Utilisateur copieUtilisateur1 = defaultUtilisateurService.updateUtilisateur(
            UTILISATEUR_1_LOGIN, utilisateur1)

    assertNotNull(copieUtilisateur1.email)
    assertNotNull(copieUtilisateur1.dateNaissance)
    assertEquals(UTILISATEUR_2_NOM, copieUtilisateur1.nom)

  }

  void testFindUtilisateurs() {
    Utilisateur utilisateur1 = defaultUtilisateurService.createUtilisateur(
            "log1",
            "password1",
            "a_Aeàè",
            "Zoé",
            null,
            new Date().parse("d/M/yyyy", "21/3/1972")
    )
    Utilisateur utilisateur2 = defaultUtilisateurService.createUtilisateur(
            "log2",
            "password2",
            "b_Aebb",
            "Zou",
            null,
            new Date().parse("d/M/yyyy", "21/3/1982")
    )
    Utilisateur utilisateur3 = defaultUtilisateurService.createUtilisateur(
            "log3",
            "password3",
            "c_Ëolien",
            "VENTOUX",
            null,
            new Date().parse("d/M/yyyy", "21/3/1992")
    )
    Utilisateur utilisateur4 = defaultUtilisateurService.createUtilisateur(
            "log4",
            "password4",
            "d_Cîrconflêxe",
            "ÀGRAVE",
            null,
            new Date().parse("d/M/yyyy", "21/3/2002")
    )

    // test récup complète
    def allUtilisateurs = defaultUtilisateurService.findUtilisateurs(
            null, null, null, null)

    assertEquals(4, allUtilisateurs.size())

    // test pagination et sort ordering
    allUtilisateurs = defaultUtilisateurService.findUtilisateurs(
            null, null, null, null, [max: 2, offset: 2, sort: 'nom', order: 'desc'])


    assertEquals(2, allUtilisateurs.size())
    assertEquals utilisateur2, allUtilisateurs.get(0)
    assertEquals utilisateur1, allUtilisateurs.get(1)

    // test la normalisation
    allUtilisateurs = defaultUtilisateurService.findUtilisateurs(
            "eol", null, null, null)
    // log.info(allUtilisateurs.toListString())
    assertEquals(1, allUtilisateurs.size())
    assertEquals(utilisateur3, allUtilisateurs.last())

    allUtilisateurs = defaultUtilisateurService.findUtilisateurs(
            "ae", null, null, null)
    //log.info(allUtilisateurs.toListString())
    assertEquals(2, allUtilisateurs.size())
    assertEquals(utilisateur2, allUtilisateurs.last())

    allUtilisateurs = defaultUtilisateurService.findUtilisateurs(
            "cir", "ag", null, null)
    // log.info(allUtilisateurs.toListString())
    assertEquals(1, allUtilisateurs.size())
    assertEquals(utilisateur4, allUtilisateurs.last())

    // test dates
    allUtilisateurs = defaultUtilisateurService.findUtilisateurs(
            null, null, new Date().parse("d/M/yyyy", "21/3/1973"), null)
    // log.info(allUtilisateurs.toListString())
    assertEquals(3, allUtilisateurs.size())
    assertEquals(utilisateur4, allUtilisateurs.last())

    // test dates
    allUtilisateurs = defaultUtilisateurService.findUtilisateurs(
            null, null, null, new Date().parse("d/M/yyyy", "21/3/2001"))
    // log.info(allUtilisateurs.toListString())
    assertEquals(3, allUtilisateurs.size())
    assertEquals(utilisateur3, allUtilisateurs.last())

    allUtilisateurs = defaultUtilisateurService.findUtilisateurs(
            null, null,
            new Date().parse("d/M/yyyy", "21/3/1973"),
            new Date().parse("d/M/yyyy", "21/3/2001"))
    // log.info(allUtilisateurs.toListString())
    assertEquals(2, allUtilisateurs.size())
    assertEquals(utilisateur2, allUtilisateurs.first())

  }


}
