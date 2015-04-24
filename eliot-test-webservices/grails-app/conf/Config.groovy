import org.lilie.services.eliot.tice.utils.EliotApplicationEnum
import org.lilie.services.eliot.tice.utils.UrlServeurResolutionEnum

// Fichier charge si present dans le classpath : utile pour déploiement
// d'une application de démonstration après téléchargement
grails.config.locations = ["classpath:${appName}-config.groovy"]


// Fichier de configuration externe propre à l'application
def appConfigLocation = System.properties["${appName}.config.location"]
if (appConfigLocation) {
    grails.config.locations << "file:" + appConfigLocation
}


grails.project.groupId = appName // change this to alter the default package name and Maven publishing destination
//    grails.config.locations << "file:" + System.properties["${appName}.config.location"]
grails.mime.file.extensions = true // enables the parsing of file extensions from URLs into the request format
grails.mime.use.accept.header = false
grails.mime.types = [ html: ['text/html','application/xhtml+xml'],
                      xml: ['text/xml', 'application/xml'],
                      text: 'text/plain',
                      js: 'text/javascript',
                      rss: 'application/rss+xml',
                      atom: 'application/atom+xml',
                      css: 'text/css',
                      csv: 'text/csv',
                      all: '*/*',
                      json: ['application/json','text/json'],
                      form: 'application/x-www-form-urlencoded',
                      multipartForm: 'multipart/form-data'
                    ]

// Paramétrage requis par eliot-tice-plugin
        eliot.eliotApplicationEnum = EliotApplicationEnum.NOT_AN_APPLICATION
        eliot.requestHeaderPorteur = "ENT_PORTEUR"
        eliot.not_an_application.nomApplication = "TicePlugin"
        eliot.urlResolution.mode = UrlServeurResolutionEnum.ANNUAIRE_PORTEUR.name()
        //eliot.urlResolution.mode = UrlServeurResolutionEnum.CONFIGURATION.name()
        //eliot.not_an_application.urlServeur = "http//localhost:8080"
        eliot.fichiers.racine = "/tmp"

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

// URL Mapping Cache Max Size, defaults to 5000
//grails.urlmapping.cache.maxsize = 1000

// What URL patterns should be processed by the resources plugin
grails.resources.adhoc.patterns = ['/images/*', '/css/*', '/js/*', '/plugins/*']


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
// packages to include in Spring bean scanning
grails.spring.bean.packages = []
// whether to disable processing of multi part requests
grails.web.disable.multipart=false

// request parameters to mask when logging exceptions
grails.exceptionresolver.params.exclude = ['password']

// enable query caching by default
grails.hibernate.cache.queries = true

// set per-environment serverURL stem for creating absolute links
environments {
    development {
        grails.logging.jul.usebridge = true
    }
    production {
        grails.logging.jul.usebridge = false
        // grails.serverURL = "http://www.changeme.com"
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

    error  'org.codehaus.groovy.grails.web.servlet',  //  controllers
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
}
