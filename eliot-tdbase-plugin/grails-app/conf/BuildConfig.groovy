grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"
//grails.project.war.file = "target/${appName}-${appVersion}.war"

grails.plugin.location.'eliot-tice-plugin' = "../eliot-tice-plugin"
grails.plugin.location.'eliot-textes-plugin' = "../eliot-textes-plugin"
grails.plugin.location.'eliot-notes-plugin' = "../eliot-notes-plugin"

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
    // uncomment the below to enable remote dependency resolution
    // from public Maven repositories
    //mavenCentral()
    //mavenLocal()
    //mavenRepo "http://snapshots.repository.codehaus.org"
    //mavenRepo "http://repository.codehaus.org"
    //mavenRepo "http://download.java.net/maven/2/"
    //mavenRepo "http://repository.jboss.com/maven2/"
  }
  dependencies {
    // specify dependencies here under either 'build', 'compile', 'runtime', 'test' or 'provided' scopes eg.

    compile('org.gcontracts:gcontracts-core:1.2.4') {
      excludes "junit"
    }
    runtime "postgresql:postgresql:8.4-702.jdbc4"
  }

  plugins {
    build(":tomcat:$grailsVersion",
          ":release:1.0.0.RC3",
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
