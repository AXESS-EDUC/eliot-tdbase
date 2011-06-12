grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"
//grails.project.war.file = "target/${appName}-${appVersion}.war"

grails.project.dependency.resolution = {
  // inherit Grails' default dependencies
  inherits("global") {
    // uncomment to disable ehcache
    // excludes 'ehcache'
  }
  log "warn" // log level of Ivy resolver, either 'error', 'warn', 'info', 'debug' or 'verbose'
  repositories {
    grailsPlugins()
    grailsHome()
    grailsCentral()

    mavenRepo "http://dev.axess-education.com:8080/nexus/content/groups/public-snapshots"
    mavenRepo "http://dev.axess-education.com:8080/nexus/content/groups/public"
    mavenRepo "http://dev.axess-education.com:8080/nexus/content/repositories/logica-snapshots"
    mavenRepo "http://dev.axess-education.com:8080/nexus/content/repositories/logica-releases"

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

    // dependances Eliot
    compile "commons-fileupload:commons-fileupload:1.2.1"
    compile "org.lilie.services.eliot:eliot-securite-commons:2.4.9-SNAPSHOT"
    compile "org.lilie.services.eliot:eliot-scolarite-commons:2.4.9-SNAPSHOT"
    compile "org.lilie.services.eliot:eliot-annuaire-commons:2.4.9-SNAPSHOT"

    runtime "postgresql:postgresql:8.4-702.jdbc4"

//      compile "org.lilie.socle:api-portail:1.6.0beta4"
    //      compile "org.lilie.socle:api-annuaire:1.6.0beta4"
    //      compile "org.lilie.socle:api-admin:1.6.0beta4"
    //      compile "org.lilie.socle:fmk-core-ent:1.6.0beta4"
    //      compile "org.lilie.socle:fmk-core-web:1.6.0beta4"
    //      compile "org.lilie.socle:api-web-droits:1.6.0beta4"
    //      compile "org.lilie.socle:api-recherche:1.6.0beta4"



  }

  plugins {
    compile ":hibernate:$grailsVersion"
    compile ":jquery:1.6.1.1"
    compile ":resources:1.0"
    compile ":database-migration:0.2.1"
    // dependances Eliot
    //compile  "org.lilie.services.eliot:grails-eliot-app-plugin:2.4.9-SNAPSHOT"

    build ":tomcat:$grailsVersion"
  }
}
