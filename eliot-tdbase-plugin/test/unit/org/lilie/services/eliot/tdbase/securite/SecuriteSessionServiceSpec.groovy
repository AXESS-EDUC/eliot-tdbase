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

    MappingFonctionRole mappingFonctionRole

    def setup() {

        mappingFonctionRole = new MappingFonctionRole(["ENS":
                                                       ["ENSEIGNANT":
                                                                ["associe"   : true,
                                                                 "modifiable": true],
                                                        "ELEVE"     : ["associe"   : true,
                                                                       "modifiable": true],
                                                        "PARENT"    : ["associe"   : false,
                                                                       "modifiable": false]
                                                       ],
                                               "AL" :
                                                       ["ADMINISTRATEUR": ["associe"   : true,
                                                                           "modifiable": true],
                                                        "ENSEIGNANT"    :
                                                                ["associe"   : true,
                                                                 "modifiable": true]
                                                       ]
        ])


    }

    void "test de l'initialisation de la liste des roles applicatifs pour l'etablissement courant"() {

        given: "un objet securite session avec un current etablissement"
        SecuriteSessionService securiteSessionService = new SecuriteSessionService()
        securiteSessionService.profilScolariteService = Mock(ProfilScolariteService) {
            findFonctionsForPersonneAndEtablissement(_,_) >> [FonctionEnum.ENS, FonctionEnum.AL]
        }
        securiteSessionService.currentEtablissement = Mock(Etablissement)
        securiteSessionService.currentPreferenceEtablissement = Mock(PreferenceEtablissement) {
            mappingFonctionRoleAsMap() >> mappingFonctionRole
        }
        and: "une personne déclenchant l'appel à la méthode"
        def personne = Mock(Personne)

        when: "on initialise la liste des roles applicatifs"
        securiteSessionService.initialiseRoleApplicatifListForCurrentEtablissement(personne)

        then: "la liste des roles applicatifs de la securité session est mise à jours"
        securiteSessionService.roleApplicatifList.size() == 3
        securiteSessionService.roleApplicatifList.contains(RoleApplicatif.ENSEIGNANT)
        securiteSessionService.roleApplicatifList.contains(RoleApplicatif.ELEVE)
        securiteSessionService.roleApplicatifList.contains(RoleApplicatif.ADMINISTRATEUR)

    }

    def "test du onChange etalissement"() {

        given: "un etablissement"
        def etab = Mock(Etablissement)

        and: "un objet securite session"
        SecuriteSessionService securiteSessionService = new SecuriteSessionService()
        securiteSessionService.personneId =1
        securiteSessionService.profilScolariteService = Mock(ProfilScolariteService) {
            findFonctionsForPersonneAndEtablissement(_,_) >> [FonctionEnum.ENS, FonctionEnum.AL]
        }
        def preferenceEtablissement = Mock(PreferenceEtablissement) {
            mappingFonctionRoleAsMap() >> mappingFonctionRole
        }

        and:" une personne déclenchant le changement d'établissement"
        def personne = Mock(Personne) {
            getId() >> 1
        }
        securiteSessionService.preferenceEtablissementService = Mock(PreferenceEtablissementService) {
            getPreferenceForEtablissement(personne,etab) >> preferenceEtablissement
        }

        when: "le changement d'établissement est demandé par la personne"
        securiteSessionService.onChangeEtablissement(personne,etab)

        then:"l'objet securite session est mis a jour"
        securiteSessionService.currentEtablissement == etab
        securiteSessionService.currentPreferenceEtablissement == preferenceEtablissement
        securiteSessionService.roleApplicatifList.size() == 3
        securiteSessionService.roleApplicatifList.contains(RoleApplicatif.ENSEIGNANT)
        securiteSessionService.roleApplicatifList.contains(RoleApplicatif.ELEVE)
        securiteSessionService.roleApplicatifList.contains(RoleApplicatif.ADMINISTRATEUR)
        securiteSessionService.currentRoleApplicatif == RoleApplicatif.ADMINISTRATEUR
    }

    def "test onChange etablissement par une personne non autorisée "() {
        given: "une personne non autorisee"
        def personne = Mock(Personne) {
            getId() >> 2
        }
        and: "un objet securite session"
        SecuriteSessionService securiteSessionService = new SecuriteSessionService()
        securiteSessionService.personneId = 1

        when:"un changement d'établissement est demandé par la personne non autorisée"
        securiteSessionService.onChangeEtablissement(personne,Mock(Etablissement))

        then:"une exception de sécurité est levée"
        thrown(BadPersonnSecuritySessionException)
    }

    def "test de la premiere initialisation d'un objet securite session"() {
        given:"un utilisateur"
        def personne = Mock(Personne) {
            getId() >> 1
        }
        def utilisateur = Mock(Utilisateur) {
            getPersonneId() >> 1
            getPersonne() >> personne
        }
        and:" un nouvel objet securite session non encore initialisé"
        SecuriteSessionService securiteSessionService = new SecuriteSessionService()
        def etab = Mock(Etablissement)
        securiteSessionService.profilScolariteService = Mock(ProfilScolariteService) {
            findEtablissementsForPersonne(personne) >> [etab, Mock(Etablissement)]
            findFonctionsForPersonneAndEtablissement(_,_) >> [FonctionEnum.ENS, FonctionEnum.AL]
        }
        def preferenceEtablissement = Mock(PreferenceEtablissement) {
            mappingFonctionRoleAsMap() >> mappingFonctionRole
        }
        securiteSessionService.preferenceEtablissementService = Mock(PreferenceEtablissementService) {
            getPreferenceForEtablissement(personne,etab) >> preferenceEtablissement
        }

        and:"une transaction"
//        GroovyMock(Personne, global:true) {
//            withTransaction(_) >> { v -> return v[0]}
//        }
        // tip given by Burt Beckwith here :
        // http://grails.1312388.n4.nabble.com/Testing-plugin-how-to-mock-withTransaction-on-Domain-object-td1368196.html
        Personne.metaClass.'static'.withTransaction = { Closure callable ->
            callable.call(null)
        }


        when:"l'initialisation est déclenchée pour l'utilisateur donné"
        securiteSessionService.initialiseSecuriteSessionForUtilisateur(utilisateur)

        then:"l'objet securité session est mis à jour"
        securiteSessionService.personneId == 1
        securiteSessionService.etablissementList.size() == 2
        securiteSessionService.currentEtablissement == etab
        securiteSessionService.currentPreferenceEtablissement == preferenceEtablissement
        securiteSessionService.roleApplicatifList.size() == 3
        securiteSessionService.roleApplicatifList.contains(RoleApplicatif.ENSEIGNANT)
        securiteSessionService.roleApplicatifList.contains(RoleApplicatif.ELEVE)
        securiteSessionService.roleApplicatifList.contains(RoleApplicatif.ADMINISTRATEUR)
        securiteSessionService.currentRoleApplicatif == RoleApplicatif.ADMINISTRATEUR

    }

    def "test de l'initialisation d'un objet securite session deja initialisé pour le même utilisateur"() {
        given: "un utilisateur"
        def personne = Mock(Personne) {
            getId() >> 1
        }
        def utilisateur = Mock(Utilisateur) {
            getPersonneId() >> 1
            getPersonne() >> personne
        }
        and: "un objet securite session deja initialise"
        SecuriteSessionService securiteSessionService = new SecuriteSessionService()
        securiteSessionService.personneId = 1
        def profilScolariteService = Mock(ProfilScolariteService)
        securiteSessionService.profilScolariteService = profilScolariteService

        when:"l'initialisation est déclenchée par l'utilisateur autorisé"
        securiteSessionService.initialiseSecuriteSessionForUtilisateur(utilisateur)

        then:"aucune interaction n'est provoquee car l'objet est laissé inchangé"
        0 * profilScolariteService.findEtablissementsForPersonne()
        0 * profilScolariteService.findFonctionsForPersonneAndEtablissement(_,_)
    }

    def "test de l'initialisation d'un objet securite session deja initialisé par un utilisateur different"() {
        given: "un utilisateur"
        def personne = Mock(Personne) {
            getId() >> 1
        }
        def utilisateur = Mock(Utilisateur) {
            getPersonneId() >> 1
            getPersonne() >> personne
        }
        and: "un objet securite session deja initialise par un autre utilisateur"
        SecuriteSessionService securiteSessionService = new SecuriteSessionService()
        securiteSessionService.personneId = 2

        when:"l'initialisation est déclenchée par l'utilisateur non autorisé"
        securiteSessionService.initialiseSecuriteSessionForUtilisateur(utilisateur)

        then:"une exception de sécurité est levée"
        thrown(BadPersonnSecuritySessionException)
    }
}