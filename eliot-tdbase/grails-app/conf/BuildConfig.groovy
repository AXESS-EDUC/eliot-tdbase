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
grails.plugin.location.'eliot-tdbase-plugin' = "../eliot-tdbase-plugin"
grails.plugin.location.'eliot-textes-plugin' = "../eliot-textes-plugin"
grails.plugin.location.'eliot-notes-plugin' = "../eliot-notes-plugin"


grails.project.war.file = "target/${appName}.war"

// This closure is passed the location of the staging directory that
// is zipped up to make the WAR file, and the command line arguments.
grails.war.resources = { stagingDir, args ->
    copy(file: "src/templates/eliot-tdbase-config.groovy",
         tofile: "${stagingDir}/WEB-INF/classes/eliot-tdbase-config.groovy")
}

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
    mavenRepo "http://www.ticetime.com/nexus/content/repositories/snapshots/"
  }

  /**
   *   specify dependencies here under either 'build', 'compile', 'runtime',
   *   'test' or 'provided' scopes eg.
   */
  dependencies {
    runtime "postgresql:postgresql:8.4-702.jdbc4"
    compile group: 'net.sourceforge.saxon', name: 'saxon', version: '9.1.0.8'
  }

  plugins {
    compile ":hibernate:$grailsVersion"
    compile ":jquery:1.7.1"
    compile ":jquery-ui:1.8.15"
    compile ":resources:1.1.5"
    //compile ":spring-security-cas:1.0.2"
    compile ":codenarc:0.15"
    compile(":gmetrics:0.3.1") {
      excludes "groovy-all"
    }

    build(":tomcat:$grailsVersion",
          ":release:1.0.0")
  }
}