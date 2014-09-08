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

import grails.plugin.spock.IntegrationSpec
import org.lilie.services.eliot.tdbase.utils.TdBaseInitialisationTestService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.utils.contract.PreConditionException

import java.lang.reflect.UndeclaredThrowableException

/**
 * @author Franck Silvestre
 */
class PreferenceEtablissementIntegrationSpec extends IntegrationSpec {

    Personne personne1
    Etablissement etablissement

    TdBaseInitialisationTestService tdBaseInitialisationTestService
    PreferenceEtablissementService preferenceEtablissementService

    def setup() {
        tdBaseInitialisationTestService.bootstrapForIntegrationTest()
        personne1 = tdBaseInitialisationTestService.utilisateur1.personne
        etablissement = tdBaseInitialisationTestService.leLycee
    }

    def "Recuperation des preferences etablissement"() {

        given: "un etablissement sans preference etablissement"
        PreferenceEtablissement.findByEtablissement(etablissement) == null

        when:"la preference de l'etablissement est demandee par un non administrateur"
        def pref = preferenceEtablissementService.getPreferenceForEtablissement(personne1,etablissement)

        then:"la preference n'est pas creee"
        !pref

        when:"la preference de l'etablissement est demandee par un administrateur"
        pref = preferenceEtablissementService.getPreferenceForEtablissement(personne1
                                                        ,etablissement, RoleApplicatif.ADMINISTRATEUR)

        then:"la preference de l'etablissement est cree"
        !pref.hasErrors()

        and: "l'etablissement est correct"
        pref.etablissement == etablissement

        and: "l'auteur de la modification est l'administreur ayant demande la pref"
        pref.lastUpdateAuteur == personne1

    }

    def "une preference etablissement n'est pas recree quand elle existe"() {

        given: "un etablissement avec preference etablissement"
        def pref = preferenceEtablissementService.getPreferenceForEtablissement(personne1,
                etablissement, RoleApplicatif.ADMINISTRATEUR)

        when: "la preference est demandee par un administrateur"
        def pref2 = preferenceEtablissementService.getPreferenceForEtablissement(personne1,
                etablissement, RoleApplicatif.ADMINISTRATEUR)

        then: "la preference unique de l'etablissement est recuperee"
        !pref.hasErrors()
        pref == pref2

        when: "un utilisateur non administrateur demande la preference"
        def pref3 = preferenceEtablissementService.getPreferenceForEtablissement(personne1,
                etablissement)

        then: "la preference unique de l'etablissement est recuperee"
        pref == pref3

    }

}
