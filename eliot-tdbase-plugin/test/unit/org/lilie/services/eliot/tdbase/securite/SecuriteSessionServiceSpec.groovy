package org.lilie.services.eliot.tdbase.securite

import grails.test.mixin.TestMixin
import grails.test.mixin.support.GrailsUnitTestMixin
import org.lilie.services.eliot.tdbase.preferences.MappingFonctionRole
import org.lilie.services.eliot.tdbase.preferences.PreferenceEtablissement
import org.lilie.services.eliot.tdbase.preferences.PreferenceEtablissementService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.annuaire.groupe.GroupeService
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService
import org.lilie.services.eliot.tice.securite.CorrespondantDeploimentConfig
import org.lilie.services.eliot.tice.securite.DomainAutorite
import org.lilie.services.eliot.tice.utils.contract.PreConditionException
import spock.lang.Specification
import spock.lang.Unroll

/**
 * See the API for {@link grails.test.mixin.support.GrailsUnitTestMixin} for usage instructions
 */
@TestMixin(GrailsUnitTestMixin)
class SecuriteSessionServiceSpec extends Specification {

    MappingFonctionRole mappingFonctionRole
    SecuriteSessionService securiteSessionService
    GroupeService groupeService

    def setup() {
        mappingFonctionRole = getDefaultMappingFonctionRole()
        groupeService = Mock(GroupeService)
        securiteSessionService = new SecuriteSessionService(
                groupeService: groupeService
        )
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
            getEtablissements() >> etabList
        }
        securiteSessionService.rolesApplicatifsAndPerimetreByRoleApplicatif = new TreeMap<>()
        securiteSessionService.rolesApplicatifsAndPerimetreByRoleApplicatif.put(RoleApplicatif.ADMINISTRATEUR, perimetre)
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
        securiteSessionService.currentRoleApplicatif == RoleApplicatif.ENSEIGNANT

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
        0 * profilScolariteService.findEtablissementsAndFonctionsForPersonne()
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
        // hack pour mock sur objets "comparable"
        Etablissement etab2 = Mock(Etablissement) {
            compareTo(etab1) >> -1
        }
        etab1.compareTo(etab2) >> 1
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

        when: "la constitution des rôles avec périmètres est déclenchée"
        securiteSessionService.initialiseRolesAvecPerimetreForPersonne(personne)

        then: "la liste des rôles avec périmètre contient les rôles applicatifs attendu"
        def rolesPerimetres = securiteSessionService.rolesApplicatifsAndPerimetreByRoleApplicatif
        rolesPerimetres.size() == 3
        rolesPerimetres.containsKey(RoleApplicatif.ENSEIGNANT)
        rolesPerimetres.containsKey(RoleApplicatif.ADMINISTRATEUR)
        rolesPerimetres.containsKey(RoleApplicatif.ELEVE)

        and: "le role ENSEIGNANT a pour  perimetre tous les établissements"
        rolesPerimetres.get(RoleApplicatif.ENSEIGNANT).etablissements.size() == 2
        rolesPerimetres.get(RoleApplicatif.ENSEIGNANT).perimetre == PerimetreRoleApplicatifEnum.ALL_ETABLISSEMENTS

        and: "le role ADMINISTRATEUR ne concerne que l'établissement 1"
        rolesPerimetres.get(RoleApplicatif.ADMINISTRATEUR).etablissements == [etab1] as Set
        rolesPerimetres.get(RoleApplicatif.ADMINISTRATEUR).perimetre == PerimetreRoleApplicatifEnum.SEVERAL_ETABLISSEMENTS

        and: "le role ELEVE  concerne tous les établissements "
        rolesPerimetres.get(RoleApplicatif.ELEVE).etablissements == [etab1, etab2] as Set
        rolesPerimetres.get(RoleApplicatif.ELEVE).perimetre == PerimetreRoleApplicatifEnum.ALL_ETABLISSEMENTS

    }

    def "test de l'initialisation des rôles avec périmètre lorsque le rôle super-admin est imposé"() {

        given:"une personne qui est effectivement un super-admin"
        def personne = Mock(Personne)
        securiteSessionService.profilScolariteService = Mock(ProfilScolariteService) {
            personneEstAdministrateurCentral(personne) >> true
        }

        and:"un rôle applicatif imposé"
        def roleApplicatif = RoleApplicatif.SUPER_ADMINISTRATEUR

        when:"l'initialisation des rôles est délenchées avec le rôle imposé"
        securiteSessionService.initialiseRolesAvecPerimetreForPersonne(personne, roleApplicatif)

        then:"le current role applicatif est le role applicatif imposé"
        securiteSessionService.currentRoleApplicatif == roleApplicatif

        and:"le default role applicatif est le role applicatif imposé"
        securiteSessionService.defaultRoleApplicatif == roleApplicatif

        and:"la liste des établissements est vide"
        securiteSessionService.etablissementList.isEmpty()

        and:"la liste des rôles avec parametre contient une seule entrée avec le rôle imposé"
        securiteSessionService.rolesApplicatifsAndPerimetreByRoleApplicatif.size() == 1
        securiteSessionService.rolesApplicatifsAndPerimetreByRoleApplicatif.get(roleApplicatif)

    }

    def "test de l'initialisation des rôles avec périmètre lorsque le rôle super-admin est imposé sur une personne non super admin"() {

        given:"une personne qui n'est pas un super-admin"
        def personne = Mock(Personne)
        securiteSessionService.profilScolariteService = Mock(ProfilScolariteService) {
            personneEstAdministrateurCentral(personne) >> false
        }

        and:"un rôle applicatif imposé"
        def roleApplicatif = RoleApplicatif.SUPER_ADMINISTRATEUR

        when:"l'initialisation des rôles est délenchées avec le rôle imposé"
        securiteSessionService.initialiseRolesAvecPerimetreForPersonne(personne, roleApplicatif)

        then:"le current role applicatif est le role NO_ROLE"
        securiteSessionService.currentRoleApplicatif == RoleApplicatif.NO_ROLE

        and:"le default role applicatif est le role NO_ROLE"
        securiteSessionService.defaultRoleApplicatif == RoleApplicatif.NO_ROLE

        and:"la liste des établissements est vide"
        securiteSessionService.etablissementList.isEmpty()

        and:"la liste des rôles avec parametre contient une seule entrée avec le rôle NO_ROLE"
        securiteSessionService.rolesApplicatifsAndPerimetreByRoleApplicatif.size() == 1
        securiteSessionService.rolesApplicatifsAndPerimetreByRoleApplicatif.get(RoleApplicatif.NO_ROLE)

    }

    def "test de l'initialisation des rôles avec périmètre lorsque le rôle administrateur est imposé"() {

        given:"une personne administrant deux établissement"
        def personne = Mock(Personne)
        Etablissement etab1 = Mock(Etablissement)
        // hack pour mock sur objets "comparable"
        Etablissement etab2 = Mock(Etablissement) {
            compareTo(etab1) >> -1
        }
        etab1.compareTo(etab2) >> 1
        securiteSessionService.profilScolariteService = Mock(ProfilScolariteService) {
            findEtablissementsAdministresForPersonne(personne) >> [etab1, etab2]
        }

        and:"un rôle applicatif imposé"
        def roleApplicatif = RoleApplicatif.ADMINISTRATEUR

        when:"l'initialisation des rôles est délenchées avec le rôle imposé"
        securiteSessionService.initialiseRolesAvecPerimetreForPersonne(personne, roleApplicatif)

        then:"le current role applicatif est le role applicatif imposé"
        securiteSessionService.currentRoleApplicatif == roleApplicatif

        and:"le default role applicatif est le role applicatif imposé"
        securiteSessionService.defaultRoleApplicatif == roleApplicatif

        and:"la liste des rôles avec parametre contient une seule entrée avec le rôle imposé"
        securiteSessionService.rolesApplicatifsAndPerimetreByRoleApplicatif.size() == 1
        securiteSessionService.rolesApplicatifsAndPerimetreByRoleApplicatif.get(roleApplicatif)

        and:"la liste des établissements est non vide"
        securiteSessionService.etablissementList.size() == 2
        securiteSessionService.etablissementList.contains(etab1)
        securiteSessionService.etablissementList.contains(etab2)

    }

    def "test de l'initialisation des rôles avec périmètre lorsque le rôle administrateur est imposé sur une personne non administrateur"() {

        given:"une personne n'administrant aucun établissement"
        def personne = Mock(Personne)
        securiteSessionService.profilScolariteService = Mock(ProfilScolariteService) {
            findEtablissementsAdministresForPersonne(personne) >> []
        }

        and:"un rôle applicatif imposé"
        def roleApplicatif = RoleApplicatif.ADMINISTRATEUR

        when:"l'initialisation des rôles est délenchées avec le rôle imposé"
        securiteSessionService.initialiseRolesAvecPerimetreForPersonne(personne, roleApplicatif)

        then:"le current role applicatif est le role NO_ROLE"
        securiteSessionService.currentRoleApplicatif == RoleApplicatif.NO_ROLE

        and:"le default role applicatif est le role NO_ROLE"
        securiteSessionService.defaultRoleApplicatif == RoleApplicatif.NO_ROLE

        and:"la liste des rôles avec parametre contient une seule entrée avec le rôle NO_ROLE"
        securiteSessionService.rolesApplicatifsAndPerimetreByRoleApplicatif.size() == 1
        securiteSessionService.rolesApplicatifsAndPerimetreByRoleApplicatif.get(RoleApplicatif.NO_ROLE)

        and:"la liste des établissements est vide"
        securiteSessionService.etablissementList.size() == 0

    }

    def "test de l'initialisation des rôles avec périmètre lorsque un rôle non autorisé est imposé"() {

        given:"une personne administrant deux établissement"
        def personne = Mock(Personne)

        and:"un rôle applicatif imposé"
        def roleApplicatif = RoleApplicatif.ENSEIGNANT

        when:"l'initialisation des rôles est délenchées avec le rôle imposé"
        securiteSessionService.initialiseRolesAvecPerimetreForPersonne(personne, roleApplicatif)

        then:"une exception est levée"
        thrown(PreConditionException)

    }

    def "test de l'initialisation du role CD par config pour un user qui est effectivement un CD"() {
        given:"un user en registré comme CD dans la configuration"
        def autorite = Mock(DomainAutorite) {
            getIdentifiant() >> "idexterne1"
        }
        def utilisateur = Mock(Utilisateur) {
            getAutorite() >> autorite
        }
        CorrespondantDeploimentConfig.externalIds = ["idexterne1"]

        when:"l'initialisation de correspondant déploiement est déclenchée sur ce user"
        securiteSessionService.initialiseSecuriteSessionForCorrespondantDeploiment(utilisateur)

        then:"la session est correctement initialisée"
        securiteSessionService.rolesApplicatifsAndPerimetreByRoleApplicatif.size() == 1
        securiteSessionService.rolesApplicatifsAndPerimetreByRoleApplicatif.get(RoleApplicatif.SUPER_ADMINISTRATEUR)
        securiteSessionService.currentRoleApplicatif == RoleApplicatif.SUPER_ADMINISTRATEUR
        securiteSessionService.defaultRoleApplicatif == RoleApplicatif.SUPER_ADMINISTRATEUR

    }

    def "test de l'initialisation du role CD par config pour un user qui n'est pas un CD"() {
        given:"un user en registré comme CD dans la configuration"
        def autorite = Mock(DomainAutorite) {
            getIdentifiant() >> "idexterne1"
        }
        def utilisateur = Mock(Utilisateur) {
            getAutorite() >> autorite
        }
        CorrespondantDeploimentConfig.externalIds = ["idexterne2"]

        when:"l'initialisation de correspondant déploiement est déclenchée sur ce user"
        securiteSessionService.initialiseSecuriteSessionForCorrespondantDeploiment(utilisateur)

        then:"une exception est levée"
        thrown(PreConditionException)

    }

    @Unroll
    def "le role par défaut d'un utilisateur avec fonction #fct est #role"() {

        given: "une personne dans un établissement ayant une fonction"
        def pers = Mock(Personne)
        def etab = Mock(Etablissement)
        securiteSessionService.preferenceEtablissementService = Mock(PreferenceEtablissementService) {
            getMappingFonctionRoleForEtablissement(pers, etab) >> mappingFonctionRole
        }
        def fctsByEtab = new HashMap<Etablissement, Set<FonctionEnum>>()
        fctsByEtab.put(etab, [fct] as Set)
        securiteSessionService.profilScolariteService = Mock(ProfilScolariteService) {
            findEtablissementsAndFonctionsForPersonne(pers) >> fctsByEtab
        }

        when: "on initialise ses rôles"
        securiteSessionService.initialiseRolesAvecPerimetreForPersonne(pers)

        then: "le role par défaut est correctement associé"
        securiteSessionService.currentRoleApplicatif == role

        where:
        fct                         | role
        FonctionEnum.ELEVE          | RoleApplicatif.ELEVE
        FonctionEnum.DIR            | RoleApplicatif.ADMINISTRATEUR
        FonctionEnum.ENS            | RoleApplicatif.ENSEIGNANT
        FonctionEnum.PERS_REL_ELEVE | RoleApplicatif.PARENT
        FonctionEnum.DOC            | RoleApplicatif.ENSEIGNANT


    }


    private MappingFonctionRole getDefaultMappingFonctionRole() {
        new MappingFonctionRole(["ENS"           :
                                         ["ENSEIGNANT":
                                                  ["associe"   : true,
                                                   "modifiable": true],
                                          "ELEVE"     : ["associe"   : true,
                                                         "modifiable": true],
                                          "PARENT"    : ["associe"   : false,
                                                         "modifiable": false]
                                         ],
                                 "AL"            :
                                         ["ADMINISTRATEUR": ["associe"   : true,
                                                             "modifiable": true],
                                          "ENSEIGNANT"    :
                                                  ["associe"   : true,
                                                   "modifiable": true]
                                         ],
                                 "ELEVE"         :
                                         ["ELEVE"     : ["associe"   : true,
                                                         "modifiable": false],
                                          "ENSEIGNANT":
                                                  ["associe"   : true,
                                                   "modifiable": true]
                                         ],
                                 "DIR"           :
                                         ["ADMINISTRATEUR": ["associe"   : true,
                                                             "modifiable": true],
                                          "ENSEIGNANT"    :
                                                  ["associe"   : true,
                                                   "modifiable": true]
                                         ],
                                 "DOC"           :
                                         ["ELEVE"     : ["associe"   : true,
                                                         "modifiable": true],
                                          "ENSEIGNANT":
                                                  ["associe"   : true,
                                                   "modifiable": true]
                                         ],
                                 "PERS_REL_ELEVE":
                                         ["PARENT"    : ["associe"   : true,
                                                         "modifiable": false],
                                          "ENSEIGNANT":
                                                  ["associe"   : true,
                                                   "modifiable": true]
                                         ]
        ])
    }

}