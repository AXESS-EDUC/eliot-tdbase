package org.lilie.services.eliot.tdbase.securite

import grails.test.mixin.TestMixin
import grails.test.mixin.support.GrailsUnitTestMixin
import org.lilie.services.eliot.tdbase.RoleApplicatif
import org.lilie.services.eliot.tdbase.preferences.MappingFonctionRole
import org.lilie.services.eliot.tdbase.preferences.PreferenceEtablissement
import org.lilie.services.eliot.tdbase.preferences.PreferenceEtablissementService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.support.GrailsUnitTestMixin} for usage instructions
 */
@TestMixin(GrailsUnitTestMixin)
class SecuriteSessionServiceSpec extends Specification {

    Personne personne
    def utilisateur
    def profilScolariteService
    def preferenceEtablissementService
    def preferenceEtablissement
    def etablissement1
    def etablissement2

    def setup() {
        def personneMock = mockFor(Personne)
        personneMock.demand.getId { 1 }
        personne = personneMock.createMock()

        def utilisateurMock = mockFor(Utilisateur)
        utilisateurMock.demand.getPersonneId { 1 }
        utilisateurMock.demand.getPersonne { personne }
        utilisateur = utilisateurMock.createMock()

        def profilScolariteServiceMock = mockFor(ProfilScolariteService)
        profilScolariteServiceMock.demand.findFonctionEnumsForPersonneAndEtablissement { Personne personne1, Etablissement etab ->
            [FonctionEnum.ENS, FonctionEnum.AL]
        }
        profilScolariteService = profilScolariteServiceMock.createMock()

        def etablissementMock = mockFor(Etablissement)
        etablissement1 = etablissementMock.createMock()
        etablissement2 = etablissementMock.createMock()

        def mapping = new MappingFonctionRole(["ENS":
                                                       ["ENSEIGNANT":
                                                                ["associe"   : true,
                                                                 "modifiable": true],
                                                        "ELEVE":["associe"   : true,
                                                                 "modifiable": true],
                                                        "PARENT":["associe"   : false,
                                                                  "modifiable": false]
                                                       ],
                                               "AL" :
                                                       ["ADMINISTRATEUR": ["associe"   : true,
                                                                           "modifiable": true],
                                                        "ENSEIGNANT":
                                                                ["associe"   : true,
                                                                 "modifiable": true]
                                                       ]
        ])

        def preferenceEtablissementMock = mockFor(PreferenceEtablissement)
        preferenceEtablissementMock.demand.mappingFonctionRoleAsMap { ->
            mapping
        }
        preferenceEtablissement = preferenceEtablissementMock.createMock()

//        def preferenceEtablissementServiceMock = mockFor(PreferenceEtablissementService)
//        preferenceEtablissementServiceMock.demand.getPreferenceForEtablissement { Etablissement etab ->
//            preferenceEtablissement
//        }
//        preferenceEtablissementService = preferenceEtablissementServiceMock.createMock()

    }

    void "initialisation de la liste des roles applicatifs pour l'etablissement courant"() {

        given: "un objet securite session avec un current etablissement"
        SecuriteSessionService securiteSessionService = new SecuriteSessionService()
        securiteSessionService.profilScolariteService = profilScolariteService
        securiteSessionService.preferenceEtablissementService = preferenceEtablissementService
        securiteSessionService.currentEtablissement = etablissement1
        securiteSessionService.currentPreferenceEtablissement = preferenceEtablissement

        when:"on initialise la liste des roles applicatifs"
        securiteSessionService.initialiseRoleApplicatifListForCurrentEtablissement(personne)

        then:"la liste des roles applicatifs de la securité session sont mis à jours"
        securiteSessionService.roleApplicatifList.size() == 3
        securiteSessionService.roleApplicatifList.contains(RoleApplicatif.ENSEIGNANT)
        securiteSessionService.roleApplicatifList.contains(RoleApplicatif.ELEVE)
        securiteSessionService.roleApplicatifList.contains(RoleApplicatif.ADMINISTRATEUR)

    }
}