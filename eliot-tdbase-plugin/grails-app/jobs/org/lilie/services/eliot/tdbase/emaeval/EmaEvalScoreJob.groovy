/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 *  This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
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
 *   <http://www.gnu.org/licenses/> and
 *   <http://www.cecill.info/licences.fr.html>.
 */

package org.lilie.services.eliot.tdbase.emaeval

import org.lilie.services.eliot.tdbase.emaeval.score.EmaEvalScoreService

/**
 * Job prenant en charge la transmission asynchrone des scores entre un séance TD Base
 * et une campagne EmaEval
 *
 * @author John Tranier
 */
class EmaEvalScoreJob {
  def concurrent = false

  EmaEvalScoreService emaEvalScoreService

  private final static int BATCH_SIZE = 10

  def getTriggers() {
    if (!config.eliot.interfacage.emaeval.actif) {
      return null
    }

    return config.eliot.interfacage.emaeval.score.trigger
  }

  def execute() {
    log.info "Exécution du EmaEvalScoreJob"

    List<CampagneProxy> campagneProxyList =
      emaEvalScoreService.findLotCampagneProxyEnAttenteTransmissionScore(BATCH_SIZE)

    while(campagneProxyList) {
      traiteLot(campagneProxyList)

      campagneProxyList =
        emaEvalScoreService.findLotCampagneProxyEnAttenteTransmissionScore(BATCH_SIZE)
    }

  }

  private void traiteLot(List<CampagneProxy> campagneProxyList) {
    campagneProxyList.each { CampagneProxy campagneProxy ->
      try {
        emaEvalScoreService.transmetScoreCampagne(campagneProxy)
      }
      catch (Throwable throwable) {
        log.error(
            "Une erreur inconnue s'est produite durant l'exécution de EmaEvalScoreJob",
            throwable
        )
      }
    }
  }
}
