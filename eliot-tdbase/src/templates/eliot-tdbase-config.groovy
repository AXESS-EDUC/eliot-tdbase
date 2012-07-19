import org.lilie.services.eliot.tice.scolarite.FonctionEnum

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
eliot.fichiers.storedInDatabase = true
eliot.fichiers.racine = '/tmp/eliot-root'
eliot.fichiers.maxsize.mega = 10

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
eliot.manuels.documents.urlMap = [
        "${FonctionEnum.ENS.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "${FonctionEnum.DOC.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "${FonctionEnum.CTR.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "${FonctionEnum.DIR.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Enseignant/content/index.html",
        "${FonctionEnum.ELEVE.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Eleve/content/index.html",
        "${FonctionEnum.PERS_REL_ELEVE.name()}": "http://ticetime.github.com/eliot-tdbase/aide/webhelp/Manuel_Utilisateur_TDBase_Paren/content/index.html"
]

// data source
dataSource {
  pooled = false
  driverClassName = "org.postgresql.Driver"
  url = "jdbc:postgresql://localhost:5432/eliot-tdbase"
  username = "eliot"
  password = "eliot"
  logSql = false
}

