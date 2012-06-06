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
import org.springframework.transaction.annotation.Transactional

/**
 * Service pour interaction avec cahier de textes
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
                                                                 Personne personne,
                                                                 String codePorteur = null) {
    assert (seance.enseignant == personne)
    def structId = seance.structureEnseignementId
    def personneId = personne.id
    def restRes = cahierTextesRestService.findCahiersByStructureAndEnseignant(structId,
                                                                                     personneId,
                                                                                     codePorteur)
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
  List<ChapitreInfo> getChapitreInfosForCahierId(Long cahierId,
                                                 Personne peronne,
                                                 String codePorteur = null) {
    def restRes = cahierTextesRestService.getStructureChapitresForCahierId(cahierId,
                                                                           peronne.id,
                                                                           codePorteur)
    def res = []
    def rang = 0
    if (restRes) {
      setupChapitreInfos(restRes["racine"], rang, res)
    }
    res
  }

  /**
   * Creer une activite dans le cahier de textes pour une séance tdbase
   * @param cahierId l'id du cahier dans lequel on crée l'activité
   * @param chapitreId l'id du chapitre dans lequel on créé l'activité
   * @param activiteContext le contexte de l'activité
   * @param seance la séance pour laquelle con créé l'activité
   * @param description la description de la séance
   * @param urlSeance l'url de la séance
   * @param personne la personne déclenchant l'opération
   * @return l'id de l'activité du cahier de textes qui a été créée
   */
  @Transactional
  Long createTextesActivite(Long cahierId,
                            Long chapitreId,
                            ContexteActivite activiteContext,
                            ModaliteActivite seance,
                            String description,
                            String urlSeance,
                            Personne personne,
                            String codePorteur = null) {
    assert (personne == seance.enseignant)
    def res = cahierTextesRestService.createTextesActivite(cahierId,
                                                           chapitreId,
                                                           activiteContext.name(),
                                                           personne.id,
                                                           seance.sujet.titre,
                                                           description,
                                                           seance.dateDebut,
                                                           seance.dateFin,
                                                           urlSeance,
                                                           codePorteur)
    def activiteId = null
    if (res) {
      activiteId = res.id as Long
      seance.activiteId = activiteId
      try {
        seance.save(failOnError: true)
      } catch (Exception e) {
        log.error(e.message)
        activiteId = null
      }
    }
    activiteId
  }

  private def setupChapitreInfos(List listeIn, Integer rang, List listeOut) {
    listeIn.each {
      def nom = new StringBuilder()
      rang.times() {
        nom << ". "
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
    nomAvecIndentation?.trim()
  }
}



enum ContexteActivite {
  CLA, // en classe
  MAI  // à la maison
}