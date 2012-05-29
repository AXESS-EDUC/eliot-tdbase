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
class NotesRestService {

  static transactional = false
  RestClient restClient

  /**
   * Récupère les services évaluables pour une séance donnée
   * format de la réponse
   * <code>
   * [kind: "List",
   *  total: 3,
   *  items:
   *  [[kind:"eliot-notes#services#standard",
   *  class:"org.lilie.services.eliot.scolarite.Service",
   *  id: 1,
   *  libelle: "1ES1(A)-AGL1-TP (T2)",
   *  typePeriodeId: 1,
   *  sousMatiereId: 1],
   *   [kind:"eliot-notes#services#standard",
   *   class:"org.lilie.services.eliot.scolarite.Service",
   *   id: 2,
   *   libelle: "1ES1(B)-AGL1-TP (T2)",
   *   typePeriodeId: 1,
   *   sousMatiereId: 2],
   *   ...
   *  ]
   *  ]
   *  </code
   * @param structureId  l'id de la structure enseignement concernée
   * @param date la date de début de la séance
   * @param enseignantId  l'id de l'enseignant concerné
   * @return  la map correspondant aux services trouvés
   */
  def findServicesEvaluablesByStrunctureAndDateAndEnseignant(Long structureId,
                                                             Date date,
                                                             Long enseignantId) {
      restClient.invokeOperation('findServicesEvaluablesByStrunctureAndDateAndEnseignant',
                                 null,
                                 [structureEnseignementId:structureId,
                                         date:date.format("yyyy-MM-dd'T'HH:mm:ss"),
                                         enseignantId:enseignantId])
  }
}

