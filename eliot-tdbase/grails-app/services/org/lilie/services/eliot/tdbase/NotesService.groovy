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

import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.StructureEnseignement

/**
 * Service pour interaction avec le module Notes
 * @author franck Silvestre
 */
class NotesService {

  static transactional = false

  /**
   * Récupère les services évaluables pour une structure donnée, à une date donnée
   * pour un enseignat donné
   * @param struct la structure d'enseignement
   * @param date la date de début de la séance
   * @param enseignant l'enseignant concerné par le devoir
   * @return la liste des services évaluables
   */
  List<ServiceInfo> findServicesEvaluablesByStructureAndDateAndEnseignant(StructureEnseignement struct,
                                                                          ModaliteActivite seance,
                                                                          Personne enseignant) {
    assert (enseignant == seance.enseignant)
    // todofsil cabler au client de web services
    [new ServiceInfo(id: 1, libelle: "1ES1(A)-AGL1-TP (T2)",typePeriodeId: 1,sousMatiereId: 1),
            new ServiceInfo(id: 2, libelle: "1ES1(B)-AGL1-TP (T2)",typePeriodeId: 1,sousMatiereId: 2),
            new ServiceInfo(id: 3, libelle: "1ES1(B)-AGL1 (T2)",typePeriodeId: 1,sousMatiereId: 1)]
  }

  /**
   * Crée un devoir pour un service donné, une séance donnée
   * @param serviceId l'id du service sur lequel on crée le devoir
   * @param seance la séance concernée
   * @param personne la personne déclenchant l'opération
   * @return
   */
  Long createDevoir(Long serviceId,
                                       Long typePeriodeId,
                                       Long sousMatiereId,
                                       ModaliteActivite seance,
                                       Personne personne) {
    assert (personne == seance.enseignant)
    // todofsil cabler au client de rest services
    def res = [id: 1]
    def evaluationId = null
    if (res) {
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
   * @param devoirId  l'id du devoir
   * @param notes  la map contenant les notes (key : id de l'élève, value: la note)
   * @param seance la seance concernée
   * @param personne  la personne déclenchant l'opération
   * @return
   */
  Long updateNotes(Long devoirId,Map<Long,Float> notes, ModaliteActivite seance,
                   Personne personne) {
    assert (personne == seance.enseignant)
    // todofsil cabler au client de rest services
    devoirId
  }


}

class ServiceInfo {
  Long id
  String libelle
  Long typePeriodeId
  Long sousMatiereId
}