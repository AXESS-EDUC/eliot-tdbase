import grails.plugins.springsecurity.SecurityConfigType
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

// set per-environment serverURL stem for creating absolute links
environments {
  development {
    grails.serverURL = "http://localhost:8080/${appName}"
  }
  test {
    grails.serverURL = "http://localhost:8080/${appName}"
  }
  testlilie {
    grails.serverURL = "http://localhost:8080/${appName}"
  }
}

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
}

grails.controllers.defaultScope = "session"


grails.plugins.springsecurity.dao.reflectionSaltSourceProperty = 'username'
grails.plugins.springsecurity.securityConfigType = SecurityConfigType.InterceptUrlMap
grails.plugins.springsecurity.errors.login.fail = "errors.login.fail"



// set security rbac
//
grails.plugins.springsecurity.interceptUrlMap = ['/': ['IS_AUTHENTICATED_FULLY'],
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
eliot.pages.container.forceDimensions = true
// hauteur en pixel : ne s'applique que si forceDimensions est à true
eliot.pages.container.height = 629
// largeur en pixel : ne s'applique que si forceDimensions est à true
eliot.pages.container.width = 931

// l'url des fichiers de documentation par fonction
eliot.manuels.documents.urlMap = ["${FonctionEnum.ENS.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "${FonctionEnum.ELEVE.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Eleve/content/index.html",
        "${FonctionEnum.PERS_REL_ELEVE.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Parent/content/index.html"]


// l'UR du serveur web hébergeant Jmol
// les ressources JS et Applet Java Jmol sont recherchées dans l'URI 'js/lib/jmol'
// relative au serveur Web hébergeant Jmol :
eliot.jmol.serverURL="${grails.serverURL}"

environments {
  test {
    grails.plugins.springsecurity.cas.active = false
    eliot.fichiers.racine = '/tmp'
    eliot.tdbase.nomApplication = "eliot-tdbase"
    eliot.urlResolution.mode = UrlServeurResolutionEnum.ANNUAIRE_PORTEUR.name()
    //eliot.urlResolution.mode = UrlServeurResolutionEnum.CONFIGURATION.name()
    //eliot.tdbase.urlServeur = "http//localhost:8080"
  }
  development {
    grails.plugins.springsecurity.interceptUrlMap = ['/': ['IS_AUTHENTICATED_FULLY'],
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

    grails.plugins.springsecurity.cas.active = false
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
    eliot.fichiers.racine = '/Users/Shared/eliot-root'
    eliot.fichiers.maxsize.mega = 10
    // configuration des liens du menu portail et des annonces portail
    eliot.portail.menu.affichage = true
    eliot.portail.menu.liens = [[url: "http://wwww.ticetime.com",
            libelle: "ticetime"],
            [url: "https://github.com/ticetime/eliot-tdbase/wiki",
                    libelle: "eliot-tdbase sur Github"]]
    eliot.portail.news = ["Environnement DEVELOPPEMENT",
            "Le projet est disponible sur <a href=\"https://github.com/ticetime/eliot-tdbase/wiki\" target=\"_blank\">Github</a> !",
            "Login / mot de passe enseignant : ens1 / ens1",
            "Login / mot de passe élève 1 : elv1 / elv1",
            "Login / mot de passe élève 2 : elv2 / elv2",
            "Login / mot de passe parent 1 : resp1 / resp1"]
  }
  testlilie {
    eliot.tdbase.nomApplication = "eliot-tdbase"
    eliot.urlResolution.mode = UrlServeurResolutionEnum.CONFIGURATION.name()
    eliot.tdbase.urlServeur = "http//localhost:8080"
    // determine si eliot-tdbase doit s'executer en mode intégration Lilie
    eliot.portail.lilie = true
    // cas is not activated by default
    grails.plugins.springsecurity.cas.active = true
    grails.plugins.springsecurity.cas.loginUri = '/login'
    grails.plugins.springsecurity.cas.serviceUrl = "http://localhost:8080/${appName}/j_spring_cas_security_check"
    grails.plugins.springsecurity.cas.serverUrlPrefix = 'http://localhost:8181/cas-server-webapp-3.4.11'
    grails.plugins.springsecurity.cas.proxyCallbackUrl = "http://localhost:8080/${appName}/secure/receptor"
    grails.plugins.springsecurity.cas.proxyReceptorUrl = '/secure/receptor'

    // application de la migration  définie dans eliot-tice-dbmigration
    eliot.bootstrap.migration = true

    // configuration de la racine de l'espace de fichier
    eliot.fichiers.racine = '/Users/Shared/eliot-root'
    eliot.fichiers.maxsize.mega = 10
    // configuration des liens du menu portail et des annonces portail
    eliot.portail.menu.affichage = true
    eliot.portail.menu.liens = [[url: "http://wwww.ticetime.com",
            libelle: "ticetime"],
            [url: "https://github.com/ticetime/eliot-tdbase/wiki",
                    libelle: "eliot-tdbase sur Github"]]
    eliot.portail.news = ["Environnement TESTLILIE",
            "Login / mot de passe : voir base de test eliot/lilie"]
  }
  production {
    // paramètres par defaut de CAS
    grails.plugins.springsecurity.cas.active = true
    grails.plugins.springsecurity.cas.useSingleSignout = true
  }
}


