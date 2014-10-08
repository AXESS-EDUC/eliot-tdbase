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


package org.lilie.services.eliot.tice.scolarite

import org.lilie.services.eliot.tice.utils.BootstrapService

/**
 *  Test la classe ProfilScolariteService
 * @author franck silvestre
 */
class ProfilScolariteServiceIntegrationTests extends GroovyTestCase {

  BootstrapService bootstrapService
  ProfilScolariteService profilScolariteService
  FonctionService fonctionService


  void setUp() {
      bootstrapService.bootstrapJeuDeTestDevDemo()
  }

  void testFindProprietesScolaritesForPersonne() {
    List<ProprietesScolarite> props = profilScolariteService.findProprietesScolaritesForPersonne(bootstrapService.enseignant1)
    assertEquals("pas le bon de nombre de proprietes", 7, props.size())
  }

  void testFindFonctions() {
    List<Fonction> fonctions = profilScolariteService.findFonctionsForPersonne(bootstrapService.enseignant1)
    assertEquals("pas le bon de nombre de fonction", 1, fonctions.size())
    assertEquals("pas la bonne fonction", fonctionService.fonctionEnseignant(), fonctions.last())
  }

  void testFindProprietesScolaritesWithStructureForPersonne() {
    List<ProprietesScolarite> props = profilScolariteService.findProprietesScolariteWithStructureForPersonne(bootstrapService.enseignant1)
    assertEquals("pas le bon de nombre de props", 4, props.size())
  }

  void testFindNiveauxForPersonne() {
    def niveaux = profilScolariteService.findNiveauxForPersonne(bootstrapService.enseignant1)
    assertEquals(3, niveaux.size())
    assertTrue("Niveau 6ème pas trouvé",niveaux.contains(bootstrapService.nivSixieme))
    assertTrue("Niveau terminale pas trouvé",niveaux.contains(bootstrapService.nivTerminale))
    assertTrue("Niveau 1ère pas trouvé",niveaux.contains(bootstrapService.nivPremiere) )

  }


  void testFindEtablissementsForPersonne() {
      // test pour un enseignant
      def etabs = profilScolariteService.findEtablissementsForPersonne(bootstrapService.enseignant1)
      assertEquals(2, etabs.size())
      assertTrue("college pas trouvé",etabs.contains(bootstrapService.leCollege))
      assertTrue("lycee pas trouvé",etabs.contains(bootstrapService.leLycee))

      // test sur un eleve
      etabs = profilScolariteService.findEtablissementsForPersonne(bootstrapService.eleve1)
      assertEquals(2, etabs.size())
      assertTrue("college pas trouvé",etabs.contains(bootstrapService.leCollege))
      assertTrue("lycee pas trouvé",etabs.contains(bootstrapService.leLycee))

      // test sur un parent
      etabs = profilScolariteService.findEtablissementsForPersonne(bootstrapService.parent1)
      assertEquals(2, etabs.size())
      assertTrue("college pas trouvé",etabs.contains(bootstrapService.leCollege))
      assertTrue("lycee pas trouvé",etabs.contains(bootstrapService.leLycee))
    }

    void testPersonneEstResponsableEleve() {

        assertTrue(profilScolariteService.personneEstResponsableEleve(bootstrapService.parent1))
        assertTrue(profilScolariteService.personneEstResponsableEleve(bootstrapService.parent1, bootstrapService.eleve1))

        assertFalse(profilScolariteService.personneEstResponsableEleve(bootstrapService.enseignant1))
        assertFalse(profilScolariteService.personneEstResponsableEleve(bootstrapService.parent1, bootstrapService.enseignant1))
    }


}
