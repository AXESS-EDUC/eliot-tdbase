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

import com.pentila.evalcomp.domain.definition.EvaluationDefinition
import org.lilie.services.eliot.tdbase.ModaliteActivite

/**
 * Service de gestion des CampagneProxy
 *
 * @author John Tranier
 */
class CampagneProxyService {
  static transactional = true

  EmaEvalService emaEvalService

  /**
   * Mémorise une demande de création de campagne pour une séance TD Base.
   * La création de campagne sera effectuée ultérieurement, de manière asynchrone,
   * par EmaEvalCampagneJob.
   * Il s'agit donc d'une promesse de création de campagne.
   * @param modaliteActivite
   * @return
   */
  CampagneProxy promesseCreeCampagne(ModaliteActivite modaliteActivite) {
    CampagneProxy campagneProxy = CampagneProxy.findByModaliteActivite(modaliteActivite)

    if (campagneProxy) {
      campagneProxy.envoiOrdreCreationCampagne()
    } else {
      campagneProxy = new CampagneProxy(
          modaliteActivite: modaliteActivite,
          statut: CampagneProxyStatut.EN_ATTENTE_CREATION,
          operateurLogin: modaliteActivite.enseignant.autorite.identifiant
      )
      campagneProxy.save(failOnError: true)
    }

    return campagneProxy
  }

  /**
   * Mémorise une demande de suppression de campagne EmaEval.
   * La suppression de campagne sera effectuée ultérieurement, de manière asynchrone,
   * par EmaEvalCampagneJob.
   * Il s'agit donc d'une promesse de suppression de campagne.
   * @param modaliteActivite
   * @return
   */
  void promesseSupprimeCampagne(ModaliteActivite modaliteActivite) {
    CampagneProxy campagneProxy = CampagneProxy.findByModaliteActivite(modaliteActivite)

    if (!campagneProxy) {
      return // Rien à faire
    }

    campagneProxy.envoiOrdreSuppressionCampagne()
  }

  void realisePromesse(CampagneProxy campagneProxy) {
    if (!campagneProxy.hasPendingPromesse()) {
      throw new IllegalArgumentException(
          "Il n'y a aucun ordre en attente pour ce campagneProxy : $campagneProxy"
      )
    }

    switch (campagneProxy.statut) {
      case CampagneProxyStatut.EN_ATTENTE_CREATION:
        realisePromesseCreationCampagne(campagneProxy)
        break

      case CampagneProxyStatut.EN_ATTENTE_SUPPRESSION:
        realisePromesseSuppressionCampagne(campagneProxy)
        break

      default:
        throw new UnsupportedOperationException() // Ne devrait pas se produire
    }
  }

  private void realisePromesseCreationCampagne(CampagneProxy campagneProxy) {
    try {
      log.info "Création d'une campagne EmaEval pour la séance ${campagneProxy?.modaliteActivite?.id}"
      EvaluationDefinition campagne = emaEvalService.creeCampagne(
          campagneProxy.modaliteActivite
      )

      campagneProxy.campagneId = campagne.id
      campagneProxy.statut = CampagneProxyStatut.OK
      campagneProxy.save(failOnError: true)
    }
    catch (Throwable throwable) {
      log.error(
          "Erreur durant la création de la campagne pour la séance ${campagneProxy?.modaliteActivite?.id}",
          throwable
      )
      campagneProxy.statut = CampagneProxyStatut.ECHEC_CREATION
      campagneProxy.save(failOnError: true)
    }
  }

  private void realisePromesseSuppressionCampagne(CampagneProxy campagneProxy) {
    try {
      log.info "Suppression de la campagne EmaEval ${campagneProxy.campagneId}"
      emaEvalService.supprimeCampagneEmaEval(
          campagneProxy.operateurLogin,
          campagneProxy.campagneId
      )
      campagneProxy.delete()
    }
    catch (Throwable throwable) {
      log.error(
          "Erreur durant la suppression de la campagne ${campagneProxy.campagneId}",
          throwable
      )
      campagneProxy.statut = CampagneProxyStatut.ECHEC_SUPPRESSION
      campagneProxy.save(failOnError: true)
    }
  }

  /**
   * Retourne un lot de CampagneProxy qui représentent des opérations de création ou
   * de suppression de campagnes qui sont en attente
   * @param max le nombre max de résultat à retourner (le traitement s'effectue par lot)
   * @return
   */
  List<CampagneProxy> findLotCampagneProxyEnAttenteOperation(int max) {
    CampagneProxy.withCriteria {
      inList(
          'statut',
          [
              CampagneProxyStatut.EN_ATTENTE_CREATION,
              CampagneProxyStatut.EN_ATTENTE_SUPPRESSION
          ]
      )
      order('id', 'asc')
      maxResults(max)
    }
  }

  /**
   * Retourne un lot de CampagneProxy qui sont attentes de transmission des scores
   * de la séance TD Base associée
   * @param max le nombre max de résultat à retourner (le traitement s'effectue par lot)
   * @return
   */
  List<CampagneProxy> findLotCampagneProxyEnAttenteTransmissionScore(int max) {
    CampagneProxy.withCriteria {
      eq('statut', CampagneProxyStatut.OK)
      eq('scoreTransmissionStatut', ScoreTransmissionStatut.EN_ATTENTE_FIN_SEANCE)
      'modaliteActivite' {
        le('dateFin', new Date())
        eq('optionEvaluerCompetences', true)
      }
      order('id', 'asc')
      maxResults(max)
    }
  }
}
