import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.securite.RoleApplicatif
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

grails.serverURL = "http://localhost:8080/eliot-tdbase"
eliot.tdbase.nomApplication = "eliot-tdbase"
eliot.urlResolution.mode = UrlServeurResolutionEnum.CONFIGURATION.name()
eliot.tdbase.urlServeur = "http//localhost:8080"

// cas is not activated by default
//
grails.plugins.springsecurity.cas.active = false
grails.plugins.springsecurity.cas.loginUri = '/login'
grails.plugins.springsecurity.cas.serviceUrl = "http://localhost:8080/eliot-tdbase/j_spring_cas_security_check"
grails.plugins.springsecurity.cas.serverUrlPrefix = 'http://localhost:8181/cas-server-webapp-3.4.11'
grails.plugins.springsecurity.cas.proxyCallbackUrl = "http://localhost:8080/eliot-tdbase/secure/receptor"
grails.plugins.springsecurity.cas.proxyReceptorUrl = '/secure/receptor'

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
eliot.fichiers.racine = '/tmp/eliot-root'
eliot.fichiers.maxsize.mega = 10
eliot.fichiers.importexport.maxsize.mega = 25 // taille max spécifique aux fichiers d'import

// les dimensions de div continer à prendre en compte si nécessaire
eliot.pages.container.forceDimensions = false
// hauteur en pixel : ne s'applique que si forceDimensions est à true
eliot.pages.container.height = 629
// largeur en pixel : ne s'applique que si forceDimensions est à true
eliot.pages.container.width = 931

// configuration des liens du menu portail et des annonces portail
//
eliot.portail.menu.affichage = true
eliot.portail.menu.liens = [
        [
                url: "http://wwww.ticetime.com",
                libelle: "ticetime"
        ],
        [
                url: "https://github.com/ticetime/eliot-tdbase/wiki",
                libelle: "eliot-tdbase sur Github"
        ]
]
eliot.portail.news = [
        "TDBase version ${appVersion} - environnement DEMO",
        "Le projet est disponible sur <a href=\"https://github.com/ticetime/eliot-tdbase/wiki\" target=\"_blank\">Github</a> !",
        "Login / mot de passe enseignant : ens1 / ens1",
        "Login / mot de passe eleve 1 : elv1 / elv1",
        "Login / mot de passe eleve 2 : elv2 / elv2",
        "Login / mot de passe parent 1 : resp1 / resp1"
]

// set url documentation
eliot.manuels.documents.urlMap = ["${RoleApplicatif.ENSEIGNANT.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
                                  "${RoleApplicatif.ELEVE.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Eleve/content/index.html",
                                  "${RoleApplicatif.PARENT.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Paren/content/index.html"]

// l'url des fichiers de documentation par identifiant (item de question,...)
eliot.help.documents.urlMap = [
        "eliot.tdbase.item.${QuestionTypeEnum.Associate.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "eliot.tdbase.item.${QuestionTypeEnum.BooleanMatch.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "eliot.tdbase.item.${QuestionTypeEnum.Composite.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "eliot.tdbase.item.${QuestionTypeEnum.Decimal.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "eliot.tdbase.item.${QuestionTypeEnum.Document.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "eliot.tdbase.item.${QuestionTypeEnum.ExclusiveChoice.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "eliot.tdbase.item.${QuestionTypeEnum.FileUpload.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "eliot.tdbase.item.${QuestionTypeEnum.FillGap.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "eliot.tdbase.item.${QuestionTypeEnum.FillGraphics.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "eliot.tdbase.item.${QuestionTypeEnum.GraphicMatch.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "eliot.tdbase.item.${QuestionTypeEnum.Integer.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "eliot.tdbase.item.${QuestionTypeEnum.MultipleChoice.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "eliot.tdbase.item.${QuestionTypeEnum.Open.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "eliot.tdbase.item.${QuestionTypeEnum.Order.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "eliot.tdbase.item.${QuestionTypeEnum.Slider.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "eliot.tdbase.item.${QuestionTypeEnum.Statement.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "eliot.tdbase.introduction": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html"]

//  support de l'interfaçage eliot-notes
//
eliot.interfacage.notes = false

//  support de l'interfaçage eliot-textes
//
eliot.interfacage.textes = false

// rest client config for scolarite
eliot.webservices.rest.client.scolarite.user = "api"
eliot.webservices.rest.client.scolarite.password = "api"
eliot.webservices.rest.client.scolarite.urlServer = "http://localhost:8090"
eliot.webservices.rest.client.scolarite.uriPrefix = "/eliot-test-webservices/api-rest/v2"
eliot.webservices.rest.client.scolarite.connexionTimeout = 10000

// Support de l'interface EmaEval
eliot.interfacage.emaeval.actif = false
eliot.interfacage.emaeval.url = "https://emaeval.pentila.com/EvalComp/webservices/"
eliot.interfacage.emaeval.referentiel.nom = "Palier 3"
eliot.interfacage.emaeval.plan.nom = "Plan TDBase"
eliot.interfacage.emaeval.scenario.nom = "Evaluation directe"
eliot.interfacage.emaeval.methodeEvaluation.nom = "Methode d'évaluation" // Note : je ne comprends pas pourquoi la méthode n'a pas pour nom "Méthode d'évaluation booléenne" ...

// Trigger définissant la périodicité du job exécutant en tâche de fond
// la gestion des campagnes EmaEval (via les webservices)
eliot.interfacage.emaeval.campagne.trigger = {
  simple name: 'emaEvalCampagneTrigger', startDelay: 1000 * 60, repeatInterval: 1000 * 15
}

// Trigger définissant la périodicité du job exécutant en tâche de fond
// la transmission des résultats entre une séance TD Base et une campagne EmaEval
eliot.interfacage.emaeval.score.trigger = {
  simple name: 'emaEvalScoreTrigger', startDelay: 1000 * 60, repeatInterval: 1000 * 15
}


// Configuration plugin Quartz 2
grails.plugin.quartz2.autoStartup = true



// data source
dataSource {
  pooled = false
  driverClassName = "org.postgresql.Driver"
  url = "jdbc:postgresql://localhost:5432/eliot-tdbase"
  username = "eliot"
  password = "eliot"
  logSql = false
}

eliot.correspondant.force.allIdExterne = ["ent.personne.sadm1"]