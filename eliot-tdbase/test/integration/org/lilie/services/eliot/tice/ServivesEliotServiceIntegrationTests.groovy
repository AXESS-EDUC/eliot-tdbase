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

package org.lilie.services.eliot.tice

import org.hibernate.SessionFactory

import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.utils.InitialisationTestService
import org.lilie.services.eliot.tice.utils.ServicesEliotService
import org.lilie.services.eliot.tice.utils.ServiceEliotEnum

/**
 *
 * @author franck Silvestre
 */
class ServivesEliotServiceIntegrationTests extends GroovyTestCase {


  Utilisateur utilisateur1
  Personne personne1
  SessionFactory sessionFactory

  InitialisationTestService initialisationTestService
  ServicesEliotService servicesEliotService

  void setUp() {
    super.setUp()
    utilisateur1 = initialisationTestService.getUtilisateur1()
    personne1 = utilisateur1.personne
  }

  void tearDown() {
    super.tearDown()
  }

  def testGetCheminRacineSystemeFichier() {
    def config = new ConfigSlurper().parse("""
        eliot.fichiers.racine = '/Users/Shared/eliot-root'
    """)
    assertEquals('/Users/Shared/eliot-root/',
                 servicesEliotService.getCheminRacineEspaceFichier(config))
  }

  def testGetCheminRacineSystemeFichierForPersonneAndServiceEliot() {
    def config = new ConfigSlurper().parse("""
        eliot.fichiers.racine = '/Users/Shared/eliot-root'
    """)
    assertEquals('/Users/Shared/eliot-root/',
                 servicesEliotService.getCheminRacineEspaceFichier(config))
    def persId = personne1.id.toString()
    persId = "00000000000000000000".substring(persId.size()) + persId
    String chemin = servicesEliotService.getCheminRelatifEspaceFichierForPersonneAndServiceEliot(
                          personne1,ServiceEliotEnum.tdbase)
    println(chemin)
    assertEquals("${persId}/tdbase/Documents/".toString(),
                  chemin)


  }
}
