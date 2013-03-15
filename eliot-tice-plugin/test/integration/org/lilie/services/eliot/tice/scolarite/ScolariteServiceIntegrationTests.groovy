/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 *  Lilie is free software. You can redistribute it and/or modify since
 *  you respect the terms of either (at least one of the both license) :
 *  - under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *  - the CeCILL-C as published by CeCILL-C; either version 1 of the
 *  License, or any later version
 *
 *  There are special exceptions to the terms and conditions of the
 *  licenses as they are applied to this software. View the full text of
 *  the exception in file LICENSE.txt in the directory of this software
 *  distribution.
 *
 *  Lilie is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  Licenses for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  and the CeCILL-C along with Lilie. If not, see :
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */


package org.lilie.services.eliot.tice.scolarite

import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.utils.BootstrapService
import org.lilie.services.eliot.tice.utils.InitialisationTestService

/**
 *  Test la classe ProfilScolariteService
 * @author franck silvestre
 */
class ScolariteServiceIntegrationTests extends GroovyTestCase {


  BootstrapService bootstrapService
  ScolariteService scolariteService


  void setUp() {
     bootstrapService.bootstrapForIntegrationTest()
  }

  void testFindNiveauxForStructureEnseignement() {
    def struct = bootstrapService.classe1ere
    def niveaux = scolariteService.findNiveauxForStructureEnseignement(struct)
    assertEquals(1, niveaux.size())
    assertEquals(struct.niveau,niveaux.first())

    struct = bootstrapService.grpe1ere
    niveaux = scolariteService.findNiveauxForStructureEnseignement(struct)
    assertEquals(2, niveaux.size())
    assertTrue("niveau premiere non trouve",niveaux.contains(bootstrapService.nivPremiere))
    assertTrue("niveau terminale non trouve",niveaux.contains(bootstrapService.nivTerminale))
  }

  void testFindStructuresEnseignement() {
    def etab = bootstrapService.leLycee
    def structs = scolariteService.findStructuresEnseignement(etab)
    assertEquals(3, structs.size())
    assertTrue("Terminale pas trouvée", structs.contains(bootstrapService.classeTerminale))
    assertTrue("premiere pas trouvée", structs.contains(bootstrapService.classe1ere))
    assertTrue("groupe pas trouvé", structs.contains(bootstrapService.grpe1ere))
  }
}
