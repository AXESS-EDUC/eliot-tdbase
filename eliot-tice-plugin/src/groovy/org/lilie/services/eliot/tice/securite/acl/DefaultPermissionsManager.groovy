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

package org.lilie.services.eliot.tice.securite.acl

import org.lilie.services.eliot.tice.securite.DomainAutorisation

/**
 *  Classe fournissant la gestion des permissions pour un item donné par une
 * session donnée
 *
 * @author fsil
 * @author msan
 */
//TODO : ajouter autorisation heritee
public class DefaultPermissionsManager extends PermissionsManager {

  private DomainAutorisation autorisation

  /**
   * Créer un permissions manager pour l'item et l'autoritePers1 passés en paramètres.
   * Les permissions sont gérees par la session passée en paramètre.
   * Il faut donc que la session passée en paramètre dispose de l'autorisation de
   * modifier les permissions sur l'item
   * @param item l'item
   * @param autorite l'autorité
   * @param session la session
   */
  DefaultPermissionsManager(Item item,
                            Autorite autorite,
                            AclSecuritySession session)
  throws AutorisationException {
    super(item, autorite, session)
    autorisation = DomainAutorisation.findByAutoriteAndItem(autorite, item)
  }

  /**
   * Ajoute la propriété de l'item à l'autorité
   * @throws IllegalStateException si l'autorisation n'a pas pu être enregistrée
   */
  public void addPermissionProprietaire() throws IllegalStateException {
    if (autorisation?.autoriteEstProprietaire()) {
      // l'autorisation est déjà OK
      return;
    }
    if (autorisation == null) {
      // il faut créer l'autorisation
      autorisation = new DomainAutorisation(autorite: autorite, item: item)
    }
    autorisation.proprietaire = true
    if (!autorisation.save(flush: true)) {
      throw new IllegalStateException(
              "L'autorisation n'a pas pu être enregistrée : ${autorisation.errors}"
      )
    }

  }

  /**
   * Ajoute la permission de consulter l'item à l'autorité
   * @throws IllegalStateException si l'autorisation n'a pas pu être enregistrée
   */
  public void addPermissionConsultation() throws IllegalStateException {
    if (autorisation?.autoriseConsulterLeContenu()) {
      // l'autorisation est déjà OK
      return;
    }
    if (autorisation == null) {
      // il faut créer l'autorisation
      autorisation = new DomainAutorisation(autorite: autorite, item: item)
    }
    autorisation.valeurPermissionsExplicite |=
      Permission.PEUT_CONSULTER_CONTENU
    if (!autorisation.save(flush: true)) {
      throw new IllegalStateException(
              "L'autorisation n'a pas pu être enregistrée : ${autorisation.errors}"
      )
    }

  }

  /**
   * Ajoute la permission de modifier l'item à l'autorité
   */
  public void addPermissionModification() {
    if (autorisation?.autoriseModifierLeContenu()) {
      // l'autorisation est déjà OK
      return
    }
    if (autorisation == null) {
      // il faut créer l'autorisation
      autorisation = new DomainAutorisation(autorite: autorite, item: item)
    }
    // on considère que l'ajout de modification induit l'ajout de consultation
    autorisation.valeurPermissionsExplicite = autorisation.valeurPermissionsExplicite |
                                              Permission.PEUT_CONSULTER_CONTENU |
                                              Permission.PEUT_MODIFIER_CONTENU
    autorisation.save(flush: true)
  }

  /**
   * Ajoute la permission de consulter les permissions sur l'item à l'autorité
   */
  public void addPermissionConsultationPermissions() {
    if (autorisation?.autoriseConsulterLesPermissions()) {
      // l'autorisation est déjà OK
      return;
    }
    if (autorisation == null) {
      // il faut créer l'autorisation
      autorisation = new DomainAutorisation(autorite: autorite, item: item)
    }
    autorisation.valeurPermissionsExplicite = autorisation.valeurPermissionsExplicite |
                                              Permission.PEUT_CONSULTER_CONTENU |
                                              Permission.PEUT_CONSULTER_PERMISSIONS
    autorisation.save(flush: true)

  }

  /**
   * Ajoute la permission de modifier les permissions sur l'item à l'autorité
   */
  public void addPermissionModificationPermissions() {
    if (autorisation?.autoriseModifierLesPermissions()) {
      // l'autorisation est déjà OK
      return;
    }
    if (autorisation == null) {
      // il faut créer l'autorisation
      autorisation = new DomainAutorisation(autorite: autorite, item: item)
    }
    autorisation.valeurPermissionsExplicite = autorisation.valeurPermissionsExplicite |
                                              Permission.PEUT_CONSULTER_CONTENU |
                                              Permission.PEUT_CONSULTER_PERMISSIONS |
                                              Permission.PEUT_MODIFIER_PERMISSIONS
    autorisation.save(flush: true)
  }

  /**
   * Ajoute la permission de supprimer l'item à l'autorité
   */
  public void addPermissionSuppression() {
    if (autorisation?.autoriseSupprimer()) {
      // l'autorisation est déjà OK
      return;
    }
    if (autorisation == null) {
      // il faut créer l'autorisation
      autorisation = new DomainAutorisation(autorite: autorite, item: item)
    }
    autorisation.valeurPermissionsExplicite = autorisation.valeurPermissionsExplicite |
                                              Permission.PEUT_CONSULTER_CONTENU |
                                              Permission.PEUT_SUPPRIMER
    autorisation.save(flush: true)
  }

  /**
   * Supprime la permission de consulter l'item à l'autorité
   */
  public void deletePermissionConsultation() {
    if (autorisation == null) {
      return
    }
    if (!autorisation.autoriseConsulterLeContenu()) {
      return
    }
    autorisation.valeurPermissionsExplicite = 0
    if (autorisationEstSupprimee()) {
      return
    }
    autorisation.save(flush: true)

  }

  /**
   * Supprime la permission de modifier l'item à l'autorité
   */
  public void deletePermissionModification() {
    if (autorisation == null) {
      return
    }
    if (!autorisation.autoriseModifierLeContenu()) {
      return
    }
    autorisation.valeurPermissionsExplicite = autorisation.valeurPermissionsExplicite &
                                              (~Permission.PEUT_MODIFIER_CONTENU)
    if (autorisationEstSupprimee()) {
      return
    }
    autorisation.save(flush: true)
  }

  /**
   * supprime la permission de consulter les permissions sur l'item à l'autorité
   */
  public void deletePermissionConsultationPermissions() {
    if (autorisation == null) {
      return
    }
    if (!autorisation.autoriseConsulterLesPermissions()) {
      return
    }
    autorisation.valeurPermissionsExplicite = autorisation.valeurPermissionsExplicite &
                                              (~(Permission.PEUT_CONSULTER_PERMISSIONS |
                                                 Permission.PEUT_MODIFIER_PERMISSIONS))
    if (autorisationEstSupprimee()) {
      return
    }
    autorisation.save(flush: true)

  }

  /**
   * Supprimela permission de modifier les permissions sur l'item à l'autorité
   */
  public void deletePermissionModificationPermissions() {
    if (autorisation == null) {
      return
    }
    if (!autorisation.autoriseModifierLesPermissions()) {
      return
    }
    autorisation.valeurPermissionsExplicite = autorisation.valeurPermissionsExplicite &
                                              (~Permission.PEUT_MODIFIER_PERMISSIONS)
    if (autorisationEstSupprimee()) {
      return
    }
    autorisation.save(flush: true)
  }

  /**
   * Ajoute la permission de supprimer l'item à l'autorité
   */
  public void deletePermissionSuppression() {
    if (autorisation == null) {
      return
    }
    if (!autorisation.autoriseSupprimer()) {
      return
    }
    autorisation.valeurPermissionsExplicite = autorisation.valeurPermissionsExplicite &
                                              (~Permission.PEUT_SUPPRIMER)
    if (autorisationEstSupprimee()) {
      return
    }
    autorisation.save(flush: true)
  }


  private boolean autorisationEstSupprimee() {
    if (autorisation.valeurPermissions == 0 &&
        !autorisation.autoriteEstProprietaire()) {
      autorisation.delete()
      autorisation = null
      return true
    }
    return false
  }

}