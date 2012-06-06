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

package org.lilie.services.eliot.tice.webservices.test

import groovy.json.JsonBuilder

class TextesController {

  def getStructure() {
    def cid = params.cahierId as Long
    if (cid > 0) {
      String resp = new JsonBuilder([cahierId: cid,
                                            kind: "eliot-textes#chapitres#structure-chapitres",
                                            "racine": [[kind: "eliot-textes#chapitre#court-chapitres-fils",
                                                    id: 1,
                                                    class: "org.lilie.service.eliot.textes.Chapitre",
                                                    nom: "Chap 1"],
                                                    [kind: "eliot-textes#chapitre#court-chapitres-fils",
                                                            id: 2,
                                                            class: "org.lilie.service.eliot.textes.Chapitre",
                                                            nom: "Chap 2",
                                                            "chapitres-fils": [[kind: "eliot-textes#chapitre#court-chapitres-fils",
                                                                    id: 3,
                                                                    class: "org.lilie.service.eliot.textes.Chapitre",
                                                                    nom: "Chap 2.1"], [kind: "eliot-textes#chapitre#court-chapitres-fils",
                                                                    id: 4,
                                                                    class: "org.lilie.service.eliot.textes.Chapitre",
                                                                    nom: "Chap 2.2"]]],

                                                    [kind: "eliot-textes#chapitre#court-chapitres-fils",
                                                            id: 5,
                                                            class: "org.lilie.service.eliot.textes.Chapitre",
                                                            nom: "Chap 3",
                                                            "chapitres-fils": [[kind: "eliot-textes#chapitre#court-chapitres-fils",
                                                                    id: 6,
                                                                    class: "org.lilie.service.eliot.textes.Chapitre",
                                                                    nom: "Chap 3.1"], [kind: "eliot-textes#chapitre#avec-chapitres-fils",
                                                                    id: 7,
                                                                    class: "org.lilie.service.eliot.textes.Chapitre",
                                                                    nom: "Chap 3.2"]]]

                                            ]

                                    ]).toPrettyString()
      render(text: resp, contentType: "application/json", encoding: "UTF-8")
    } else {
      render(contentType: "text/json") {
        cahierId = id
        erreur = "not found"
      }

    }

  }

  def getCahiersService() {
    def utilisateurPersonneId = params.utilisateurPersonneId as Long
    def structureEnseignementId = params.structureEnseignementId as Long
    def matiereId = params.matiereId as Long
    String resp = new JsonBuilder([kind: "PaginatedList",
                                          offset: 0,
                                          pageSize: 20,
                                          total: 3,
                                          items: [[kind: "eliot-textes#cahier-service#standard",
                                                  class: "org.lilie.services.eliot.textes.CahierDeTextes",
                                                  id: 1,
                                                  nom: "cahier 1...",
                                                  description: "C'est le cahier 1",
                                                  estVise: true,
                                                  dateCreation: new Date() - 150,
                                                  service: [kind: "eliot#service#standard",
                                                          class: "org.lilie.services.eliot.scolarite.Service",
                                                          id: 1]],
                                                  [kind: "eliot-textes#cahier-service#standard",
                                                          class: "org.lilie.services.eliot.textes.CahierDeTextes",
                                                          id: 2,
                                                          nom: "cahier 2...",
                                                          description: "C'est le cahier 2",
                                                          estVise: true,
                                                          dateCreation: new Date() - 150,
                                                          service: [kind: "eliot#service#standard",
                                                                  class: "org.lilie.services.eliot.scolarite.Service",
                                                                  id: 2]],
                                                  [kind: "eliot-textes#cahier-service#standard",
                                                          class: "org.lilie.services.eliot.textes.CahierDeTextes",
                                                          id: 3,
                                                          nom: "cahier 3...",
                                                          description: "C'est le cahier 3",
                                                          estVise: true,
                                                          dateCreation: new Date() - 150,
                                                          service: [kind: "eliot#service#standard",
                                                                  class: "org.lilie.services.eliot.scolarite.Service",
                                                                  id: 3]]]]).toPrettyString()
    render(text: resp, contentType: "application/json", encoding: "UTF-8")
  }

  def insertActivite() {
    println("INFO - insertActivite contenu requete: ")
        println(request.inputStream.text)
    def utilisateurPersonneId = params.utilisateurPersonneId as Long
    def actId = 1
    String resp = new JsonBuilder([kind : "eliot-textes#activite#id",
    class : "org.lilie.services.eliot.textes.Activite",
    id : actId]).toPrettyString()
    render(text: resp, contentType: "application/json", encoding: "UTF-8")
  }

}

