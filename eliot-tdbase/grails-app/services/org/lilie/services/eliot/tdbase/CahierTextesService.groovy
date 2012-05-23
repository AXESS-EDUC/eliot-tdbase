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

import groovy.transform.ToString
import org.lilie.services.eliot.tdbase.webservices.rest.client.CahierTextesRestService
import org.lilie.services.eliot.tice.annuaire.Personne

/**
 * Service d'initiaisation de l'annuaire des opérations de web services Rest
 * @author franck Silvestre
 */
class CahierTextesService {

  static transactional = false
  CahierTextesRestService cahierTextesRestService

  /**
   * Récupère la liste des cahiers de textes infos
   * @param seance la modalité activité pour laquelle on récupère les cahiers
   * @param personne la personne qui déclenche l'opération
   * @return la liste des cahiers de textes
   */
  List<CahierTextesInfo> findCahiersTextesInfoByModaliteActivite(ModaliteActivite seance,
                                                                 Personne personne) {
    assert (seance.enseignant == personne)
    def structId = seance.structureEnseignementId
    def matId = seance.matiereId
    def personneId = personne.id
    def restRes = cahierTextesRestService.getCahiersForStructureMatiereAndEnseignant(structId, matId, personneId)
    def res = []
    if (restRes) {
      restRes.items.each {
        res << new CahierTextesInfo(id: it.id, nom: it.nom)
      }
    }
    res
  }

  /**
   * Récupère la liste des chapitres d'un cahier de textes
   * @param cahierId l'id du cahier
   * @param peronne la personne déclenchant l'opération
   * @return la liste des chapitres
   */
  List<ChapitreInfo> getChapitreInfosForCahierId(Long cahierId, Personne peronne) {
    def restRes = cahierTextesRestService.getStructureChapitresForCahierId(cahierId, peronne.id)
    def res = []
    def rang = 0
    if (restRes) {
      setupChapitreInfos(restRes["cahier-racine"], rang, res)
    }
    res
  }


  private def setupChapitreInfos(List listeIn, Integer rang, List listeOut) {
    listeIn.each {
      def nom = new StringBuilder()
      rang.times() {
        nom << " "
      }
      nom << it.nom
      listeOut << new ChapitreInfo(id: it.id, nomAvecIndentation: nom.toString())
      setupChapitreInfos(it["chapitres-fils"], rang + 2, listeOut)
    }
  }

}

/**
 * Classe d'objets encapsulant les informations sur un cahier de textes
 */
@ToString
class CahierTextesInfo {
  Long id
  String nom
}

/**
 * Classe d'objets encapsulant les informations d'un chapitre
 */
@ToString
class ChapitreInfo {
  Long id

  /**
   * le nom avec indentation correspondant à la profondeur du chapitre
   */
  String nomAvecIndentation

  /**
   *
   * @return le nom sans indentation
   */
  String getNom() {
    return nomAvecIndentation?.trim()
  }

}

enum ActiviteContext {
  EN_CLASSE,
  MAISON
}