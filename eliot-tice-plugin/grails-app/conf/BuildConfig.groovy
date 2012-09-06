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

//grails.project.war.file = "target/${appName}-${appVersion}.war"


versionTDBase = "2.0.4-CF-SNAPSHOT"

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
    mavenLocal()
    mavenRepo "http://repository-ticetime.forge.cloudbees.com/release"
    mavenRepo "http://repository-ticetime.forge.cloudbees.com/snapshot"
  }

  dependencies {
    // specify dependencies here under either 'build', 'compile', 'runtime', 'test' or 'provided' scopes eg.

    runtime "postgresql:postgresql:9.1-901.jdbc4"
    compile group: 'org.liquibase', name: 'liquibase-core', version: '2.0.2'
    runtime group: 'org.lilie.services.eliot', name: 'eliot-tice-dbmigration-all', version: "${versionTDBase}"
    compile('org.codehaus.groovy.modules.http-builder:http-builder:0.5.2') {
      excludes "commons-logging", "xml-apis", "groovy"
    }

  }

  plugins {

    build(":tomcat:$grailsVersion",
          ":rest-client-builder:1.0.2",
          ":release:2.0.2") {
      export = false
    }

    compile ":spring-security-core:1.2.7.2"

    compile(":hibernate:$grailsVersion") {
      export = false
    }


    compile(":codenarc:0.15") {
      export = false
    }

    compile(":gmetrics:0.3.1") {
      excludes "groovy-all"
      export = false
    }

    compile ":mail:1.0"
  }
}
