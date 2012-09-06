import grails.plugins.springsecurity.SecurityConfigType
import groovyx.net.http.ContentType
import groovyx.net.http.Method
import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.lilie.services.eliot.tice.utils.EliotApplicationEnum
import org.lilie.services.eliot.tice.utils.UrlServeurResolutionEnum

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

//
//  L'application enum  et le nom du header indentifiant le porteur
//
eliot.eliotApplicationEnum = EliotApplicationEnum.TDBASE
eliot.requestHeaderPorteur = "ENT_PORTEUR"
eliot.defaultCodePorteur = "CRIF"

/**
 * Chargement des configurations externalisées
 */

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

// config générale
grails.resources.adhoc.patterns = ['/images/*', '/css/*', '/js/*', '/plugins/*']
grails.project.groupId = "org.lilie.services.eliot" // change this to alter the default package name and Maven publishing destination
grails.mime.file.extensions = true // enables the parsing of file extensions from URLs into the request format
grails.mime.use.accept.header = false
grails.mime.types = [html: ['text/html', 'application/xhtml+xml'],
        xml: ['text/xml', 'application/xml'],
        text: 'text/plain',
        js: 'text/javascript',
        rss: 'application/rss+xml',
        atom: 'application/atom+xml',
        css: 'text/css',
        csv: 'text/csv',
        all: '*/*',
        json: ['application/json', 'text/json'],
        form: 'application/x-www-form-urlencoded',
        multipartForm: 'multipart/form-data']

// URL Mapping Cache Max Size, defaults to 5000
//grails.urlmapping.cache.maxsize = 1000

// The default codec used to encode data with ${}
grails.views.default.codec = "none" // none, html, base64
grails.views.gsp.encoding = "UTF-8"
grails.converters.encoding = "UTF-8"
// enable Sitemesh preprocessing of GSP pages
grails.views.gsp.sitemesh.preprocess = true
// scaffolding templates configuration
grails.scaffolding.templates.domainSuffix = 'Instance'

// Set to false to use the new Grails 1.2 JSONBuilder in the render method
grails.json.legacy.builder = false
// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true
// whether to install the java.util.logging bridge for sl4j. Disable for AppEngine!
grails.logging.jul.usebridge = true
// packages to include in Spring bean scanning
grails.spring.bean.packages = []

// request parameters to mask when logging exceptions
grails.exceptionresolver.params.exclude = ['password']

// log4j configuration
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

  info 'grails.app'

  debug 'org.lilie.services.eliot.tice.webservices.rest.client.RestClient'

}

grails.controllers.defaultScope = "session"

grails.serverURL = "http://localhost:8080/${appName}"
eliot.tdbase.nomApplication = "eliot-tdbase"
eliot.urlResolution.mode = UrlServeurResolutionEnum.CONFIGURATION.name()
eliot.tdbase.urlServeur = "http//localhost:8080"

grails.plugins.springsecurity.dao.reflectionSaltSourceProperty = 'username'
grails.plugins.springsecurity.securityConfigType = SecurityConfigType.InterceptUrlMap
grails.plugins.springsecurity.errors.login.fail = "errors.login.fail"

// set security rbac
//
grails.plugins.springsecurity.interceptUrlMap = ['/': ['IS_AUTHENTICATED_FULLY'],
        '/p/**': ['IS_AUTHENTICATED_FULLY'],
        '/dashboard/**': ["${FonctionEnum.ENS.toRole()}",
                'IS_AUTHENTICATED_FULLY'],
        '/sujet/**': ["${FonctionEnum.ENS.toRole()}",
                'IS_AUTHENTICATED_FULLY'],
        '/question/**': ["${FonctionEnum.ENS.toRole()}",
                'IS_AUTHENTICATED_FULLY'],
        '/seance/**': ["${FonctionEnum.ENS.toRole()}",
                'IS_AUTHENTICATED_FULLY'],
        '/activite/**': ["${FonctionEnum.ELEVE.toRole()}",
                'IS_AUTHENTICATED_FULLY'],
        '/resultats/**': ["${FonctionEnum.PERS_REL_ELEVE.toRole()}",
                'IS_AUTHENTICATED_FULLY'],
        '/maintenance/**': ["${FonctionEnum.CD.toRole()}",
                'IS_AUTHENTICATED_FULLY']]

// l'interfacage doit il effectuer des contrôles fort sur les "pseudo
// clés étrangères"
eliot.interfacage.strongCheck = true

//  support de l'interfaçage eliot-notes
//
eliot.interfacage.notes = true

//  support de l'interfaçage eliot-textes
//
eliot.interfacage.textes = true

// le nombre d'éléments max à afficher dans une liste de résultat
eliot.listes.maxrecherche = 5
eliot.listes.max = 7

// les dimensions de div continer à prendre en compte si nécessaire
eliot.pages.container.forceDimensions = false
// hauteur en pixel : ne s'applique que si forceDimensions est à true
eliot.pages.container.height = 629
// largeur en pixel : ne s'applique que si forceDimensions est à true
eliot.pages.container.width = 931

// l'url des fichiers de documentation par fonction
eliot.manuels.documents.urlMap = ["${FonctionEnum.ENS.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "${FonctionEnum.ELEVE.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Eleve/content/index.html",
        "${FonctionEnum.PERS_REL_ELEVE.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Parent/content/index.html"]

// les ressources JS et Applet Java Jmol sont recherchées dans l'URI
// relative au serveur Grails (l'URI doit commencer par '/'):
eliot.jmol.resourcesURI = "/js/lib/jmol/"

// les operations de webservices
//
eliot.webservices.rest.client.operations = [[operationName: "getStructureChapitresForCahierId",
        description: "Retourne la liste arborescente de chapitres d'un cahier",
        contentType: ContentType.JSON,
        method: Method.GET,
        requestBodyTemplate: null,
        responseContentStructure: "eliot-textes#chapitres#structure-chapitres",
        //urlServer: "http://localhost:8090",
        uriTemplate: '/cahiers/$cahierId/chapitres'],
        [operationName: "findCahiersByStructureAndEnseignant",
                description: "Retourne la liste des cahiers pour une structure et un enseignant donné",
                contentType: ContentType.JSON,
                method: Method.GET,
                requestBodyTemplate: null,
                responseContentStructure: "PaginatedList<eliot-textes#cahiers-service#standard>",
                //urlServer: "http://localhost:8090",
                uriTemplate: '/cahiers-service'],
        [operationName: "createTextesActivite",
                description: "Insert une activité dans un cahier de textes",
                contentType: ContentType.JSON,
                method: Method.POST,
                requestBodyTemplate: '''
                                            {
                                            "kind" : "eliot-textes#activite-interactive#insert",
                                            "titre" : "$titre",
                                            "chapitre-parent-id" : $chapitreId,
                                            "date-debut" : "$dateDebutActivite",
                                            "date-fin" : "$dateFinActivite",
                                            "contexte-activite" : "$contexteActivite",
                                            "description" : "$description",
                                            "ressource-interactive-url" : "$urlSeance"
                                            }
                                            ''',
                responseContentStructure: "PaginatedList<eliot-textes#cahiers-service#standard>",
                //urlServer: "http://localhost:8090",
                uriTemplate: '/cahiers/$cahierId/activites-interactives'],
        [operationName: "findServicesEvaluablesByStrunctureAndDateAndEnseignant",
                description: "Retourne la liste des services pour une structure, une date et un enseignant donné",
                contentType: ContentType.JSON,
                method: Method.GET,
                requestBodyTemplate: null,
                responseContentStructure: "List<eliot-notes#evaluation-contextes#standard>",
                //urlServer: "http://localhost:8090",
                uriTemplate: '/evaluation-contextes.json'],
        [operationName: "createDevoir",
                description: "Insert un devoir dans le module Notes",
                contentType: ContentType.JSON,
                method: Method.POST,
                requestBodyTemplate: '''
                                  {
                                  "kind" : "eliot-notes#evaluation#insert",
                                  "titre" : "$titre",
                                  "date" : "$date",
                                  "note-max" : $noteMax,
                                  "evaluation-contexte-id" : "$serviceId",
                                   }
                                   ''',
                responseContentStructure: "eliot-notes#evaluation#id>",
                //urlServer: "http://localhost:8090",
                uriTemplate: '/evaluations'],
        [operationName: "updateNotes",
                description: "Met à jour les notes d'un devoir dans le module Notes",
                contentType: ContentType.JSON,
                method: Method.PUT,
                requestBodyTemplate: '''
                                 {
                                 "kind" : "eliot-notes#evaluation-notes#standard",
                                 "notes": $notesJson
                                 }
                                 ''',
                responseContentStructure: "eliot-notes#evaluation#id>",
                //urlServer: "http://localhost:8090",
                uriTemplate: '/evaluations/$evaluationId/notes.json']]

environments {
  test {
    eliot.fichiers.racine = '/tmp'
    eliot.tdbase.nomApplication = "eliot-tdbase"
    eliot.urlResolution.mode = UrlServeurResolutionEnum.ANNUAIRE_PORTEUR.name()
    //eliot.urlResolution.mode = UrlServeurResolutionEnum.CONFIGURATION.name()
    //eliot.tdbase.urlServeur = "http//localhost:8080"

    // Spécifie si les objets sensés être créés sont bien créés
    // à n'activier que si les données tdbase, notes et textes sont stockées dans
    // la même base

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

  }
  development {
    grails.plugins.springsecurity.interceptUrlMap = ['/': ['IS_AUTHENTICATED_FULLY'],
            '/p/**': ['IS_AUTHENTICATED_FULLY'],
            '/dashboard/**': ["${FonctionEnum.ENS.toRole()}",
                    'IS_AUTHENTICATED_FULLY'],
            '/sujet/**': ["${FonctionEnum.ENS.toRole()}",
                    'IS_AUTHENTICATED_FULLY'],
            '/question/**': ["${FonctionEnum.ENS.toRole()}",
                    'IS_AUTHENTICATED_FULLY'],
            '/seance/**': ["${FonctionEnum.ENS.toRole()}",
                    'IS_AUTHENTICATED_FULLY'],
            '/activite/**': ["${FonctionEnum.ELEVE.toRole()}",
                    'IS_AUTHENTICATED_FULLY'],
            '/resultats/**': ["${FonctionEnum.PERS_REL_ELEVE.toRole()}",
                    'IS_AUTHENTICATED_FULLY']]

    eliot.tdbase.nomApplication = "eliot-tdbase"
    eliot.urlResolution.mode = UrlServeurResolutionEnum.ANNUAIRE_PORTEUR.name()
    //eliot.urlResolution.mode = UrlServeurResolutionEnum.CONFIGURATION.name()
    //eliot.tdbase.urlServeur = "http//localhost:8080"
    // autorise l'identification via url get
    grails.plugins.springsecurity.apf.postOnly = false
    // application de la migration  définie dans eliot-tice-dbmigration
    eliot.bootstrap.migration = true
    // creation d'un jeu de test
    eliot.bootstrap.jeudetest = true
    // configuration de la racine de l'espace de fichier
    eliot.fichiers.storedInDatabase = true
    eliot.fichiers.racine = '/Users/Shared/eliot-root'
    eliot.fichiers.maxsize.mega = 10
    // configuration des liens du menu portail et des annonces portail
    eliot.portail.menu.affichage = true
    eliot.portail.menu.liens = [[url: "http://www.ticetime.com",
            libelle: "ticetime"],
            [url: "https://github.com/ticetime/eliot-tdbase/wiki",
                    libelle: "eliot-tdbase sur Github"]]
    eliot.portail.news = ["TD Base version ${appVersion} - environnement DEV.",
            "Le projet est disponible sur <a href=\"https://github.com/ticetime/eliot-tdbase/wiki\" target=\"_blank\">Github</a> !",
            "Login / mot de passe enseignant : ens1 / ens1",
            "Login / mot de passe élève 1 : elv1 / elv1",
            "Login / mot de passe élève 2 : elv2 / elv2",
            "Login / mot de passe parent 1 : resp1 / resp1"]

    // Spécifie si les objets sensés être créés sont bien créés
    // à n'activier que si les données tdbase, notes et textes sont stockées dans
    // la même base
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

  }
  cf {
    grails.serverURL = "http://eliot-tdbase.cloudfoundry.com"
    eliot.tdbase.urlServeur = "http://eliot-tdbase.cloudfoundry.com"
    eliot.tdbase.nomApplication = "eliot-tdbase"
    eliot.urlResolution.mode = UrlServeurResolutionEnum.CONFIGURATION.name()
    eliot.tdbase.urlServeur = "http//eliot-tdbase.cloudfoundry.com"


    grails.plugins.springsecurity.interceptUrlMap = ['/': ['IS_AUTHENTICATED_FULLY'],
            '/p/**': ['IS_AUTHENTICATED_FULLY'],
            '/dashboard/**': ["${FonctionEnum.ENS.toRole()}",
                    'IS_AUTHENTICATED_FULLY'],
            '/sujet/**': ["${FonctionEnum.ENS.toRole()}",
                    'IS_AUTHENTICATED_FULLY'],
            '/question/**': ["${FonctionEnum.ENS.toRole()}",
                    'IS_AUTHENTICATED_FULLY'],
            '/seance/**': ["${FonctionEnum.ENS.toRole()}",
                    'IS_AUTHENTICATED_FULLY'],
            '/activite/**': ["${FonctionEnum.ELEVE.toRole()}",
                    'IS_AUTHENTICATED_FULLY'],
            '/resultats/**': ["${FonctionEnum.PERS_REL_ELEVE.toRole()}",
                    'IS_AUTHENTICATED_FULLY']]

    // autorise l'identification via url get
    grails.plugins.springsecurity.apf.postOnly = false
    // application de la migration  définie dans eliot-tice-dbmigration
    eliot.bootstrap.migration = true
    // creation d'un jeu de test
    eliot.bootstrap.jeudetest = true
    // configuration de la racine de l'espace de fichier
    eliot.fichiers.storedInDatabase = true
    eliot.fichiers.racine = '/Users/Shared/eliot-root'
    eliot.fichiers.maxsize.mega = 10
    // configuration des liens du menu portail et des annonces portail
    eliot.portail.menu.affichage = true
    eliot.portail.menu.liens = [[url: "http://www.ticetime.com",
            libelle: "ticetime"],
            [url: "https://github.com/ticetime/eliot-tdbase/wiki",
                    libelle: "eliot-tdbase sur Github"]]

    eliot.portail.news = ["TDBase v2.0.4-SNAPSHOT on Cloudfoundry.",
            "Le projet est disponible sur <a href=\"https://github.com/ticetime/eliot-tdbase/wiki\" target=\"_blank\">Github</a> !",
            "Login / mot de passe enseignant : ens1 / ens1",
            "Login / mot de passe élève 1 : elv1 / elv1",
            "Login / mot de passe élève 2 : elv2 / elv2",
            "Login / mot de passe parent 1 : resp1 / resp1"]


    // Spécifie si les objets sensés être créés sont bien créés
    // à n'activier que si les données tdbase, notes et textes sont stockées dans
    // la même base
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

  }
  testlilie {
    eliot.tdbase.nomApplication = "eliot-tdbase"
    eliot.urlResolution.mode = UrlServeurResolutionEnum.CONFIGURATION.name()
    eliot.tdbase.urlServeur = "http//localhost:8080"
    // determine si eliot-tdbase doit s'executer en mode intégration Lilie
    eliot.portail.lilie = true
    eliot.portail.lilieCasActive = true
    eliot.portail.continueAfterUnsuccessfullCasLilieAuthentication = true

    // application de la migration  définie dans eliot-tice-dbmigration
    eliot.bootstrap.migration = false

    // configuration de la racine de l'espace de fichier
    eliot.fichiers.racine = '/Users/Shared/eliot-root'
    eliot.fichiers.maxsize.mega = 10
    // configuration des liens du menu portail et des annonces portail
    eliot.portail.menu.affichage = true
    eliot.portail.menu.liens = [[url: "http://www.ticetime.com",
            libelle: "ticetime"],
            [url: "https://github.com/ticetime/eliot-tdbase/wiki",
                    libelle: "eliot-tdbase sur Github"]]
    eliot.portail.news = ["TDBase version ${appVersion} - environnement TESTLILIE ",
            "Login / mot de passe : voir base de test eliot/lilie",
            "Pierre Baudet : UT110000000000005027"]

    // Spécifie si les objets sensés être créés sont bien créés
    // à n'activier que si les données tdbase, notes et textes sont stockées dans
    // la même base
    eliot.interfacage.strongCheck = false
    // rest client config for textes
    eliot.webservices.rest.client.textes.user = "api"
    eliot.webservices.rest.client.textes.password = "api"
    eliot.webservices.rest.client.textes.urlServer = "http://fylab02.dns-oid.com:8380"
    eliot.webservices.rest.client.textes.uriPrefix = "/eliot-textes-2.8.2-A1/echanges/v2"
    eliot.webservices.rest.client.textes.connexionTimeout = 10000 // ms
    // rest client config for notes
    eliot.webservices.rest.client.notes.user = "api"
    eliot.webservices.rest.client.notes.password = "api"
    eliot.webservices.rest.client.notes.urlServer = "http://fylab02.dns-oid.com:8380"
    eliot.webservices.rest.client.notes.uriPrefix = "/eliot-notes-2.8.2-A1/echanges/v2"
    eliot.webservices.rest.client.notes.connexionTimeout = 10000 // ms
  }

}


