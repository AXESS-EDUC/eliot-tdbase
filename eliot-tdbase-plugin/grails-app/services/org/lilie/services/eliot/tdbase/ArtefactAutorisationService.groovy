/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 * Lilie is free software. You can redistribute it and/or modify since
 * you respect the terms of either (at least one of the both license) :
 * - under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * - the CeCILL-C as published by CeCILL-C; either version 1 of the
 * License, or any later version
 *
 * There are special exceptions to the terms and conditions of the
 * licenses as they are applied to this software. View the full text of
 * the exception in file LICENSE.txt in the directory of this software
 * distribution.
 *
 * Lilie is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * Licenses for more details.
 *
 * You should have received a copy of the GNU General Public License
 * and the CeCILL-C along with Lilie. If not, see :
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */





package org.lilie.services.eliot.tdbase


import org.lilie.services.eliot.tice.annuaire.Personne

/**
 * Service de gestion des artefacts : un artefact est une question ou un sujet
 * Ce service contient les méthodes permettant de savoir si il est possible de
 * modifier, supprimer, dupliquer un artefact
 * @author franck silvestre
 */
class ArtefactAutorisationService {

  static transactional = false

  /**
   * Vérifie qu'un utilisateur peut supprimer un artefact
   * @param utilisateur l'utilisateur sur lequel on vérifie l'autorisation
   * @param artefact l'artefact sur lequel on vérifie l'autorisation
   * @return true si l'autorisation est vérifiée
   */
  boolean utilisateurPeutSupprimerArtefact(Personne utilisateur, Artefact artefact) {
    if (artefact.estInvariant()) {
      return false
    }
    return utilisateurPeutModifierArtefact(utilisateur, artefact) &&
           artefact.estSupprimableQuandArtefactEstModifiable()
  }

  /**
   * Vérifie qu'un utilisateur peut modifier un artefact
   * @param utilisateur l'utilisateur sur lequel on vérifie l'autorisation
   * @param artefact l'artefact sur lequel on vérifie l'autorisation
   * @return true si l'autorisation est vérifiée
   */
  boolean utilisateurPeutModifierArtefact(Personne utilisateur, Artefact artefact) {
    if (artefact.estInvariant()) {
      return false
    }
    if (utilisateur != artefact.proprietaire) {
      return false
    }
    return !artefact.estDistribue()
  }

  /**
   * Vérifie qu'un utilisateur peut masquer un artefact
   * @param utilisateur l'utilisateur sur lequel on vérifie l'autorisation
   * @param artefact l'artefact sur lequel on vérifie l'autorisation
   * @return true si l'autorisation est vérifiée
   */
  boolean utilisateurPeutMasquerArtefact(Personne utilisateur, Artefact artefact) {
    if (artefact.estInvariant()) {
      return false
    }
    return utilisateur == artefact.proprietaire
  }

  /**
   * Vérifie qu'un utilisateur peut dupliquer un artefact
   * @param utilisateur l'utilisateur sur lequel on vérifie l'autorisation
   * @param artefact l'artefact sur lequel on vérifie l'autorisation
   * @return true si l'autorisation est vérifiée
   */
  boolean utilisateurPeutDupliquerArtefact(Personne utilisateur, Artefact artefact) {
    if (artefact.estInvariant()) {
      return false
    }
    return utilisateurPeutReutiliserArtefact(utilisateur, artefact)
  }

  /**
   * Vérifie qu'un utilisateur peut partager un artefact
   * @param utilisateur l'utilisateur sur lequel on vérifie l'autorisation
   * @param artefact l'artefact sur lequel on vérifie l'autorisation
   * @return true si l'autorisation est vérifiée
   */
  boolean utilisateurPeutPartageArtefact(Personne utilisateur, Artefact artefact) {
    if (artefact.estInvariant()) {
      return false
    }
    if (artefact.estPartage()) {
      return false
    }
    return utilisateur == artefact.proprietaire
  }

  /**
   * Vérifie qu'un utilisateur peut réutiliser un artefact
   * @param utilisateur l'utilisateur sur lequel on vérifie l'autorisation
   * @param artefact l'artefact sur lequel on vérifie l'autorisation
   * @return true si l'autorisation est vérifiée
   */
  boolean utilisateurPeutReutiliserArtefact(Personne utilisateur, Artefact artefact) {
    if (utilisateur == artefact.proprietaire) {
      return true
    }
    return artefact.estPartage()
  }

  /**
   * Vérifie qu'un utilisateur peut exporter un artefact
   * @param utilisateur l'utilisateur sur lequel on vérifie l'autorisation
   * @param artefact l'artefact sur lequel on vérifie l'autorisation
   * @return true si l'autorisation est vérifiée
   */
  boolean utilisateurPeutExporterArtefact(Personne utilisateur, Artefact artefact) {
    utilisateurPeutReutiliserArtefact(utilisateur, artefact) && artefact.estPresentableEnMoodleXML()
  }


}


