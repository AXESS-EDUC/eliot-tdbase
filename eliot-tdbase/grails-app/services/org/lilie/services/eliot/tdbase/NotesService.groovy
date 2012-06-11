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

package org.lilie.services.eliot.tdbase

import org.lilie.services.eliot.tdbase.webservices.rest.client.NotesRestService
import org.lilie.services.eliot.tice.annuaire.Personne

/**
 * Service pour interaction avec le module Notes
 * @author franck Silvestre
 */
class NotesService {

  CopieService copieService
  NotesRestService notesRestService
  static transactional = false

  /**
   * Récupère les services évaluables pour une séance donnée
   * @param seance la séance
   * @param enseignant l'enseignant concerné par le devoir
   * @return la liste des services évaluables
   */
  List<ServiceInfo> findServicesEvaluablesByModaliteActivite(ModaliteActivite seance,
                                                             Personne enseignant,
                                                             String codePorteur = null) {
    assert (enseignant == seance.enseignant)
    def res = notesRestService.findServicesEvaluablesByStrunctureAndDateAndEnseignant(seance.structureEnseignementId,
                                                                                      seance.dateDebut,
                                                                                      enseignant.id,
                                                                                      codePorteur)
    def services = []
    if (res) {
      res.each {
        services << new ServiceInfo(id: it.id,
                                    libelle: it.libelle)
      }
    }
//    if (res?.items) {
//      res.items.each {
//        services << new ServiceInfo(id: it.id,
//                                    libelle: it.libelle)
//      }
//    }
    services
  }

  /**
   * Crée un devoir pour un service donné, une séance donnée
   * @param serviceId l'id du service sur lequel on crée le devoir
   * @param seance la séance concernée
   * @param personne la personne déclenchant l'opération
   * @return
   */
  Long createDevoir(ServiceInfo serviceInfo,
                    ModaliteActivite seance,
                    Personne personne,
                    String codePorteur = null) {
    assert (personne == seance.enseignant)
    def res = notesRestService.createDevoir(seance.sujet.titre,
                                            serviceInfo.id,
                                            seance.dateDebut,
                                            seance.sujet.calculNoteMax(),
                                            personne.id,
                                            codePorteur)
    def evaluationId = null
    if (res?.id) {
      evaluationId = res.id as Long
      seance.evaluationId = evaluationId
      try {
        seance.save(failOnError: true)
      } catch (Exception e) {
        log.error(e.message)
        evaluationId = null
      }
    }
    evaluationId
  }

  /**
   * Met à jour les notes d'un devoir pour une séance donnée
   * @param devoirId l'id du devoir
   * @param notes la map contenant les notes (key : id de l'élève, value: la note)
   * @param seance la seance concernée
   * @param personne la personne déclenchant l'opération
   * @return le nombre de notes modifiées
   */
  Long updateNotes(ModaliteActivite seance,
                   Personne personne,
                   String codePorteur = null) {
    assert (personne == seance.enseignant)
    def copies = copieService.findCopiesRemisesForModaliteActivite(seance,
                                                            personne)
    if (copies) {
      def notes = []
      copies.each { Copie copie ->
        notes << new EleveNote(eleveId: copie.eleveId, valeurNote: copie.correctionNoteFinale)
      }
      def res = notesRestService.updateNotes(seance.evaluationId,
                                             notes,
                                             personne.id,
                                             codePorteur)
      Long nbNotesMod = null
      if (res) {
        try {
          nbNotesMod = res.size()
        } catch (Exception e) {}
      }
      return nbNotesMod
    }
    return 0
  }


}

class ServiceInfo {
  String id
  String libelle
}

class EleveNote {
  Long eleveId
  Float valeurNote
}