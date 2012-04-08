import org.lilie.services.eliot.tice.utils.EliotApplicationEnum
import org.lilie.services.eliot.tice.utils.UrlServeurResolutionEnum

// configuration for plugin testing - will not be included in the plugin zip

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
        'org.codehaus.groovy.grails.plugins' // plugins
  warn 'org.codehaus.groovy.grails.orm.hibernate', // hibernate integration
       'org.springframework'
  warn 'org.hibernate'
  'net.sf.ehcache.hibernate'

  warn 'org.mortbay.log'
}


grails.views.default.codec = "none" // none, html, base64
grails.views.gsp.encoding = "UTF-8"

environments {
  test {
    eliot.eliotApplicationEnum = EliotApplicationEnum.NOT_AN_APPLICATION
    eliot.requestHeaderPorteur = "ENT_PORTEUR"
    eliot.not_an_application.nomApplication = "TicePlugin"
    eliot.urlResolution.mode = UrlServeurResolutionEnum.ANNUAIRE_PORTEUR.name()
    //eliot.urlResolution.mode = UrlServeurResolutionEnum.CONFIGURATION.name()
    //eliot.not_an_application.urlServeur = "http//localhost:8080"
    eliot.fichiers.racine = "/tmp"
  }
}
