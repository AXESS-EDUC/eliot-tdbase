import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.lilie.services.eliot.tice.utils.UrlServeurResolutionEnum

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

// L'URL d'accès à l'application
//

grails.serverURL = "http://demo.ticetime.com/eliot-tdbase"
eliot.tdbase.nomApplication = "eliot-tdbase"
eliot.urlResolution.mode = UrlServeurResolutionEnum.CONFIGURATION.name()
eliot.tdbase.urlServeur = "http://demo.ticetime.com/"

// determine si eliot-tdbase doit s'executer en mode intégration Lilie
//
eliot.portail.lilie = false
eliot.portail.lilieCasActive = false
eliot.portail.continueAfterUnsuccessfullCasLilieAuthentication = true

// application de la migration définie dans eliot-tice-dbmigration)
//
eliot.bootstrap.migration = true

// creation d'un jeu de test
//
eliot.bootstrap.jeudetest = true

// configuration de la racine de l'espace de fichier
//
eliot.fichiers.racine = '/usr/share/eliot-root'
eliot.fichiers.maxsize.mega = 10

// configuration des liens du menu portail et des annonces portail
//
eliot.portail.menu.affichage = true
eliot.portail.menu.liens = [[url: "http://wwww.ticetime.com",
        libelle: "ticetime"],
        [url: "https://github.com/ticetime/eliot-tdbase/wiki",
                libelle: "eliot-tdbase sur Github"]]
eliot.portail.news = ["Environnement DEMO",
        "Le projet est disponible sur <a href=\"https://github.com/ticetime/eliot-tdbase/wiki\" target=\"_blank\">Github</a> !",
        "Login / mot de passe enseignant : ens1 / ens1",
        "Login / mot de passe eleve 1 : elv1 / elv1",
        "Login / mot de passe eleve 2 : elv2 / elv2",
        "Login / mot de passe parent 1 : resp1 / resp1"]

// set url documentation
eliot.manuels.documents.urlMap = ["${FonctionEnum.ENS.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "${FonctionEnum.DOC.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "${FonctionEnum.CTR.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "${FonctionEnum.DIR.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "${FonctionEnum.ELEVE.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Eleve/content/index.html",
        "${FonctionEnum.PERS_REL_ELEVE.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Paren/content/index.html"]

// Spécifie si les objets sensés être créés sont bien créés
// à n'activier que si les données tdbase, notes et textes sont stockées dans
// la même base
eliot.interfacage.strongCheck = false
// rest client config for textes
eliot.webservices.rest.client.textes.user = "api"
eliot.webservices.rest.client.textes.password = "api"
eliot.webservices.rest.client.textes.urlServer = "http://www.ticeitime.com:8090"
eliot.webservices.rest.client.textes.uriPrefix = "/eliot-textes/echanges/v2"
eliot.webservices.rest.client.textes.connexionTimeout = 10000 // ms
// rest client config for notes
eliot.webservices.rest.client.notes.user = "api"
eliot.webservices.rest.client.notes.password = "api"
eliot.webservices.rest.client.notes.urlServer = "http://www.ticeitime.com:8090"
eliot.webservices.rest.client.notes.uriPrefix = "/eliot-notes/echanges/v2"
eliot.webservices.rest.client.notes.connexionTimeout = 10000 // ms

// data source
dataSource {
  pooled = false
  driverClassName = "org.postgresql.Driver"
  url = "jdbc:postgresql://localhost:5432/eliot-tdbase-demo"
  username = "eliot"
  password = "eliot"
  logSql = false
}

log4j = {

  appenders {
    //file name:'file', file:'/appli/tomcat/logs/eliot-tdbase-app.log'
    file name: 'file', file: '/tmp/eliot-tdbase-app.log'
  }

  root {
    info 'file'
    additivity = true
  }

  error 'org.hibernate.type', 'org.springframework.security'

  error 'grails',
        'org.codehaus.groovy.grails.web.servlet',  //  controllers
        'org.codehaus.groovy.grails.web.pages', //  GSP
        'org.codehaus.groovy.grails.web.sitemesh', //  layouts
        'org.codehaus.groovy.grails.web.mapping.filter', // URL mapping
        'org.codehaus.groovy.grails.web.mapping', // URL mapping
        'org.codehaus.groovy.grails.commons', // core / classloading
        'org.codehaus.groovy.grails.plugins',
        'org.codehaus.groovy.grails.orm.hibernate' // plugins
  //		'org.springframework'

  warn 'org.mortbay.log'
  info 'grails.app'
  error 'org.lilie.services.eliot.tice.webservices.rest.client.RestClient'
  error file: "StackTrace"

}
