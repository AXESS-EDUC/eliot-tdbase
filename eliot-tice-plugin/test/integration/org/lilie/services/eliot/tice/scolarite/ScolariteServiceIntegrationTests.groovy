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

import org.junit.Test
import org.lilie.services.eliot.tice.utils.BootstrapService
import org.lilie.services.eliot.tice.utils.contract.PreConditionException

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
        assertEquals(struct.niveau, niveaux.first())

        struct = bootstrapService.grpe1ere
        niveaux = scolariteService.findNiveauxForStructureEnseignement(struct)
        assertEquals(2, niveaux.size())
        assertTrue("niveau premiere non trouve", niveaux.contains(bootstrapService.nivPremiere))
        assertTrue("niveau terminale non trouve", niveaux.contains(bootstrapService.nivTerminale))
    }


    void testFindStructuresEnseignement() {
        def lycee = bootstrapService.leLycee
        def structs = scolariteService.findStructuresEnseignement([lycee])
        assertEquals(3, structs.size())
        assertTrue("Terminale pas trouvée", structs.contains(bootstrapService.classeTerminale))
        assertTrue("premiere pas trouvée", structs.contains(bootstrapService.classe1ere))
        assertTrue("groupe pas trouvé", structs.contains(bootstrapService.grpe1ere))

        def college = bootstrapService.leCollege
        structs = scolariteService.findStructuresEnseignement([lycee, college])
        assertEquals(4, structs.size())

        structs = scolariteService.findStructuresEnseignement([lycee, college])
        assertEquals(4, structs.size())

        structs = scolariteService.findStructuresEnseignement([lycee, college], null,
                bootstrapService.nivSixieme)
        assertEquals(1, structs.size())
        assertTrue("sixieme pas trouvée", structs.contains(bootstrapService.classe6eme))

        structs = scolariteService.findStructuresEnseignement([lycee, college], null,
                bootstrapService.nivTerminale)
        assertEquals(2, structs.size())
        assertTrue("terminale pas trouvée", structs.contains(bootstrapService.classeTerminale))
        assertTrue("grpe pas trouvé", structs.contains(bootstrapService.grpe1ere))

        structs = scolariteService.findStructuresEnseignement([lycee, college], "1ere")
        assertEquals(2, structs.size())
        assertTrue("classe pas trouvée", structs.contains(bootstrapService.classe1ere))
        assertTrue("grpe pas trouvé", structs.contains(bootstrapService.grpe1ere))

        structs = scolariteService.findStructuresEnseignement([lycee, college], "1ERE")
        assertEquals(2, structs.size())
        assertTrue("classe pas trouvée", structs.contains(bootstrapService.classe1ere))
        assertTrue("grpe pas trouvé", structs.contains(bootstrapService.grpe1ere))
    }

    void testFindNiveauxForEtablissement() {
        def lycee = bootstrapService.leLycee
        def niveaux = scolariteService.findNiveauxForEtablissement([lycee])
        assertEquals(2, niveaux.size())
        assertTrue("pas de premiere", niveaux.contains(bootstrapService.nivPremiere))
        assertTrue("pas de terminal", niveaux.contains(bootstrapService.nivTerminale))

        def college = bootstrapService.leCollege
        niveaux = scolariteService.findNiveauxForEtablissement([college])
        assertEquals(1, niveaux.size())
        assertTrue("pas de sixieme", niveaux.contains(bootstrapService.nivSixieme))

        niveaux = scolariteService.findNiveauxForEtablissement([lycee, college])
        assertEquals(3, niveaux.size())
        assertTrue("pas de premiere", niveaux.contains(bootstrapService.nivPremiere))
        assertTrue("pas de terminal", niveaux.contains(bootstrapService.nivTerminale))
        assertTrue("pas de sixieme", niveaux.contains(bootstrapService.nivSixieme))

    }

    void testFindMatieresSuccess() {
        // given : un établissement
        def leLycee = bootstrapService.leLycee
        // when : findMatieres est demandé pour cet établissement
        def res = scolariteService.findMatieres([leLycee])
        // then: toutes les matieres de l'établissement sont retournées
        assertEquals("pas toutes les matières",5,res.size())

        // when : find matières est demandé pour cet établissement avec un pattern de code correspondant à une matière
        res = scolariteService.findMatieres([leLycee],"anglais")
        // then : une seule matière est retournée
        assertEquals("pas 1 seule les matière",1,res.size())
        assertEquals("pas la bonne matière",bootstrapService.matiereAnglais,res.last())

        // when : find matières est demandé pour cet établissement avec un pattern ne correspondant à aucune matière
        res = scolariteService.findMatieres([leLycee],"no_result")
        // then : la liste retournée est vide
        assertEquals("pas 0 matière",0,res.size())

    }

    @Test(expected = PreConditionException)
    void testFindMatieresFailure() {
        // when : findMatieres est demandé pour aucun établissement
        def res = scolariteService.findMatieres([])
        // then: une exception est de type PreconditionException est levée
    }
}
