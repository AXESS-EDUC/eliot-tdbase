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

import org.hibernate.SessionFactory
import org.hibernate.stat.Statistics
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.UtilisateurService
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.securite.DomainAutorite

/**
 *  Test la classe DefaultUtilisateurService
 * @author franck silvestre
 */
class CacheDomainIntegrationTests extends GroovyTestCase {

  //static transactional = false

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

  void setUp() {
    statistics = sessionFactory.statistics
    statistics.statisticsEnabled = true
    //statistics.clear()
  }

  void testCacheAndGet() {
    Utilisateur utilisateur1 = defaultUtilisateurService.createUtilisateur(
            UTILISATEUR_1_LOGIN,
            UTILISATEUR_1_PASSWORD,
            UTILISATEUR_1_NOM,
            UTILISATEUR_1_PRENOM
    )

    //Utilisateur utilisateur1 = defaultUtilisateurService.findUtilisateur(UTILISATEUR_1_LOGIN)

    sessionFactory.currentSession.flush()
    sessionFactory.currentSession.clear()

    println "default session ${sessionFactory.currentSession}"

    Thread.start {
      Personne.withNewSession { org.hibernate.Session session ->
        println "new session ${session}"
        Personne personne1 = Personne.get(utilisateur1.personneId)
        DomainAutorite domainAutorite = DomainAutorite.get(utilisateur1.autoriteId)

        assertEquals(utilisateur1.personneId, personne1.id)

        assertEquals(utilisateur1.autoriteId, domainAutorite.id)
        println "new session ${session}"
      }
    }
    sleep(2000)
    Thread.start {
      Personne.withNewSession { org.hibernate.Session session ->
        println "new session 2  ${session}"

        Personne personne2 = Personne.get(utilisateur1.personneId)
        assertEquals(utilisateur1.personneId, personne2.id)


        DomainAutorite domainAutorite2 = DomainAutorite.get(utilisateur1.autoriteId)
        assertEquals(utilisateur1.autoriteId, domainAutorite2.id)

        println "new session 2  ${session}"

      }
    }

    sleep(2000)
    println ">>>>P ${statistics.secondLevelCachePutCount}"
    println ">>>>H ${statistics.secondLevelCacheHitCount}"
    println ">>>>M ${statistics.secondLevelCacheMissCount}"

  }


}
