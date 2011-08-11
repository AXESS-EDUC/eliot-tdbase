// configuration for plugin testing - will not be included in the plugin zip
 
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
           'org.codehaus.groovy.grails.plugins' // plugins
    warn   'org.codehaus.groovy.grails.orm.hibernate', // hibernate integration
           'org.springframework'
    warn   'org.hibernate'
           'net.sf.ehcache.hibernate'

    warn   'org.mortbay.log'
}

grails.plugin.databasemigration.changelogFileName =  "changelog.xml"
grails.plugin.databasemigration.updateOnStart = true
grails.plugin.databasemigration.updateOnStartFileNames = ['changelog.xml']

// cas is not activated by default
//grails.plugins.springsecurity.cas.active = false
//grails.plugins.springsecurity.cas.loginUri = '/login'
//grails.plugins.springsecurity.cas.serviceUrl = 'http://localhost:8080/your-app-name/j_spring_cas_security_check'
//grails.plugins.springsecurity.cas.serverUrlPrefix = 'https://your-cas-server/cas'
//grails.plugins.springsecurity.cas.proxyCallbackUrl = 'http://localhost:8080/your-app-name/secure/receptor'
//grails.plugins.springsecurity.cas.proxyReceptorUrl = '/secure/receptor'

// Added by the Spring Security Core plugin:
//grails.plugins.springsecurity.userLookup.userDomainClassName = 'org.lilie.services.eliot.tice.temp.User'
//grails.plugins.springsecurity.userLookup.authorityJoinClassName = 'org.lilie.services.eliot.tice.temp.UserRole'
//grails.plugins.springsecurity.authority.className = 'org.lilie.services.eliot.tice.temp.Role'
grails.views.default.codec="none" // none, html, base64
grails.views.gsp.encoding="UTF-8"
