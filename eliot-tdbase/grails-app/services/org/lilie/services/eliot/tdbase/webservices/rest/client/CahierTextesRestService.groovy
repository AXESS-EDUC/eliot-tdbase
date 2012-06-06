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

package org.lilie.services.eliot.tdbase.webservices.rest.client

import org.lilie.services.eliot.tice.webservices.rest.client.RestClient

/**
 * Service d'initiaisation de l'annuaire des opérations de web services Rest
 * @author franck Silvestre
 */
class CahierTextesRestService {

  static transactional = false
  RestClient restClientForTextes

  /**
   * Récupère la structure en chapitre d'un cahier de textes identifié
   * par son Id
   * Format de la réponse
   * <code>
   *   [cahierId: 1,
   *    kind: "eliot-textes#chapitres#structure-chapitres",
   *    "cahier-racine": [
   *      [kind: "eliot-textes#chapitre#avec-chapitres-fils",
   *        id: 1,
   *        class: "org.lilie.service.eliot.textes.Chapitre",
   *        nom: "Chap 1"],
   *      [kind: "eliot-textes#chapitre#avec-chapitres-fils",
   *        id: 2,
   *        class: "org.lilie.service.eliot.textes.Chapitre",
   *        nom: "Chap 2",
   *        "chapitres-fils": [[
   *            kind: "eliot-textes#chapitre#avec-chapitres-fils",
   *            id: 3,
   *            class: "org.lilie.service.eliot.textes.Chapitre",
   *            nom: "Chap 2.1"],
   *            [kind: "eliot-textes#chapitre#avec-chapitres-fils",
   *            id: 4,
   *            class: "org.lilie.service.eliot.textes.Chapitre",
   *            nom: "Chap 2.2",]]],
   *     ...]
   *   </code>
   * @param cahierId l'id du cahier
   * @param personneId l'id de la personne effectuant la demande
   * @return une map représentant la structure du cahier
   */
  def getStructureChapitresForCahierId(Long cahierId, Long personneId,
                                       String codePorteur = null) {
    restClientForTextes.invokeOperation('getStructureChapitresForCahierId',
                                        [cahierId: cahierId],
                                        [utilisateurPersonneId: personneId,
                                        codePorteur: codePorteur])
  }

  /**
   * Récupère les cahiers pour une structure d'enseignement, une matière et un
   * enseignant donné.
   * Format de la réponse
   * <code>
   *   [kind: "PaginatedList",
   *    offset: 0,
   *    pageSize: 20,
   *    total: 3,
   *    items: [
   *    [kind: "eliot-textes#cahier-service#standard",
   *    class: "org.lilie.services.eliot.textes.CahierDeTextes",
   *    id: 1,
   *    nom: "cahier 1...",
   *    description: "C'est le cahier 1",
   *    estVise: true,
   *    dateCreation: new Date() - 150,
   *    service: [kind: "eliot#service#standard",
   *      class: "org.lilie.services.eliot.scolarite.Service",
   *      id: 1
   *      ]
   *    ],
   *    ...
   *    ]
   * </code>
   * @param structEnsId l'identifiant de la structure d'enseignement
   * @param matiereId l'identifiant de la matière
   * @param personneId l'identifiant de l'enseignant
   * @return la map représentant la liste des cahiers
   */
  def findCahiersByStructureAndEnseignant(Long structEnsId,
                                                 Long personneId,
                                                 codePorteur = null) {
    restClientForTextes.invokeOperation('findCahiersByStructureAndEnseignant',
                                        null,
                                        [structureEnseignementId: structEnsId,
                                                utilisateurPersonneId: personneId,
                                                codePorteur: codePorteur])
  }

  /**
   * Insert une activité dans un cahier de texte
   * Format de la réponse
   * <code>
   *   [kind : "eliot-textes#activite#id",
   *    class : "org.lilie.services.eliot.textes.Activite",
   *   id : activiteId]
   * </code>
   * @param cahierId l'id du cahier de texte
   * @param chapitreId l'id du chapitre dans lequel on insert l'activité
   * @param activiteContext le contexte d'activité : "CLA" ou "MAI"
   * @param personneId l'id de la personne déclenchant l'insertion
   * @param titre le titre de l'activité
   * @param description la description de l'activité
   * @param dateActivite la date de l'activité
   * @param urlSeance l'url de la séance
   * @return l'id de l'activite créee ou null
   */
  def createTextesActivite(Long cahierId,
                           Long chapitreId,
                           String activiteContext,
                           Long personneId,
                           String titre,
                           String description,
                           Date dateDebutActivite,
                           Date dateFinActivite,
                           String urlSeance,
                           codePorteur = null) {
    restClientForTextes.invokeOperation('createTextesActivite',
                                        [cahierId: cahierId],
                                                                         [utilisateurPersonneId: personneId,
                                                                                 codePorteur: codePorteur],
                                                                         [titre: titre,
                                                                                 cahierId: cahierId,
                                                                                 chapitreId: chapitreId,
                                                                                 dateDebutActivite: dateDebutActivite.format("yyyy-MM-dd'T'HH:mm:ss'Z'"),
                                                                                 dateFinActivite: dateFinActivite.format("yyyy-MM-dd'T'HH:mm:ss'Z'"),
                                                                                 contexteActivite: activiteContext,
                                                                                 description: description,
                                                                                 urlSeance: urlSeance])
  }

}

