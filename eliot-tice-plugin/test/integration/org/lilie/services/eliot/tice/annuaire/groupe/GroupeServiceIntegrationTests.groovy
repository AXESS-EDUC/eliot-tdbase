/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 *  This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
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
 *   <http://www.gnu.org/licenses/> and
 *   <http://www.cecill.info/licences.fr.html>.
 */

package org.lilie.services.eliot.tice.annuaire.groupe

import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.Fonction
import org.lilie.services.eliot.tice.scolarite.FonctionService
import org.lilie.services.eliot.tice.scolarite.ProprietesScolarite
import org.lilie.services.eliot.tice.scolarite.StructureEnseignement
import org.lilie.services.eliot.tice.utils.BootstrapService

/**
 * @author John Tranier
 */
class GroupeServiceIntegrationTests extends GroovyTestCase {

    GroupeService groupeService
    BootstrapService bootstrapService
    FonctionService fonctionService

    void setUp() {
        bootstrapService.bootstrapJeuDeTestDevDemo()
    }


    void testFindAllPersonneInGroupeScolarite() {
        given: "Une classe"
        StructureEnseignement classe = bootstrapService.classe1ere

        and: "Le groupe scolarité des élèves de la classe"
        ProprietesScolarite groupeScolarite =
                ProprietesScolarite.withCriteria(uniqueResult: true) {
                    eq('structureEnseignement', classe)
                    eq('fonction', fonctionService.fonctionEleve())
                    isNull('responsableStructureEnseignement')
                }

        expect:
        assertEquals(
                "Le nombre d'élèves dans la classe est incorrect",
                2,
                groupeService.findAllPersonneInGroupeScolarite(
                        groupeScolarite
                ).size()
        )
    }

    void testFindAllGroupeScolariteForPersonne() {
        given:
        Personne personne = bootstrapService.eleve1

        expect:
        List<ProprietesScolarite> groupeScolariteList = groupeService.findAllGroupeScolariteForPersonne(personne)
        assertEquals(
                "Le nombre de groupes est incorrect",
                4,
                groupeScolariteList.size()
        )

        given:
        personne = bootstrapService.enseignant1

        expect:
        groupeScolariteList = groupeService.findAllGroupeScolariteForPersonne(personne)
        assertEquals(
                "Le nombre de groupes est incorrect",
                8,
                groupeScolariteList.size()
        )

        given:
        personne = bootstrapService.parent1

        expect:
        groupeScolariteList = groupeService.findAllGroupeScolariteForPersonne(personne)
        assertEquals(
                "Le nombre de groupes est incorrect",
                5,
                groupeScolariteList.size()
        )

        given:
        personne = bootstrapService.persDirection1

        expect:
        groupeScolariteList = groupeService.findAllGroupeScolariteForPersonne(personne)
        assertEquals(
                "Le nombre de groupes est incorrect",
                2,
                groupeScolariteList.size()
        )
    }

    void testRechercheGroupeScolarite() {
        given:
        Personne enseignant = bootstrapService.enseignant1
        Etablissement etablissement = bootstrapService.leLycee
        Fonction fonction = fonctionService.fonctionEleve()

        expect:
        RechercheGroupeResultat resultat =
                groupeService.rechercheGroupeScolarite(
                enseignant,
                new RechercheGroupeCritere(
                        etablissement: etablissement,
                        fonction: fonction
                )
        )

        assertEquals(
                3,
                resultat.nombreTotal
        )

        given:
        fonction = fonctionService.fonctionEnseignant()

        expect:
        resultat = groupeService.rechercheGroupeScolarite(
                        enseignant,
                        new RechercheGroupeCritere(
                                etablissement: etablissement,
                                fonction: fonction
                        )
                )

        assertEquals(
                3,
                resultat.nombreTotal
        )
    }
}
