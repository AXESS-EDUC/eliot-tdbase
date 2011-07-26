package org.lilie.services.eliot.tdbase

import org.hibernate.SessionFactory
import org.lilie.services.eliot.tdbase.misc.TdBaseInitialisationTestService
import org.lilie.services.eliot.tice.CopyrightsType
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur

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

/**
 *
 * @author franck Silvestre
 */
class SujetServiceIntegrationTests extends GroovyTestCase {

  private static final String SUJET_1_TITRE = "Sujet test 1"
  private static final String SUJET_2_TITRE = "Sujet test 2"

  Utilisateur utilisateur1
  Personne personne1
  Utilisateur utilisateur2
  Personne personne2
  SessionFactory sessionFactory

  TdBaseInitialisationTestService tdBaseInitialisationTestService
  SujetService sujetService

  protected void setUp() {
    super.setUp()
    utilisateur1 = tdBaseInitialisationTestService.getUtilisateur1()
    personne1 = utilisateur1.personne
    utilisateur2 = tdBaseInitialisationTestService.getUtilisateur2()
    personne2 = utilisateur2.personne
  }

  protected void tearDown() {
    super.tearDown()
  }

  void testCreateSujet() {

    Sujet sujet = sujetService.createSujet(personne1, SUJET_1_TITRE)
    assertNotNull(sujet)
    if (sujet.hasErrors()) {
      log.severe("${sujet.errors}")
    }
    assertFalse(sujet.hasErrors())

    assertEquals(personne1, sujet.proprietaire)
    assertFalse(sujet.accesPublic)
    assertFalse(sujet.accesSequentiel)
    assertFalse(sujet.ordreQuestionsAleatoire)
    assertEquals(CopyrightsType.default, sujet.copyrightsType)
  }

  void testFindSujetsForProprietaire() {
    Sujet sujet1 = sujetService.createSujet(personne1, SUJET_1_TITRE)
    assertFalse(sujet1.hasErrors())
    Sujet sujet2 = sujetService.createSujet(personne1, SUJET_1_TITRE)
    assertFalse(sujet2.hasErrors())
    def sujets1 = sujetService.findSujetsForProprietaire(personne1)
    assertEquals(2, sujets1.size())

    def sujets2 = sujetService.findSujetsForProprietaire(personne2)
    assertEquals(0, sujets2.size())

    assertEquals(2, sujetService.nombreSujetsForProprietaire(personne1))
    assertEquals(0, sujetService.nombreSujetsForProprietaire(personne2))
  }

}
