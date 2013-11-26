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

import org.lilie.services.eliot.tdbase.ModaliteActivite

/**
 * Représente une campagne EmaEval, et les opérations en attentes d'exécution sur
 * celle-ci (création ou suppression).
 * @author John Tranier
 */
class CampagneProxy {
  Long campagneId // Identifiant de la campagne dans EmaEval
  ModaliteActivite modaliteActivite // Séance associée à cette campagne
  CampagneProxyStatut statut
  String operateurLogin // Login emaeval de l'utilisateur utilisé pour créer la campagne
  ScoreTransmissionStatut scoreTransmissionStatut = ScoreTransmissionStatut.EN_ATTENTE_FIN_SEANCE

  static constraints = {
    campagneId nullable: true
    modaliteActivite nullable: true
    statut validator: { val, obj ->
      switch (val) {
        case CampagneProxyStatut.EN_ATTENTE_CREATION:
          return obj.campagneId == null &&
              obj.modaliteActivite &&
              scoreTransmissionStatut == ScoreTransmissionStatut.EN_ATTENTE_FIN_SEANCE

        case CampagneProxyStatut.OK:
          return obj.campagneId != null && obj.modaliteActivite

        case CampagneProxyStatut.ECHEC_CREATION:
          return obj.campagneId && obj.modaliteActivite

        case CampagneProxyStatut.EN_ATTENTE_SUPPRESSION:
          return obj.campagneId != null

        case CampagneProxyStatut.ECHEC_SUPPRESSION:
          return obj.campagneId != null
      }
    }
  }

  static mapping = {
    table 'emaeval_interface.campagne_proxy'
    version(true) // Le versionnement est nécessaire pour prévenir de modification concurrente d'une séance par l'utilisateur & par EmaEvalJob
    id(column: "id", generator: "sequence", params: [sequence: 'emaeval_interface.campagne_proxy_id_seq'])
  }

  /**
   * Mémorise dans l'objet CampagneProxy que la campagne associée doit être créée.
   * La création sera gérée de manière asynchrone (par EmaEvalJob).
   *
   * Cette méthode effectue un traitement différent suivant le statut actuel du CampagneProxy
   */
  void envoiOrdreCreationCampagne() {
    switch (statut) {
    // La campagne est déjà créée ou en attente de création
      case CampagneProxyStatut.EN_ATTENTE_CREATION:
      case CampagneProxyStatut.OK:
        break

    // La campagne est en attente de suppression ou une tentative de suppression
    // de la campagne a échoué => on rétablit le proxy pour indiquer que la campagne existe déjà
      case CampagneProxyStatut.EN_ATTENTE_SUPPRESSION:
      case CampagneProxyStatut.ECHEC_SUPPRESSION:
        statut = CampagneProxyStatut.OK
        this.save(failOnError: true)
        break

      // La dernière tentative de création a échouée => on retente
      case CampagneProxyStatut.ECHEC_CREATION:
        statut = CampagneProxyStatut.EN_ATTENTE_CREATION
        this.save(failOnError: true)
        break
    }
  }

  /**
   * Mémorise dans l'objet CampagneProxy que la campagne associée doit être supprimée.
   * La suppression sera gérée de manière asynchrone (par EmaEvalJob).
   *
   * Cette méthode effectue un traitement différent suivant le statut actuel du CampagneProxy
   */
  void envoiOrdreSuppressionCampagne() {

    switch (statut) {
    // La campagne n'a jamais été créée
      case CampagneProxyStatut.EN_ATTENTE_CREATION:
      case CampagneProxyStatut.ECHEC_CREATION:
        this.delete() // on supprime simplement le proxy
        break

    // Rien à faire, la campagne est déjà en attente de suppression
      case CampagneProxyStatut.EN_ATTENTE_SUPPRESSION:
        break

    // Une campagne existe bien => on envoi l'ordre de suppression
      case CampagneProxyStatut.OK:
      case CampagneProxyStatut.ECHEC_SUPPRESSION: // Cas où la dernière tentative à échouée => on retente
        this.modaliteActivite = null // On supprime le lien (s'il existe) entre la campagne & la séance
        statut = CampagneProxyStatut.EN_ATTENTE_SUPPRESSION
        this.save(failOnError: true)
        break
    }
  }

  /**
   * Indique si ce proxy référence une opération en attente sur la campagne associée
   * (la campagne est en attente de création ou de suppression).
   * @return
   */
  boolean hasPendingPromesse() {
    return statut in [
        CampagneProxyStatut.EN_ATTENTE_CREATION,
        CampagneProxyStatut.EN_ATTENTE_SUPPRESSION
    ]
  }
}
