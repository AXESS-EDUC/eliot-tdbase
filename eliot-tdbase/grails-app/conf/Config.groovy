import grails.plugins.springsecurity.SecurityConfigType
import org.lilie.services.eliot.tice.scolarite.FonctionEnum

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

// locations to search for config files that get merged into the main config
// config files can either be Java properties files or ConfigSlurper scripts

// grails.config.locations = [ "classpath:${appName}-config.properties",
//                             "classpath:${appName}-config.groovy",
//                             "file:${userHome}/.grails/${appName}-config.properties",
//                             "file:${userHome}/.grails/${appName}-config.groovy"]

// if(System.properties["${appName}.config.location"]) {
//    grails.config.locations << "file:" + System.properties["${appName}.config.location"]
// }

grails.project.groupId = appName // change this to alter the default package name and Maven publishing destination
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
        multipartForm: 'multipart/form-data'
]

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
  production {
    grails.serverURL = "http://www.changeme.com"
  }
  development {
    grails.serverURL = "http://localhost:8080/${appName}"
  }
  test {
    grails.serverURL = "http://localhost:8080/${appName}"
  }
  demo {
    grails.serverURL = "http://www.ticetime.com:8080/${appName}"
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

grails.plugin.databasemigration.changelogFileName = "changelog.xml"
grails.plugin.databasemigration.updateOnStart = false
grails.plugin.databasemigration.updateOnStartFileNames = ['changelog.xml']

grails.plugins.springsecurity.dao.reflectionSaltSourceProperty = 'username'
grails.plugins.springsecurity.securityConfigType = SecurityConfigType.InterceptUrlMap

// set per-environment security rbac
environments {
  production {
    grails.plugins.springsecurity.interceptUrlMap = [
            '/sujet/**': [
                    "${FonctionEnum.ENS.toRole()}",
                    "${FonctionEnum.DOC.toRole()}",
                    "${FonctionEnum.CTR.toRole()}",
                    "${FonctionEnum.DIR.toRole()}",
                    'IS_AUTHENTICATED_FULLY'
            ],
            '/question/**': [
                    "${FonctionEnum.ENS.toRole()}",
                    "${FonctionEnum.DOC.toRole()}",
                    "${FonctionEnum.CTR.toRole()}",
                    "${FonctionEnum.DIR.toRole()}",
                    'IS_AUTHENTICATED_FULLY'
            ],
            '/seance/**': [
                    "${FonctionEnum.ENS.toRole()}",
                    "${FonctionEnum.DOC.toRole()}",
                    "${FonctionEnum.CTR.toRole()}",
                    "${FonctionEnum.DIR.toRole()}",
                    'IS_AUTHENTICATED_FULLY'
            ]
    ]
  }
  demo {
    grails.plugins.springsecurity.interceptUrlMap = [
            '/sujet/**': [
                    "${FonctionEnum.ENS.toRole()}",
                    "${FonctionEnum.DOC.toRole()}",
                    "${FonctionEnum.CTR.toRole()}",
                    "${FonctionEnum.DIR.toRole()}",
                    'IS_AUTHENTICATED_FULLY'
            ],
            '/question/**': [
                    "${FonctionEnum.ENS.toRole()}",
                    "${FonctionEnum.DOC.toRole()}",
                    "${FonctionEnum.CTR.toRole()}",
                    "${FonctionEnum.DIR.toRole()}",
                    'IS_AUTHENTICATED_FULLY'
            ],
            '/seance/**': [
                    "${FonctionEnum.ENS.toRole()}",
                    "${FonctionEnum.DOC.toRole()}",
                    "${FonctionEnum.CTR.toRole()}",
                    "${FonctionEnum.DIR.toRole()}",
                    'IS_AUTHENTICATED_FULLY'
            ]
    ]
  }
  development {
    grails.plugins.springsecurity.interceptUrlMap = [
            '/sujet/**': [
                    "${FonctionEnum.ENS.toRole()}",
                    "${FonctionEnum.DOC.toRole()}",
                    "${FonctionEnum.CTR.toRole()}",
                    "${FonctionEnum.DIR.toRole()}",
                    'IS_AUTHENTICATED_REMEMBERED'
            ],
            '/question/**': [
                    "${FonctionEnum.ENS.toRole()}",
                    "${FonctionEnum.DOC.toRole()}",
                    "${FonctionEnum.CTR.toRole()}",
                    "${FonctionEnum.DIR.toRole()}",
                    'IS_AUTHENTICATED_REMEMBERED'
            ],
            '/seance/**': [
                    "${FonctionEnum.ENS.toRole()}",
                    "${FonctionEnum.DOC.toRole()}",
                    "${FonctionEnum.CTR.toRole()}",
                    "${FonctionEnum.DIR.toRole()}",
                    'IS_AUTHENTICATED_REMEMBERED'
            ]
    ]
  }
  test {
    grails.plugins.springsecurity.interceptUrlMap = [
            '/sujet/**': [
                    "${FonctionEnum.ENS.toRole()}",
                    "${FonctionEnum.DOC.toRole()}",
                    "${FonctionEnum.CTR.toRole()}",
                    "${FonctionEnum.DIR.toRole()}",
                    'IS_AUTHENTICATED_REMEMBERED'
            ],
            '/question/**': [
                    "${FonctionEnum.ENS.toRole()}",
                    "${FonctionEnum.DOC.toRole()}",
                    "${FonctionEnum.CTR.toRole()}",
                    "${FonctionEnum.DIR.toRole()}",
                    'IS_AUTHENTICATED_REMEMBERED'
            ],
            '/seance/**': [
                    "${FonctionEnum.ENS.toRole()}",
                    "${FonctionEnum.DOC.toRole()}",
                    "${FonctionEnum.CTR.toRole()}",
                    "${FonctionEnum.DIR.toRole()}",
                    'IS_AUTHENTICATED_REMEMBERED'
            ]
    ]
  }

  // configuration de la racine de l'espace de fichier
  environments {
    development {
      eliot.fichiers.racine = "/Users/Shared/eliot-root"
      eliot.fichiers.maxsize.mega = 10
    }
    demo {
      eliot.fichiers.racine = "/usr/share/eliot-root"
      eliot.fichiers.maxsize.mega = 10
    }
  }

}


