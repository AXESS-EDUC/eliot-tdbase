grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"
//grails.project.war.file = "target/${appName}-${appVersion}.war"

grails.plugin.location.'eliot-tice-plugin' = "../eliot-tice-plugin"


grails.project.dependency.resolution = {
  // inherit Grails' default dependencies
  inherits("global") {
    // uncomment to disable ehcache
    // excludes 'ehcache'
    excludes "xml-apis"
  }
  log "warn" // log level of Ivy resolver, either 'error', 'warn', 'info', 'debug' or 'verbose'
  repositories {
    grailsCentral()
    mavenRepo("http://repo.grails.org/grails/plugins/")
  }
  dependencies {
    // specify dependencies here under either 'build', 'compile', 'runtime', 'test' or 'provided' scopes eg.

    // runtime 'mysql:mysql-connector-java:5.1.5'
    compile('org.codehaus.groovy.modules.http-builder:http-builder:0.5.2') {
      excludes "commons-logging", "xml-apis", "groovy"
    }
  }

  plugins {
    build(":tomcat:$grailsVersion",
          ":rest-client-builder:1.0.2",
          ":release:2.0.2",
          ":hibernate:$grailsVersion") {
      export = false
    }

    compile(":codenarc:0.15") {
      export = false
    }


    compile(":gmetrics:0.3.1") {
      excludes "groovy-all"
      export = false
    }
  }
}
