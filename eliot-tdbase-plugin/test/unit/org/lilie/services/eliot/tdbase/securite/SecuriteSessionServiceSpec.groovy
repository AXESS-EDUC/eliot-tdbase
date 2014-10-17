package org.lilie.services.eliot.tdbase.securite

import grails.test.mixin.Mock
import grails.test.mixin.TestMixin
import grails.test.mixin.support.GrailsUnitTestMixin
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
    SecuriteSessionService securiteSessionService

    def setup() {
        mappingFonctionRole = getDefaultMappingFonctionRole()
        securiteSessionService = new SecuriteSessionService()
    }


    def "test du onChange etablissement"() {

        given: "un etablissement"
        def etab = Mock(Etablissement)

        and: "un objet securite session"
        securiteSessionService.personneId = 1
        def preferenceEtablissement = Mock(PreferenceEtablissement) {
            mappingFonctionRoleAsMap() >> mappingFonctionRole
        }
        def etabList = new TreeSet<Etablissement>()
        etabList.add(etab)
        PerimetreRoleApplicatif perimetre = Mock(PerimetreRoleApplicatif) {
            getEtablissementList() >> etabList
        }
        securiteSessionService.rolesApplicatifsAndPerimetreByRoleApplicatif = new TreeMap<>()
        securiteSessionService.rolesApplicatifsAndPerimetreByRoleApplicatif.put(RoleApplicatif.ADMINISTRATEUR,perimetre)
        securiteSessionService.currentRoleApplicatif = RoleApplicatif.ADMINISTRATEUR

        and: " une personne déclenchant le changement d'établissement"
        def personne = Mock(Personne) {
            getId() >> 1
        }
        securiteSessionService.preferenceEtablissementService = Mock(PreferenceEtablissementService) {
            getPreferenceForEtablissement(personne, etab) >> preferenceEtablissement
        }

        when: "le changement d'établissement est demandé par la personne"
        securiteSessionService.onChangeEtablissement(personne, etab)

        then: "l'objet securite session est mis a jour"
        securiteSessionService.currentEtablissement == etab
        securiteSessionService.currentPreferenceEtablissement == preferenceEtablissement
    }

    def "test onChange etablissement par une personne non autorisée "() {
        given: "une personne non autorisee"
        def personne = Mock(Personne) {
            getId() >> 2
        }
        and: "un objet securite session"
        securiteSessionService.personneId = 1

        when: "un changement d'établissement est demandé par la personne non autorisée"
        securiteSessionService.onChangeEtablissement(personne, Mock(Etablissement))

        then: "une exception de sécurité est levée"
        thrown(BadPersonnSecuritySessionException)
    }

    def "test de la premiere initialisation d'un objet securite session (non super admin)"() {
        given: "une personne"
        def personne = Mock(Personne) {
            getId() >> 1
        }
        def utilisateur = Mock(Utilisateur) {
            getPersonneId() >> 1
            getPersonne() >> personne
        }

        and: "des établissements"
        Etablissement etab1 = Mock(Etablissement)
        Etablissement etab2 = Mock(Etablissement)

        securiteSessionService.preferenceEtablissementService = Mock(PreferenceEtablissementService) {
            getMappingFonctionRoleForEtablissement(personne, _) >> mappingFonctionRole
        }

        and: "les fonctions de la personne"
        def fctsByEtab = new HashMap<Etablissement, Set<FonctionEnum>>()
        fctsByEtab.put(etab1, [FonctionEnum.AL, FonctionEnum.ENS] as Set)
        fctsByEtab.put(etab2, [FonctionEnum.ENS] as Set)
        securiteSessionService.profilScolariteService = Mock(ProfilScolariteService) {
            findEtablissementsAndFonctionsForPersonne(personne) >> fctsByEtab
        }

        and: "une transaction"
        // tip given by Burt Beckwith here :
        // http://grails.1312388.n4.nabble.com/Testing-plugin-how-to-mock-withTransaction-on-Domain-object-td1368196.html
        Personne.metaClass.'static'.withTransaction = { Closure callable ->
            callable.call(null)
        }


        when: "l'initialisation est déclenchée pour l'utilisateur donné"
        securiteSessionService.initialiseSecuriteSessionForUtilisateur(utilisateur)

        then: "l'objet securité session est mis à jour"
        securiteSessionService.personneId == 1
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

        when: "l'initialisation est déclenchée par l'utilisateur autorisé"
        securiteSessionService.initialiseSecuriteSessionForUtilisateur(utilisateur)

        then: "aucune interaction n'est provoquee car l'objet est laissé inchangé"
        0 * profilScolariteService.findEtablissementsForPersonne()
        0 * profilScolariteService.findFonctionsForPersonneAndEtablissement(_, _)
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

        when: "l'initialisation est déclenchée par l'utilisateur non autorisé"
        securiteSessionService.initialiseSecuriteSessionForUtilisateur(utilisateur)

        then: "une exception de sécurité est levée"
        thrown(BadPersonnSecuritySessionException)
    }

    def "test de la constitution des rôles avec périmètre pour une personne avec établissements"() {

        given: "une personne"
        def personne = Mock(Personne)

        and: "des établissements"
        Etablissement etab1 = Mock(Etablissement)
        Etablissement etab2 = Mock(Etablissement) {
            compareTo(etab1) >> -1
        }
        etab1.compareTo(etab2) >> 1
        securiteSessionService.preferenceEtablissementService = Mock(PreferenceEtablissementService) {
            getMappingFonctionRoleForEtablissement(personne,  _) >> mappingFonctionRole
        }

        and: "les fonctions de la personne"
        def fctsByEtab = new HashMap<Etablissement, Set<FonctionEnum>>()
        fctsByEtab.put(etab1, [FonctionEnum.AL, FonctionEnum.ENS] as Set)
        fctsByEtab.put(etab2, [FonctionEnum.ENS] as Set)
        securiteSessionService.profilScolariteService = Mock(ProfilScolariteService) {
            findEtablissementsAndFonctionsForPersonne(personne) >> fctsByEtab
        }

        when: "la constitution des rôles avec périmètres est déclenchée"
        securiteSessionService.initialiseRolesAvecPerimetreForPersonne(personne)

        then: "la liste des rôles avec périmètre contient les rôles applicatifs attendu"
        def rolesPerimetres = securiteSessionService.rolesApplicatifsAndPerimetreByRoleApplicatif
        rolesPerimetres.size() == 3
        rolesPerimetres.containsKey(RoleApplicatif.ENSEIGNANT)
        rolesPerimetres.containsKey(RoleApplicatif.ADMINISTRATEUR)
        rolesPerimetres.containsKey(RoleApplicatif.ELEVE)

        and: "le role ENSEIGNANT a pour  perimetre tous les établissements"
        rolesPerimetres.get(RoleApplicatif.ENSEIGNANT).etablissementList.size() == 2
        rolesPerimetres.get(RoleApplicatif.ENSEIGNANT).perimetre == PerimetreRoleApplicatifEnum.ALL_ETABLISSEMENTS

        and: "le role ADMINISTRATEUR ne concerne que l'établissement 1"
        rolesPerimetres.get(RoleApplicatif.ADMINISTRATEUR).etablissementList == [etab1] as Set
        rolesPerimetres.get(RoleApplicatif.ADMINISTRATEUR).perimetre == PerimetreRoleApplicatifEnum.SEVERAL_ETABLISSEMENTS

        and: "le role ELEVE ne concerne que l'établissement 1"
        rolesPerimetres.get(RoleApplicatif.ELEVE).etablissementList == [etab1, etab2] as Set
        rolesPerimetres.get(RoleApplicatif.ELEVE).perimetre == PerimetreRoleApplicatifEnum.ALL_ETABLISSEMENTS

    }


    private MappingFonctionRole getDefaultMappingFonctionRole() {
        new MappingFonctionRole(["ENS":
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

}