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

    void testFindStructuresEnseignementForPersonne() {
        List<ProprietesScolarite> props = profilScolariteService.findStructuresEnseignementForPersonne(bootstrapService.enseignant1)
        assertEquals("pas le bon de nombre de proprietes", 4, props.size())
        props = profilScolariteService.findStructuresEnseignementForPersonne(bootstrapService.enseignant1, fonctionService.fonctionEleve())
        assertEquals("le filtre sur la fonction est KO", 0, props.size())

    }

    void testFindFonctions() {
        List<Fonction> fonctions = profilScolariteService.findFonctionsForPersonne(bootstrapService.enseignant1)
        assertEquals("pas le bon de nombre de fonction", 1, fonctions.size())
        assertEquals("pas la bonne fonction", fonctionService.fonctionEnseignant(), fonctions.last())
    }

    void testFindProprietesScolaritesWithStructureForPersonne() {
        // given: un enseignant dans 4 classes sur deux établissements
        def ens = bootstrapService.enseignant1

        // when: la recherche des pps avec struture est lancée sans filtrer sur un étab
        List<ProprietesScolarite> props = profilScolariteService.findProprietesScolariteWithStructureForPersonne(bootstrapService.enseignant1)

        //then: toutes les pps concernées sont récupérées
        assertEquals("pas le bon de nombre de props", 4, props.size())

        //when: la recherche des pps avec struture est lancée uniquement sur le collège
        def lecollege = bootstrapService.leCollege
        props = profilScolariteService.findProprietesScolariteWithStructureForPersonne(bootstrapService.enseignant1, [lecollege])

        //then: uniquement les pps du collège sont récupérées
        assertEquals("pas le bon de nombre de props", 1, props.size())

    }

    void testFindNiveauxForPersonne() {
        def niveaux = profilScolariteService.findNiveauxForPersonne(bootstrapService.enseignant1)
        assertEquals(3, niveaux.size())
        assertTrue("Niveau 6ème pas trouvé", niveaux.contains(bootstrapService.nivSixieme))
        assertTrue("Niveau terminale pas trouvé", niveaux.contains(bootstrapService.nivTerminale))
        assertTrue("Niveau 1ère pas trouvé", niveaux.contains(bootstrapService.nivPremiere))

    }


    void testFindEtablissementsForPersonne() {
        // test pour un enseignant
        def etabs = profilScolariteService.findEtablissementsForPersonne(bootstrapService.enseignant1)
        assertEquals(2, etabs.size())
        assertTrue("college pas trouvé", etabs.contains(bootstrapService.leCollege))
        assertTrue("lycee pas trouvé", etabs.contains(bootstrapService.leLycee))

        // test sur un eleve
        etabs = profilScolariteService.findEtablissementsForPersonne(bootstrapService.eleve1)
        assertEquals(2, etabs.size())
        assertTrue("college pas trouvé", etabs.contains(bootstrapService.leCollege))
        assertTrue("lycee pas trouvé", etabs.contains(bootstrapService.leLycee))

        // test sur un parent
        etabs = profilScolariteService.findEtablissementsForPersonne(bootstrapService.parent1)
        assertEquals(2, etabs.size())
        assertTrue("college pas trouvé", etabs.contains(bootstrapService.leCollege))
        assertTrue("lycee pas trouvé", etabs.contains(bootstrapService.leLycee))
    }

    void testPersonneEstResponsableEleve() {

        assertTrue(profilScolariteService.personneEstResponsableEleve(bootstrapService.parent1))
        assertTrue(profilScolariteService.personneEstResponsableEleve(bootstrapService.parent1,
                bootstrapService.eleve1))

        assertFalse(profilScolariteService.personneEstResponsableEleve(bootstrapService.enseignant1))
        assertFalse(profilScolariteService.personneEstResponsableEleve(bootstrapService.parent1,
                bootstrapService.enseignant1))
    }

    void testPersonneEstPersonnelDirection() {
        assertTrue(profilScolariteService.personneEstPersonnelDirectionForEtablissement(bootstrapService.persDirection1,
                bootstrapService.leCollege))
        assertTrue(profilScolariteService.personneEstPersonnelDirectionForEtablissement(bootstrapService.persDirection1,
                bootstrapService.leLycee))
    }

    void testPersonneEstAdministrateurCentral() {
        assertTrue(profilScolariteService.personneEstAdministrateurCentralForPorteurEnt(bootstrapService.superAdmin1,
                bootstrapService.leLycee.porteurEnt))
    }

    void testFindFonctionsForPersonneAndEtablissement() {
        // given: un établissement
        def etab = bootstrapService.leLycee

        // and: un enseignant
        def ens1 = bootstrapService.enseignant1

        // when: la recherche de fonction est lancée
        Set fcts = profilScolariteService.findFonctionsForPersonneAndEtablissement(ens1, etab)

        // then: la fct retournée est enseignant
        assertEquals(1, fcts.size())
        assertTrue(fcts.contains(FonctionEnum.ENS))

    }

    void testFindEtablissementsAndFonctionsForPersonne() {
        // given: un enseignant
        def ens1 = bootstrapService.enseignant1

        // when: la recherche d'établissements et de fonctions est lancée
        def res = profilScolariteService.findEtablissementsAndFonctionsForPersonne(ens1)

        // then: le résultats contient les établissements assicié à la fonction enseignant
        res.size() == 2
        res.get(bootstrapService.leLycee).size() == 1
        res.get(bootstrapService.leLycee).contains(FonctionEnum.ENS)
        res.get(bootstrapService.leCollege).size() == 1
        res.get(bootstrapService.leCollege).contains(FonctionEnum.ENS)

        // given: un parent
        def parent1 = bootstrapService.parent1

        // when: la recherche d'établissements et de fonctions est lancée
        res = profilScolariteService.findEtablissementsAndFonctionsForPersonne(ens1)

        // then: le résultats contient les établissements assicié à la fonction enseignant
        res.size() == 2
        res.get(bootstrapService.leLycee).size() == 1
        res.get(bootstrapService.leLycee).contains(FonctionEnum.PERS_REL_ELEVE)
        res.get(bootstrapService.leCollege).size() == 1
        res.get(bootstrapService.leCollege).contains(FonctionEnum.PERS_REL_ELEVE)

        // given: un élève
        def elv1 = bootstrapService.eleve1

        // when: la recherche d'établissements et de fonctions est lancée
        res = profilScolariteService.findEtablissementsAndFonctionsForPersonne(ens1)

        // then: le résultats contient les établissements assicié à la fonction enseignant
        res.size() == 2
        res.get(bootstrapService.leLycee).size() == 1
        res.get(bootstrapService.leLycee).contains(FonctionEnum.ELEVE)
        res.get(bootstrapService.leCollege).size() == 1
        res.get(bootstrapService.leCollege).contains(FonctionEnum.ELEVE)

        // given: un pers de direction
        def pers1 = bootstrapService.persDirection1

        // when: la recherche d'établissements et de fonctions est lancée
        res = profilScolariteService.findEtablissementsAndFonctionsForPersonne(ens1)

        // then: le résultats contient les établissements assicié à la fonction enseignant
        res.size() == 2
        res.get(bootstrapService.leLycee).size() == 1
        res.get(bootstrapService.leLycee).contains(FonctionEnum.DIR)
        res.get(bootstrapService.leCollege).size() == 1
        res.get(bootstrapService.leCollege).contains(FonctionEnum.DIR)
    }

    void testFindEtablissementsAdministresForPersonne() {
        given: "un administrateur d'établissements"
        def admin = bootstrapService.persDirection1

        when: "la récupération des établissements qu'il administre est demandé"
        def res = profilScolariteService.findEtablissementsAdministresForPersonne(admin)

        then:"Les établissements récupérés sont les administrés par la personne"
        assertEquals("pas le bon nombre d'établissements",2,res.size())
        assertTrue(res.contains(bootstrapService.leLycee))
        assertTrue(res.contains(bootstrapService.leCollege))

        given: "un non administrateur d'établissements"
        def ens = bootstrapService.enseignant1

        when: "la récupération des établissements qu'il administre est demandé"
        res = profilScolariteService.findEtablissementsAdministresForPersonne(ens)

        then:"aucun établissement n'est récupéré"
        assertEquals("pas le bon nombre d'établissements",0,res.size())

    }

}
