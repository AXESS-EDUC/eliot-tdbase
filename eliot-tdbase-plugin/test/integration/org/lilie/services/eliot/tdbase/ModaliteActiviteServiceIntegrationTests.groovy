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

package org.lilie.services.eliot.tdbase

import org.codehaus.groovy.grails.commons.GrailsApplication
import org.lilie.services.eliot.tdbase.preferences.GestionnaireModificationLiaisonFonctionRole
import org.lilie.services.eliot.tdbase.preferences.MappingFonctionRole
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.utils.BootstrapService

/**
 * @author John Tranier
 */
class ModaliteActiviteServiceIntegrationTests extends GroovyTestCase {

    SujetService sujetService
    ModaliteActiviteService modaliteActiviteService
    BootstrapService bootstrapService
    GrailsApplication grailsApplication
    GestionnaireModificationLiaisonFonctionRole gestionnaireModificationLiaisonFonctionRole

    Personne enseignant1

    protected void setUp() {
        super.setUp()
        bootstrapService.bootstrapJeuDeTestDevDemo()
        enseignant1 = bootstrapService.enseignant1

        // Initialisation du mapping Fonction / Rôle
        Map mappingFonctionRoleDefaut = grailsApplication.config.eliot.tdbase.mappingFonctionRole.defaut
        if (!mappingFonctionRoleDefaut) {
            throw new Exception("Parametre obligatoire eliot.tdbase.mappingFonctionRole.defaut n'est pas configure !")
        }

        MappingFonctionRole.defaultMappingFonctionRole = new MappingFonctionRole(
                gestionnaireModificationLiaisonFonctionRole: gestionnaireModificationLiaisonFonctionRole
        ).parseMapRepresentation(mappingFonctionRoleDefaut)
    }

    void testCreateModaliteActivite() {
        given: "Un sujet"
        Sujet sujet = sujetService.createSujet(
                enseignant1,
                'sujet'
        )
        assertNotNull(sujet)
        assertFalse(sujet.hasErrors())

        and: "Une activité sur le sujet"
        def now = new Date()
        ModaliteActivite activite = modaliteActiviteService.createModaliteActivite(
                [
                        dateDebut               : now - 10,
                        dateFin                 : now + 10,
                        datePublicationResultats: now + 12,
                        sujet                   : sujet,
                        groupeEnt               : bootstrapService.groupeEntLycee
                ],
                enseignant1
        )
        assertNotNull(activite)
        assertFalse(activite.hasErrors())

        then: "Vérification des personnes devant rendre une copie"
        // Le résulat doit contenir toutes les personne du groupeEntLycee
        // Sauf l'enseignant (car il n'a pas le rôle apprenant)
        // et l'élève 4 (car il n'appartient pas au lycée)
        assertEquals(
                [
                        bootstrapService.eleve1,
                        bootstrapService.eleve2,
                        bootstrapService.eleve3
                ]*.nomAffichage.sort(),
                activite.personnesDevantRendreCopie*.nomAffichage.sort()
        )
    }
}
