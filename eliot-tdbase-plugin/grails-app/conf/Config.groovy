import org.lilie.services.eliot.tice.utils.EliotApplicationEnum
import org.lilie.services.eliot.tice.utils.UrlServeurResolutionEnum

// configuration for plugin testing - will not be included in the plugin zip

// Fichier charge si present dans le classpath : utile pour déploiement
// d'une application de démonstration après téléchargement
grails.config.locations = ["classpath:${appName}-config.groovy"]

// Fichier de configuration externe commun à toutes les applications Eliot
def eliotcommonsConfigLocation = System.properties["eliot-commons.config.location"]
if (eliotcommonsConfigLocation) {
    grails.config.locations << ("file:" + eliotcommonsConfigLocation)
}

// Fichier de configuration externe propre à l'application
def appConfigLocation = System.properties["${appName}.config.location"]
if (appConfigLocation) {
    grails.config.locations << "file:" + appConfigLocation
}

log4j = {
    // Example of changing the log pattern for the default console
    // appender:
    //
    //appenders {
    //    console name:'stdout', layout:pattern(conversionPattern: '%c{2} %m%n')
    //}

    error 'org.codehaus.groovy.grails.web.servlet',  //  controllers
            'org.codehaus.groovy.grails.web.pages', //  GSP
            'org.codehaus.groovy.grails.web.sitemesh', //  layouts
            'org.codehaus.groovy.grails.web.mapping.filter', // URL mapping
            'org.codehaus.groovy.grails.web.mapping', // URL mapping
            'org.codehaus.groovy.grails.commons', // core / classloading
            'org.codehaus.groovy.grails.plugins', // plugins
            'org.codehaus.groovy.grails.orm.hibernate', // hibernate integration
            'org.springframework',
            'org.hibernate',
            'net.sf.ehcache.hibernate'

    warn 'org.mortbay.log'
}
grails.views.default.codec = "none" // none, html, base64
grails.views.gsp.encoding = "UTF-8"

environments {
    test {
        eliot.fichiers.racine = "/tmp"
        eliot.eliotApplicationEnum = EliotApplicationEnum.NOT_AN_APPLICATION
        eliot.requestHeaderPorteur = "ENT_PORTEUR"
        eliot.not_an_application.nomApplication = "TdbasePlugin"
        eliot.urlResolution.mode = UrlServeurResolutionEnum.ANNUAIRE_PORTEUR.name()

        eliot.interfacage.strongCheck = false
        // rest client config for textes
        eliot.webservices.rest.client.textes.user = "api"
        eliot.webservices.rest.client.textes.password = "api"
        eliot.webservices.rest.client.textes.urlServer = "http://localhost:8090"
        eliot.webservices.rest.client.textes.uriPrefix = "/eliot-test-webservices/echanges/v2"
        // rest client config for notes
        eliot.webservices.rest.client.notes.user = "eliot-tdbase"
        eliot.webservices.rest.client.notes.password = "eliot-tdbase"
        eliot.webservices.rest.client.notes.urlServer = "http://localhost:8090"
        eliot.webservices.rest.client.notes.uriPrefix = "/eliot-test-webservices/api-rest/v2"
        // rest client config for scolarite
        eliot.webservices.rest.client.scolarite.user = "api"
        eliot.webservices.rest.client.scolarite.password = "api"
        eliot.webservices.rest.client.scolarite.urlServer = "http://localhost:8090"
        eliot.webservices.rest.client.scolarite.uriPrefix = "/eliot-test-webservices/api-rest/v2"
        eliot.webservices.rest.client.scolarite.connexionTimeout = 10000

        // rest client config for notification
        eliot.webservices.rest.client.notification.user = "api"
        eliot.webservices.rest.client.notification.password = "api"
        eliot.webservices.rest.client.notification.urlServer = "http://localhost:8090"
        eliot.webservices.rest.client.notification.uriPrefix = "/eliot-test-webservices/echanges/v2"
        eliot.webservices.rest.client.notification.connexionTimeout = 10000

        // Support de l'interface EmaEval
        eliot.interfacage.emaeval.actif = false
        eliot.interfacage.emaeval.url = "https://emaeval.pentila.com/EvalComp/webservices/"
        eliot.interfacage.emaeval.referentiel.nom = "Palier 3"
        eliot.interfacage.emaeval.plan.nom = "Plan TDBase"
        eliot.interfacage.emaeval.scenario.nom = "Evaluation directe"
        eliot.interfacage.emaeval.methodeEvaluation.nom = "Methode d'évaluation"
        // Note : je ne comprends pas pourquoi la méthode n'a pas pour nom "Méthode d'évaluation booléenne" ...

        /**
         * Définit les couples <RoleApplicatif, FonctionEnum> qui sont associés par défaut
         * Cette configuration est utilisée pour généré le paramétrage initial de TD Base pour
         * un établissement qui pourra ensuite être modifié par les utilisateurs disposant du
         * rôle applicatif ADMINISTRATEUR
         */
        def mappingFonctionRoleDefaut = [
                "ENSEIGNANT"          : ["ENS", "CD"],
                "ELEVE"               : ["ELEVE"],
                "PARENT"              : ["PERS_REL_ELEVE"],
                "ADMINISTRATEUR"      : ["DIR", "AL"],
                "SUPER_ADMINISTRATEUR": ["CD"]
        ]

/**
 * Définit les couples <RoleApplicatif, FonctionEnum> qui sont modifiables par les
 * administrateurs
 *
 * La clé 'défault' peut être utilisée pour définir une règle par défaut qui
 * s'applique lorsque la règle n'a pas été explicitement définie pour un RoleApplicatif
 * ou un FonctionEnum
 */
        def liaisonFonctionRoleModifiable = [
                "ENSEIGNANT": [
                        "ENS"    : false,
                        "DOC"    : false,
                        "default": true
                ],
                "ELEVE"     : [
                        "ELEVE"  : false,
                        "default": true
                ],
                "default"   : [
                        "default": false
                ]
        ]


        eliot.tdbase.mappingFonctionRole.defaut = mappingFonctionRoleDefaut
        eliot.tdbase.mappingFonctionRole.modifiable = liaisonFonctionRoleModifiable
    }
}