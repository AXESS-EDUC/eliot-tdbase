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

class NotesController {

  def getServicesEvaluables() {
    println("INFO - getServicesEvaluables porteur et user: ")
    println("Porteur ENT : ${params.codePorteur}")

    def enseignantPersonneId = params.enseignantPersonneId as Long
    println("enseignantPersonneId : ${enseignantPersonneId}")
    def structureEnseignementId = params.structureEnseignementId as Long
    def date = params.date
    String resp = new JsonBuilder([[kind: "eliot-notes#evaluation-contextes#standard",
                                                  id: 1,
                                                  libelle: "1ES1(A)-AGL1-TP (T2)"],
                                                  [kind: "eliot-notes#evaluation-contextes#standard",
                                                          id: 2,
                                                          libelle: "1ES1(A)-AGL1-Oral (T2)"],
                                                  [kind: "eliot-notes#evaluation-contextes#standard",
                                                          id: 3,
                                                          libelle: "1ES1(A)-AGL1 (T2)"]]).toPrettyString()
    render(text: resp, contentType: "application/json", encoding: "UTF-8")
  }

  def createDevoir() {
    println("INFO - createDevoir contenu requete: ")
            println(request.inputStream.text)
    def evalId = 36
    String resp = new JsonBuilder([kind: "eliot-notes#evaluation#id",
                                          class: "org.lilie.services.eliot.notes.Evaluation",
                                          id: evalId]).toPrettyString()
    render(text: resp, contentType: "application/json", encoding: "UTF-8")
  }

  def updateNotes() {
    println("INFO - updateNotes contenu requete: ")
    println(request.inputStream.text)
    def evalId = params.evaluationId as Long
    println("evaluation id : $evalId")
    String resp = new JsonBuilder([[kind: "eliot-notes#note#standard",
                                          id: evalId]]).toPrettyString()
    render(text: resp, contentType: "application/json", encoding: "UTF-8")
  }

}

