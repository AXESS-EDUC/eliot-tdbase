/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 *  Lilie is free software. You can redistribute it and/or modify since
 *  you respect the terms of either (at least one of the both license) :
 *  - under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *  - the CeCILL-C as published by CeCILL-C; either version 1 of the
 *  License, or any later version
 *
 *  There are special exceptions to the terms and conditions of the
 *  licenses as they are applied to this software. View the full text of
 *  the exception in file LICENSE.txt in the directory of this software
 *  distribution.
 *
 *  Lilie is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  Licenses for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  and the CeCILL-C along with Lilie. If not, see :
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */

package org.lilie.services.eliot.tdbase.xml.exemples


      [
        "quiz" : [
          [
            "nombreItems" : 11
          ]

          ,
          [
            "titre" : """Aire du cercle (pas du carré)""",
            "attachement" : [],

              "questionTypeCode": "calculated"

          ]

          ,
          [
            "titre" : """Consigne dispositif électronique""",
            "attachement" : [],

               "questionTypeCode": "Statement",
               "specification" : """{
                      "questionTypeCode": "Statement",
                      "enonce" : "Pas de calculatrice !"
                }"""


          ]

          ,
          [
            "titre" : """Question ouverte""",
            "attachement" : [],

              "questionTypeCode": "Open",
              "specification" : """{
                "questionTypeCode": "Open",
                "libelle" : "Ecrire un programme qui affiche Hello world",
                "nombreLignesReponses" : 5
              }"""

          ]

          ,
          [
            "titre" : """Serveur d'application / éditeurs""",
            "attachement" : [],

            "questionTypeCode" : "Associate",
            "specification" : """{
              "questionTypeCode" : "Associate",
              "libelle" : "Relier les serveurs d'applications avec les bons éditeurs\n",
              "montrerColonneAGauche" : true,
              "associations" : [
                 {
                   "participant1": "JBOSS",
                   "participant2": "Redhat"
                 },
                 {
                   "participant1": "Websphere",
                   "participant2": "IBM"
                 },
                 {
                   "participant1": "GlassFish",
                   "participant2": "Oracle"
                 },
                 {
                   "participant1": "Tomcat",
                   "participant2": "Fondation Apache"
                 }
              ]
            }"""

          ]

          ,
          [
            "titre" : """Question "Cloze" (composite ?)""",
            "attachement" : [],

              "questionTypeCode": "cloze"

          ]

          ,
          [
            "titre" : """Architecture à 3 niveaux ?""",
            "attachement" : [
              "nom" : "446px-Uncle_Sam_pointing_finger_.jpg"],

            "questionTypeCode" : "ExclusiveChoice",
            "specification" : """{
               "questionTypeCode" : "ExclusiveChoice",
               "libelle" : "Que désigne une architecture à 3 niveaux ?",
               "shuffled" : true,
               "reponses" : [
                  {
                     "libelleReponse" : "\n Une architecture MVC\n",
                     "id" : "1"
                  },
                  {
                     "libelleReponse" : "\n Une architecture N tiers ou N vaut 3\n",
                     "id" : "2"
                  }
               ],
               "indexBonneReponse": "2"
            }"""

          ]

          ,
          [
            "titre" : """Architectures N tiers""",
            "attachement" : [
              "nom" : "446px-Uncle_Sam_pointing_finger_.jpg"],

            "questionTypeCode" : "MultipleChoice",
            "specification" : """{
              "questionTypeCode" : "MultipleChoice",
               "libelle" : "Cocher les assertions vraies.",
               "shuffled" : true,
               "reponses" : [
                  {
                     "libelleReponse" : "\n Une architecture N-tiers est uniquement une architecture à base\n de Web Services\n",
                     "estUneBonneReponse" : false
                  },
                  {
                     "libelleReponse" : "\n Une architecture client serveur est une architecture N-tiers\n",
                     "estUneBonneReponse" : true
                  },
                  {
                     "libelleReponse" : "\n Une architecture N-tiers correspond à une architecture\n d'application distribuée sur plusieurs noeuds physiques\n",
                     "estUneBonneReponse" : true
                  },
                  {
                     "libelleReponse" : "\n Une application web est une application reposant sur une\n architecture N Tiers\n",
                     "estUneBonneReponse" : true
                  }
               ]
            }"""

          ]

          ,
          [
            "titre" : """HTTP 1er protocole de l'Internet""",
            "attachement" : [],

              "questionTypeCode":"Decimal",
              "specification" : """{
                "questionTypeCode":"Decimal",
                "libelle" : "En quelle année HTTP devient le premier protocole de\n l'Internet ?\n",
                "valeur" : 1996,
                "unite": "année",
                "precision": 0
              }"""

          ]

          ,
          [
            "titre" : """MVC""",
            "attachement" : [],

             "questionTypeCode" : "FillGap",
             "specification" : """{
                "questionTypeCode" : "FillGap",
                "libelle" : "Que signifie MVC ?",
                "saisieLibre" : true,
                "montrerLesMots" : false,
                "texteATrous" : "{=Model View Controller=Modèle vue contrôleur}"
             }"""

          ]

          ,
          [
            "titre" : """Premier langage Orienté Objet""",
            "attachement" : [],

             "questionTypeCode" : "FillGap",
             "specification" : """{
                "questionTypeCode" : "FillGap",
                "libelle" : "Quel est le premier langage Orienté Objet ?",
                "saisieLibre" : true,
                "montrerLesMots" : false,
                "texteATrous" : "{=Simula 66=Simula}"
             }"""

          ]

          ,
          [
            "titre" : """Tomcat et JEE""",
            "attachement" : [],

            "questionTypeCode" : "ExclusiveChoice",
            "specification" : """{
               "questionTypeCode" : "ExclusiveChoice",
               "libelle" : "Tomcat est un conteneur implémentant toutes les spécifications\n JEE.\n",
               "shuffled" : false,
               "reponses" : [
                  {
                     "libelleReponse" : "true",
                     "id" : "1"
                  },
                  {
                     "libelleReponse" : "false",
                     "id" : "2"
                  }
               ],
               "indexBonneReponse": "2"
            }"""

          ]

        ]
      ]
