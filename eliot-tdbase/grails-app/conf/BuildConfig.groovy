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

grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"

grails.plugin.location.'eliot-tice-plugin' = "../eliot-tice-plugin"


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

    runtime "postgresql:postgresql:8.4-702.jdbc4"

  }

  plugins {
    compile ":hibernate:$grailsVersion"
    compile ":jquery:1.6.1.1"
    compile ":resources:1.0"
    compile ":database-migration:0.2.1"

    compile(":spring-security-core:1.1.3")

    compile ":codenarc:0.12"
    compile(":gmetrics:0.3.1") {
      excludes "groovy-all"
    }

    build ":tomcat:$grailsVersion"
  }
}
